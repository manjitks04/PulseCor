//
//  HealthKitService.swift
//  PulseCor
//
//  Core integration of HealthKit — converted to async/await
//
import SwiftData
import HealthKit

class HealthKitService {
    static let shared = HealthKitService()
    let healthStore = HKHealthStore()

    private init() {}

    // MARK: - Authorization

    func requestAuth() async -> (Bool, Error?) {
        let steps       = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let heartRate   = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let resting     = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let hrv         = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let typesToRead: Set = [steps, heartRate, resting, hrv]

        // HKHealthStore.requestAuthorization has no native async version —
        // wrap the callback in a continuation so callers can use await
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                continuation.resume(returning: (success, error))
            }
        }
    }

    // MARK: - Fetch Methods
    // HKStatisticsQuery has no native async API — wrapped with withCheckedContinuation

    func fetchSteps(since date: Date, context: ModelContext) async {
        let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)

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
            print("HealthKitService: no step data found for the week — check HealthKit permissions")
            return
        }

        await MainActor.run {
            let entry = StepEntry(count: sum.doubleValue(for: .count()), date: Date())
            context.insert(entry)
            try? context.save()
        }
    }

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

    // MARK: - Sync

    func syncWeeklySummary(context: ModelContext) {
        let calendar = Calendar.current
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return }

        // Clear old entries before re-fetching
        try? context.delete(model: StepEntry.self)
        try? context.delete(model: HeartRateEntry.self)
        try? context.delete(model: RestingHeartRateEntry.self)
        try? context.delete(model: HRVEntry.self)

        Task {
            await fetchSteps(since: sevenDaysAgo, context: context)
            await fetchHeartRate(since: sevenDaysAgo, context: context)
            await fetchHeartRestingRate(since: sevenDaysAgo, context: context)
            await fetchHeartRateVar(since: sevenDaysAgo, context: context)
        }
    }

    // MARK: - Background Observation

    func startObserving(context: ModelContext) {
        let identifiers: [HKQuantityTypeIdentifier] = [
            .stepCount, .heartRate, .restingHeartRate, .heartRateVariabilitySDNN
        ]

        for identifier in identifiers {
            let type = HKObjectType.quantityType(forIdentifier: identifier)!

            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, _, error in
                guard error == nil else { return }
                self?.syncWeeklySummary(context: context)
            }
            healthStore.execute(query)

            // enableBackgroundDelivery has no async API — Task wrapper keeps it off the main thread
            Task {
                await withCheckedContinuation { continuation in
                    self.healthStore.enableBackgroundDelivery(for: type, frequency: .hourly) { _, _ in
                        continuation.resume()
                    }
                }
            }
        }
    }
}
