//
//  HealthKitService.swift
//  PulseCor
//
// Core HealthKit integration layer, handles auth, background syncing, data fetching
//

import SwiftData
import HealthKit


// Manages auth and data sync, singleton service running in background
class HealthKitService {
    static let shared = HealthKitService()
    let healthStore = HKHealthStore()

    private var syncDebounceTask: Task<Void, Never>?

    private init() {}
    
    
    // Reuqests read access to metrics
    func requestAuth() async -> (Bool, Error?) {
        let steps = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let resting = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let typesToRead: Set = [steps, heartRate, resting, hrv]

        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                continuation.resume(returning: (success, error))
            }
        }
    }

    // Starts background observing for all metrics, hourly background delivery
    func startObserving(context: ModelContext) {
        let identifiers: [HKQuantityTypeIdentifier] = [
            .stepCount, .heartRate, .restingHeartRate, .heartRateVariabilitySDNN
        ]

        for identifier in identifiers {
            let type = HKObjectType.quantityType(forIdentifier: identifier)!

            // Observer query triggers whenever HealthKit detects new data
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, _, error in
                guard error == nil, let self else { return }
                self.scheduleDebouncedSync(context: context)
            }
            healthStore.execute(query)

            Task {
                await withCheckedContinuation { continuation in
                    self.healthStore.enableBackgroundDelivery(for: type, frequency: .hourly) { _, _ in
                        continuation.resume()
                    }
                }
            }
        }
    }

    private func scheduleDebouncedSync(context: ModelContext) {
        syncDebounceTask?.cancel()
        syncDebounceTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await syncWeeklySummary(context: context)
        }
    }

    
    // Fetches last 7 das of data, replaces all cached entries
    func syncWeeklySummary(context: ModelContext) async {
        let calendar = Calendar.current
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return }

        //clears data
        await MainActor.run {
            try? context.delete(model: StepEntry.self)
            try? context.delete(model: HeartRateEntry.self)
            try? context.delete(model: RestingHeartRateEntry.self)
            try? context.delete(model: HRVEntry.self)
            try? context.save()
        }

        //fetches all metrics in parallel
        async let steps: () = fetchSteps(since: sevenDaysAgo, context: context)
        async let hr: () = fetchHeartRate(since: sevenDaysAgo, context: context)
        async let rhr: () = fetchHeartRestingRate(since: sevenDaysAgo, context: context)
        async let hrv: () = fetchHeartRateVar(since: sevenDaysAgo, context: context)

        _ = await (steps, hr, rhr, hrv)
    }

    // Uses cumaltive sum from start of day till now
    func fetchSteps(since date: Date, context: ModelContext) async {
        let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let result: HKStatistics? = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                continuation.resume(returning: result)
            }
            healthStore.execute(query)
        }

        guard let sum = result?.sumQuantity() else {
            print("HealthKitService: no step data found — check HealthKit permissions")
            return
        }

        await MainActor.run {
            context.insert(StepEntry(count: sum.doubleValue(for: .count()), date: Date()))
            try? context.save()
        }
    }

    // 7 day average
    func fetchHeartRate(since date: Date, context: ModelContext) async {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)

        let result: HKStatistics? = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, _ in
                continuation.resume(returning: result)
            }
            healthStore.execute(query)
        }

        guard let avg = result?.averageQuantity() else { return }
        let bpm = avg.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))

        await MainActor.run {
            context.insert(HeartRateEntry(bpm: bpm, date: Date()))
            try? context.save()
        }
    }

    // 7 day average
    func fetchHeartRestingRate(since date: Date, context: ModelContext) async {
        let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)

        let result: HKStatistics? = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, _ in
                continuation.resume(returning: result)
            }
            healthStore.execute(query)
        }

        guard let avg = result?.averageQuantity() else { return }
        let bpm = avg.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))

        await MainActor.run {
            context.insert(RestingHeartRateEntry(bpm: bpm, date: Date()))
            try? context.save()
        }
    }

    // 7 day average
    func fetchHeartRateVar(since date: Date, context: ModelContext) async {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)

        let result: HKStatistics? = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, _ in
                continuation.resume(returning: result)
            }
            healthStore.execute(query)
        }

        guard let avg = result?.averageQuantity() else { return }
        let ms = avg.doubleValue(for: .secondUnit(with: .milli))

        await MainActor.run {
            context.insert(HRVEntry(ms: ms, date: Date()))
            try? context.save()
        }
    }
}
