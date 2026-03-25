//
//  DayStatus.swift
//  PulseCor
//
//
import Foundation

struct DayStatus: Identifiable {
    let id = UUID()
    let date: Date
    let hasCheckIn: Bool
    let medicationLogs: [(name: String, dosage: String, status: MedicationStatus)]
    let isFuture: Bool
    let isToday: Bool
    var isPlaceholder: Bool = false

    var hasAnyData: Bool { hasCheckIn || !medicationLogs.isEmpty }

    var previewText: String {
        var parts: [String] = []
        if hasCheckIn { parts.append("✓ Cora") }
        medicationLogs.forEach { parts.append($0.name) }
        return parts.joined(separator: " · ")
    }
}
