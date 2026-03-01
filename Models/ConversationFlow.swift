//
//  ConversationFlow.swift
//  PulseCor
//
import Foundation
import SwiftData

@Model
class ConversationFlow {
    @Attribute(.unique) var sessionId: String
    var userId: Int
    var flowType: FlowType
    var currentStep: ConversationStep
    var isComplete: Bool
    var startedAt: Date
    var completedAt: Date?
    var tempData: [String: String]

    init(
        sessionId: String = UUID().uuidString,
        userId: Int = 1,
        flowType: FlowType,
        currentStep: ConversationStep,
        isComplete: Bool = false,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        tempData: [String: String] = [:]
    ) {
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
    case welcome, getName, healthKitAuth
    case greeting
    case askSleepQuality
    case askSleepHours
    case askWater
    case askStress
    case askEnergy
    case askMood
    case askActivity
    case askSymptoms
    case medReminder, medActionTaken
    case completion
}
