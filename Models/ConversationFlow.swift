//
//  ConversationFlow.swift
//  PulseCor
//
//
import Foundation

struct ConversationFlow: Codable {
    let id: Int?
    let sessionId: String
    let userId: Int
    let flowType: FlowType
    var currentStep: ConversationStep
    var isComplete: Bool
    let startedAt: Date
    var completedAt: Date?
    
    // Temporary data storage (e.g., "sleepHours": "7-8")
    // This is vital for the "Skip" or "Not now" feature in your MVP doc
    var tempData: [String: String]
    
    // Initializer
    init(id: Int? = nil,
         sessionId: String = UUID().uuidString,
         userId: Int = 1,
         flowType: FlowType,
         currentStep: ConversationStep,
         isComplete: Bool = false,
         startedAt: Date = Date(),
         completedAt: Date? = nil,
         tempData: [String: String] = [:]) {
        self.id = id
        self.sessionId = sessionId
        self.userId = userId
        self.flowType = flowType
        self.currentStep = currentStep
        self.isComplete = isComplete
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.tempData = tempData
    }
}

enum FlowType: String, Codable, CaseIterable {
    case onboarding = "onboarding"
    case dailyCheckIn = "daily_check_in"
    case medicationReminder = "medication_reminder"
    case weeklyReflection = "weekly_reflection"
}

enum ConversationStep: String, Codable, CaseIterable {
    // Onboarding
    case welcome, getName, healthKitAuth
    
    // Daily Check-in (Matches your Cora Conversational Flow.docx)
    case greeting
    case askSleepQuality
    case askSleepHours
    case askWater
    case askStress
    case askEnergy
    case askMood
    case askActivity
    case askSymptoms
    
    // Medication (Phase 2 feature)
    case medReminder, medActionTaken
    
    // General
    case completion
}

