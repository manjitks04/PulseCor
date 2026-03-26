//
//  BadgeDefinitions.swift
//  PulseCor
//
//  Used by StreakBadgesSection (UI) and ChatViewModel (unlock detection).
//

import Foundation

struct StreakBadge: Identifiable {
    let id: String
    let imageName: String
    let label: String
    let requiredDays: Int
}

let allBadgeDefinitions: [StreakBadge] = [
    StreakBadge(id: "1w",  imageName: "SB1W", label: "1 Week",   requiredDays: 7),
    StreakBadge(id: "2w",  imageName: "SB2W", label: "2 Weeks",  requiredDays: 14),
    StreakBadge(id: "1m",  imageName: "SB1M", label: "1 Month",  requiredDays: 30),
    StreakBadge(id: "3m",  imageName: "SB3M", label: "3 Months", requiredDays: 90),
    StreakBadge(id: "6m",  imageName: "SB6M", label: "6 Months", requiredDays: 180),
    StreakBadge(id: "9m",  imageName: "SB9M", label: "9 Months", requiredDays: 270),
    StreakBadge(id: "1y",  imageName: "SB1Y", label: "1 Year",   requiredDays: 365),
]
