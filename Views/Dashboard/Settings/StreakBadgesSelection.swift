//
//  StreakBadgesSection.swift
//  PulseCor
//
//  Displays earned and locked streak badges in Settings
//  Shows 7 badges in two rows (4 top, 3 bottom) with unlock animations
//

import SwiftUI

struct StreakBadgesSection: View {
    let currentStreak: Int

    private let rowOne = Array(allBadgeDefinitions.prefix(4))
    private let rowTwo = Array(allBadgeDefinitions.suffix(3))

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Badges")
                .font(.title).fontWeight(.semibold)
                .foregroundColor(Color("TextBlue"))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    ForEach(rowOne) { badge in
                        BadgeTile(badge: badge, isUnlocked: currentStreak >= badge.requiredDays)
                            .frame(maxWidth: .infinity)
                    }
                }

                HStack(spacing: 0) {
                    ForEach(rowTwo) { badge in
                        BadgeTile(badge: badge, isUnlocked: currentStreak >= badge.requiredDays)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .padding()
        .background(Color("CardBG"))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .padding(.horizontal)
    }
}

// Individual badge tile showing lock/unlock state with animation
// Unlocked badges show full color and saturation, locked badges are grayscale and dim
private struct BadgeTile: View {
    let badge: StreakBadge
    let isUnlocked: Bool

    @State private var scale: CGFloat = 1.0
    @State private var didAnimate = false

    var body: some View {
        VStack(spacing: 6) {
            Image(badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .saturation(isUnlocked ? 1.0 : 0.0)
                .opacity(isUnlocked ? 1.0 : 0.35)
                .scaleEffect(scale)
                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: scale)

            Text(badge.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isUnlocked ? Color("MainText") : Color("MainText").opacity(0.4))
        }
        .onChange(of: isUnlocked) { _, newValue in
            if newValue && !didAnimate {
                didAnimate = true
                scale = 1.25
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    scale = 1.0
                }
            }
        }
    }
}
