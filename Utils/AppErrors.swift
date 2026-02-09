//
//  AppErrors.swift
//  PulseCor
//
//
import Foundation

enum PulseCorError: Error, LocalizedError {
    // Database Errors
    case databaseSetupFailed
    case databaseConnectionFailed
    case saveFailed(String)
    case fetchFailed(String)
    
    // Conversation Errors
    case sessionNotFound
    case invalidStepTransition
    
    // HealthKit Errors
    case healthKitNotAvailable
    case healthDataDenied
    case healthKitAuthFailed(String)
    
    // A user-friendly description for the UI/Cora
    var errorDescription: String? {
            switch self {
            case .databaseSetupFailed:
                return "I'm having a little trouble accessing my memory right now."
            case .databaseConnectionFailed:
                return "I'm having trouble connecting to my memory."
            case .saveFailed(let reason):
                return "I couldn't save that check-in: \(reason)"
            case .fetchFailed(let reason):
                return "I couldn't retrieve that data: \(reason)"
            case .sessionNotFound:
                return "I seem to have lost track of our conversation. Let's start fresh!"
            case .invalidStepTransition:
                return "Something went wrong with our conversation flow."
            case .healthKitNotAvailable:
                return "Apple Health isn't available on this device."
            case .healthDataDenied:
                return "I don't have permission to see your health data yet! Please enable it in your iPhone Settings."
            case .healthKitAuthFailed(let reason):
                return "I couldn't connect to Apple Health: \(reason)"
            }
        }
    }
