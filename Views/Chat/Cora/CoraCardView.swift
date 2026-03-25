//
//  CoraCardView.swift
//  PulseCor
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
            StatCard(text: text)
        case .insufficientData:
            InsufficientDataCard()
        }
    }
}

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
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("MainText"))
                }

                Text(tip.text)
                    .font(.subheadline)
                    .foregroundColor(Color("MainText").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)

                Spacer()

                Text("— \(tip.source)")
                    .font(.caption)
                    .italic()
                    .foregroundColor(Color("MainText").opacity(0.45))
            }
        }
    }
}

private struct StatCard: View {
    let text: String

    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(Color("AccentCoral"))
                        .font(.system(size: 18, weight: .semibold))
                    Text("Last Week")
                        .font(.title3)
                        .fontWeight(.bold)
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
    }
}

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
                        .font(.title3)
                        .fontWeight(.bold)
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
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("AccentCoral"))
                        .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Insufficient Data Card

private struct InsufficientDataCard: View {
    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.text.square")
                        .foregroundColor(Color("AccentCoral"))
                        .font(.system(size: 18, weight: .semibold))
                    Text("Cora's Insights")
                        .font(.title3)
                        .fontWeight(.bold)
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
    }
}


private struct CardShell<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
            .background(Color("CardBG"))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.gray.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
