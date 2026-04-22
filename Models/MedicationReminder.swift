//
//  MedicationReminder.swift
//  PulseCor
//
// Models for medication tracking and reminder logging
//

import Foundation
import SwiftData

@Model
class Medication {
    var userId: Int
    var name: String
    var dosage: String
    var frequency: String
    var reminderTimes: [String] 
    var isActive: Bool
    var createdAt: Date
    var localId: UUID // Unique identifier for linking to MedicationLog entries
    init(
        userId: Int = 1,
        name: String,
        dosage: String,
        frequency: String,
        reminderTimes: [String] = [],
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.userId = userId
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.reminderTimes = reminderTimes
        self.isActive = isActive
        self.createdAt = createdAt
        self.localId = UUID()
    }
}

// Records user's response to medication reminder notifcation
@Model
class MedicationLog {
    var medicationLocalId: UUID
    var status: MedicationStatus
    var timestamp: Date
    var scheduledTime: String

    var medicationName: String
    var medicationDosage: String

    init(
        medicationLocalId: UUID,
        medicationName: String,
        medicationDosage: String,
        status: MedicationStatus,
        scheduledTime: String,
        timestamp: Date = Date()
    ) {
        self.medicationLocalId = medicationLocalId
        self.medicationName = medicationName
        self.medicationDosage = medicationDosage
        self.status = status
        self.scheduledTime = scheduledTime
        self.timestamp = timestamp
    }
}

enum MedicationStatus: String, Codable, CaseIterable {
    case taken = "Taken"
    case skipped = "Skipped"
    case snoozed = "Remind me later"
}

// View-layer representation of a medication log, used in UI to display medication history without queries

struct MedicationLogEntry {
    let medicationLocalId: UUID
    let name: String
    let dosage: String
    let status: MedicationStatus
    let timestamp: Date
}
