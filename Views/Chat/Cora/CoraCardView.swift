//
//  CoraCardView.swift
//  PulseCor
//
//  Cora's daily insight card that rotates content based on day of week and check-in history.
//  Shows tips (Mon/Wed/Thu/Sat), stats (Tue/Fri), or weekly reflection teaser (Sun).
//

import SwiftUI

struct CoraCardView: View {
    let cardType: CoraCardType
    var onViewReflection: (() -> Void)? = nil

    var body: some View {
        switch cardType {
        case .tip(let tip):
            TipCard(tip: tip)
        case .stat(let text):
            StatCard(text: text)
        case .sundayTeaser(let stat):
            SundayTeaserCard(stat: stat, onViewReflection: onViewReflection)
        case .sundayTopStat(let text):
            SundayTopStatCard(text: text, onViewReflection: onViewReflection)
        case .insufficientData:
            InsufficientDataCard()
        }
    }
}

// Daily wellness tip card (shown Mon/Wed/Thu/Sat)
private struct TipCard: View {
    let tip: CoraTip
    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Color("AccentCoral"))
                        .font(.system(size: 18, weight: .semibold))
                    Text("Today's Tip")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color("MainText"))
                }
                Text(tip.text)
                    .font(.subheadline)
                    .foregroundColor(Color("MainText").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                Spacer()
                Text("— \(tip.source)")
                    .font(.caption).italic()
                    .foregroundColor(Color("MainText").opacity(0.45))
            }
        }
        .padding(.horizontal, 20)
    }
}

// Weekly stat insight card (shown Tue/Fri)
// Displays personalied data-driven insight from past week's check-ins
private struct StatCard: View {
    let text: String
    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(Color("AccentCoral"))
                        .font(.system(size: 18, weight: .semibold))
                    Text("This Week")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color("MainText"))
                }
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(Color("MainText").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}

// Sunday teaser card with button to view full weekly reflection
// Shows brief preview stat and prompts user to open full reflection
private struct SundayTeaserCard: View {
    let stat: String
    var onViewReflection: (() -> Void)?
    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color("AccentCoral"))
                        .font(.system(size: 18, weight: .semibold))
                    Text("Weekly Reflection")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color("MainText"))
                }
                Text(stat)
                    .font(.subheadline)
                    .foregroundColor(Color("MainText").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                Spacer()
                Button(action: { onViewReflection?() }) {
                    Text("See your full weekly reflection →")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("AccentCoral"))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// Alternative Sunday card showing top stat with reflection button
// Used when user has not yet viewed this week's reflection
private struct SundayTopStatCard: View {
    let text: String
    var onViewReflection: (() -> Void)?
    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(Color("AccentCoral"))
                        .font(.system(size: 18, weight: .semibold))
                    Text("This Week")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color("MainText"))
                }
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(Color("MainText").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                Spacer()
                Button(action: { onViewReflection?() }) {
                    Text("View your weekly reflection →")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("AccentCoral"))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// Placeholder card shown when user has insufficient check-in history
// Appears until user completes first week (4+ check-ins)
private struct InsufficientDataCard: View {
    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.text.square")
                        .foregroundColor(Color("AccentCoral"))
                        .font(.system(size: 18, weight: .semibold))
                    Text("Cora's Insights")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color("MainText"))
                }
                Text("Helpful insights will appear here once you complete your first week of check-ins 💙")
                    .font(.subheadline)
                    .foregroundColor(Color("MainText").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}

// Reusable card container with consistent styling (background, border, shadow)
private struct CardShell<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
            .background(Color("CardBG"))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.gray.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
