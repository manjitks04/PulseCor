//
//  StreakService.swift
//  PulseCor
//
//  Service responsible for all streak calculation and persistence logic
//  Called by ChatViewModel after a check-in completes, and by DashboardViewModel when refreshing streak display data
//

import Foundation
import SwiftData

struct StreakService {

    @discardableResult
    static func updateStreak(modelContext: ModelContext) throws -> Int {
        var descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == 1 })
        descriptor.fetchLimit = 1

        let user: User
        if let existing = try modelContext.fetch(descriptor).first {
            user = existing
        } else {
            let newUser = User(id: 1, name: "User")
            modelContext.insert(newUser)
            user = newUser
        }

        let calendar = Calendar.current
        var newStreak = 1

        if let lastCheckIn = user.lastCheckInDate {
            let lastStart = calendar.startOfDay(for: lastCheckIn)
            let todayStart = calendar.startOfDay(for: Date())
            let days = calendar.dateComponents([.day], from: lastStart, to: todayStart).day ?? 0

            if days == 1 {
                newStreak = user.currentStreak + 1  // Consecutive day — extend streak
            } else if days > 1 {
                newStreak = 1                        // Missed a day — reset streak
            } else {
                newStreak = user.currentStreak       // Same day check-in — no change
            }
        }

        user.currentStreak = newStreak
        user.longestStreak = max(user.longestStreak, newStreak)
        user.lastCheckInDate = Date()

        return newStreak
    }
}
