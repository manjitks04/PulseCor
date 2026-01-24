//
//  DailyCheckIn.swift
//  PulseCor
//
//
import Foundation

struct DailyCheckIn: Codable {
    let id: Int?
    let userId: Int
    let date: Date
    var sleepQuality: SleepQuality?
    var sleepHours: SleepHours?
    var waterGlasses: WaterIntake?
    var stressLevel: StressLevel?
    var energyLevel: EnergyLevel?
    var activityLevel: ActivityLevel?
    var physicalSymptoms: String?
  
    let createdAt: Date
    var completedAt: Date?
    var isComplete: Bool
    
    // intialiser for new check-ins
    init(id: Int? = nil, userId: Int = 1, date: Date = Date(), sleepQuality: SleepQuality? = nil, sleepHours: SleepHours? = nil, waterGlasses: WaterIntake? = nil, stressLevel: StressLevel? = nil, energyLevel: EnergyLevel? = nil, activityLevel: ActivityLevel? = nil, physicalSymptoms: String? = nil, createdAt: Date = Date(), completedAt: Date? = nil, isComplete: Bool = false)
    {
            self.id = id
            self.userId = userId
            self.date = date
            self.sleepQuality = sleepQuality
            self.sleepHours = sleepHours
            self.waterGlasses = waterGlasses
            self.stressLevel = stressLevel
            self.energyLevel = energyLevel
            self.activityLevel = activityLevel
            self.physicalSymptoms = physicalSymptoms
            self.createdAt = createdAt
            self.completedAt = completedAt
            self.isComplete = isComplete
        }
    }

enum WaterIntake: String, Codable, CaseIterable {
    case veryHigh = "7+ glasses"
    case high = "5-6 glasses"
    case moderate = "3-4 glasses"
    case low = "0-2 glasses"
}

enum SleepQuality: String, Codable, CaseIterable {
    case refreshed = "Refreshed"
    case okay = "Okay"
    case groggy = "Groggy"
}

enum SleepHours: String, Codable, CaseIterable {
    case eightPlus = "8+ hours"
    case sevenToEight = "7-8 hours"
    case sixToSeven = "6-7 hours"
    case lessThanSix = "Less than 6"
}

enum StressLevel: String, Codable, CaseIterable {
    case calm = "Calm"
    case moderate = "A bit stressed"
    case high = "Very stressed"
}

enum EnergyLevel: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

enum ActivityLevel: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case none = "None"
}

