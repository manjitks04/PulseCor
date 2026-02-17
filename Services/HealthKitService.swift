
//
//  HealthKitService.swift
//  PulseCor
//
//core integration of healthkit
//
import SwiftData
import HealthKit

class HealthKitService{
    let healthStore = HKHealthStore()
    static let shared = HealthKitService()
    
    func requestAuth(completion: @escaping (Bool, Error?) -> Void) {
        let steps = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let restingType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        let typesToRead: Set = [steps, heartRateType, restingType, hrvType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in completion(success, error)
        }
    }
    
    //fetches step count data
    func fetchSteps(since date: Date, context: ModelContext){
        let stepsQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                print("Oops, it seems like we haven't found any step data for the week. Please check you've authorised access to HealthKit in your device settings.")
                return
            }
            
            let totalStepsForWeek = sum.doubleValue(for: HKUnit.count())
            
            DispatchQueue.main.async {
                let newEntry = StepEntry(count: totalStepsForWeek, date: Date())
                context.insert(newEntry)
                try? context.save()
            }
        }
        healthStore.execute(query)
    }
    
    //fetches heart rate data
    func fetchHeartRate(since date: Date, context: ModelContext) {
        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: hrType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            guard let result = result, let avg = result.averageQuantity() else { return }
            
            let bpmValue = avg.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            
            DispatchQueue.main.async {
                let newEntry = HeartRateEntry(bpm: bpmValue, date: Date())
                context.insert(newEntry)
            }
        }
        healthStore.execute(query)
    }
    
    //fetches heart resting data
    func fetchHeartRestingRate(since date: Date, context: ModelContext) {
        let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: restingHRType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            guard let result = result, let avg = result.averageQuantity() else { return }
            
            let value = avg.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            
            DispatchQueue.main.async {
                let newEntry = RestingHeartRateEntry(bpm: value, date: Date())
                context.insert(newEntry)
            }
        }
        healthStore.execute(query)
    }
    
    //fetches heartRateVariabilitySDNN data
    func fetchHeartRateVar(since date: Date, context: ModelContext) {
        let restingHRType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: restingHRType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            guard let result = result, let avg = result.averageQuantity() else { return }
            
            let value = avg.doubleValue(for: .secondUnit(with: .milli))
            
            DispatchQueue.main.async {
                let newEntry = HRVEntry(ms: value, date: Date())
                context.insert(newEntry)
            }
        }
        healthStore.execute(query)
    }
    
    func syncWeeklySummary(context: ModelContext){
        let calendar = Calendar.current
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return }
        
        try? context.delete(model: StepEntry.self)
            try? context.delete(model: HeartRateEntry.self)
            try? context.delete(model: RestingHeartRateEntry.self)
            try? context.delete(model: HRVEntry.self)
        
        fetchSteps(since: sevenDaysAgo, context: context)
        fetchHeartRate(since: sevenDaysAgo, context: context)
        fetchHeartRestingRate(since: sevenDaysAgo, context: context)
        fetchHeartRateVar(since: sevenDaysAgo, context: context)
    }
}
