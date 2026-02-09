//
//  AppErrors.swift
//  PulseCor
//
//
import Foundation

enum PulseCorError: Error, LocalizedError {
    // Database Errors
    case databaseSetupFailed
    case databaseConnectionFailed  // ← Add this
    case saveFailed(String)
    case fetchFailed(String)
    
    // Conversation Errors
    case sessionNotFound
    case invalidStepTransition
    
    // HealthKit Errors (For Week 14-15)
    case healthKitNotAvailable
    case healthDataDenied
    case healthKitAuthFailed(String)
    
    // A user-friendly description for the UI/Cora
    var errorDescription: String? {
        switch self {
        case .databaseSetupFailed:
            return "I'm having a little trouble accessing my memory right now."
        case .databaseConnectionFailed:  // ← Add this
            return "I'm having trouble connecting to my memory."
        case .saveFailed(let reason):
            return "I couldn't save that check-in: \(reason)"
        case .healthDataDenied:
            return "I don't have permission to see your heart rate data yet!"
        default:
            return "Something went wrong. Let's try that again."
        }
    }
