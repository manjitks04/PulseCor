//
//  MedicationStatus.swift
//  PulseCor
//
// UI styling
import SwiftUI

extension MedicationStatus {
    // Icon background colours, used in calendar medication log cards
    var iconColors: (Color, Color) {
        switch self {
        case .taken:   return (Color("AccentPink").opacity(0.25), Color("AccentPink").opacity(0.1))
        case .snoozed: return (Color.orange.opacity(0.25), Color.orange.opacity(0.1))
        case .skipped: return (Color(.systemGray4).opacity(0.3), Color(.systemGray4).opacity(0.15))
        }
    }

    var iconBorder: Color {
        switch self {
        case .taken:   return Color("AccentPink").opacity(0.2)
        case .snoozed: return Color.orange.opacity(0.2)
        case .skipped: return Color(.systemGray4).opacity(0.3)
        }
    }

    // Badge style configurations for dayEntryCard display
    var badge: DayEntryCard.BadgeStyle {
        switch self {
        case .taken:
            return DayEntryCard.BadgeStyle(
                text: rawValue,
                foreground: Color("AccentPink"),
                background: Color("AccentPink").opacity(0.15),
                border: Color("AccentPink").opacity(0.25)
            )
        case .snoozed:
            return DayEntryCard.BadgeStyle(
                text: "Snoozed",
                foreground: Color.orange,
                background: Color.orange.opacity(0.15),
                border: Color.orange.opacity(0.25)
            )
        case .skipped:
            return DayEntryCard.BadgeStyle(
                text: rawValue,
                foreground: Color(.systemGray2),
                background: Color(.systemGray6),
                border: Color(.systemGray4).opacity(0.3)
            )
        }
    }
}





















