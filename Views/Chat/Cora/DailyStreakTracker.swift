//
//  DailyStreakTracker.swift
//  PulseCor
//
//  Weekly check-in progress tracker showing 7-day cycle with point rewards.
//  Displays current day in cycle, progress bar, and total points earned.
//

import SwiftUI
import SwiftData

struct DailyStreakTracker: View {
    let currentDay: Int
    
    // Point rewards for each day of the week
    let rewards = [5, 5, 10, 10, 15, 15, 25]

    var body: some View {
        // Maps overall streak to current position in 7-day cycle
        let displayDay = currentDay == 0 ? 0 : currentDay % 7 == 0 ? 7 : currentDay % 7

        VStack(spacing: 12) {
            // Header with dynamic encouragement message
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily check in")
                        .font(.appSectionHeaderSemibold)
                        .foregroundColor(Color("MainText"))

                    Text(currentDay == 0 ? "Achieve a 7 day streak to unlock a special badge!" : currentDay < 7  ? "Keep going — you're \(7 - currentDay) day\(7 - currentDay != 1 ? "s" : "") away from your first badge!" : "Keep going to unlock more badges!")
                        .font(.appBody)
                        .foregroundColor(Color("MainText").opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            // 7-day progress cards
            HStack(spacing: 6) {
                ForEach(1...7, id: \.self) { day in
                    DayCard(day: day, reward: rewards[day - 1], isCompleted: day <= displayDay, isCurrent: day == displayDay)
                }
            }

            // Progress bar showing completion through the week
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 4)
                    Rectangle()
                        .fill(LinearGradient(colors: [Color("AccentCoral"), Color("AccentPink")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width * CGFloat(min(displayDay, 7)) / 7, height: 4)
                }
                .cornerRadius(2)
            }
            .frame(height: 4)
            .padding(.horizontal, 4)

            // Footer showing total streak and points earned this cycle
            HStack {
                Text("Current streak: \(currentDay) day\(currentDay != 1 ? "s" : "")")
                    .font(.appBodySemibold)
                    .foregroundColor(Color("MainText"))
                Spacer()
                let earnedPoints = rewards.prefix(min(displayDay, 7)).reduce(0, +)
                Text("\(earnedPoints)/\(rewards.reduce(0, +)) pts")
                    .font(.appBody)
                    .foregroundColor(Color("MainText").opacity(0.6))
            }
        }
        .padding(16)
        .background(Color("CardBG"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.gray.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .padding(.horizontal, 20)
    }
}
