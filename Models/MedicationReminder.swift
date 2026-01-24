//
//  MedicationReminder.swift
//  PulseCor
//
//
import Foundation

//The main schedule/setting for a medication
struct Medication: Codable {
    let id: Int?
    let userId: Int
    let name: String
    let dosage: String
    let frequency: String
    var reminderTimes: [String]? // "08:00", "20:00"
    var isActive: Bool
    let createdAt: Date
    
    init(id: Int? = nil, userId: Int = 1, name: String, dosage: String, frequency: String, reminderTimes: [String]? = nil, isActive: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.reminderTimes = reminderTimes
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

//The specific record of an event (Taken, Skipped, etc.)
struct MedicationLog: Codable {
    let id: Int?
    let medicationId: Int
    let status: MedicationStatus
    let timestamp: Date
    let scheduledTime: String // Which reminder time this was for
}

enum MedicationStatus: String, Codable, CaseIterable {
    case taken = "Taken"
    case skipped = "Skipped"
    case snoozed = "Remind me later"
}
