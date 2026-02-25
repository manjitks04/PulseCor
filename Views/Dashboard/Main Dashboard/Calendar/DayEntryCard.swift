//
//  DayEntryCard.swift
//  PulseCor
//
//
import SwiftUI

struct DayEntryCard: View {

    struct BadgeStyle {
        let text: String
        let foreground: Color
        let background: Color
        let border: Color
    }

    let icon: String
    let iconColors: (Color, Color)
    let iconBorder: Color
    let title: String
    let subtitle: String
    let badge: BadgeStyle

    var body: some View {
        HStack(spacing: 14) {
            Text(icon)
                .font(.appMediumIcon)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [iconColors.0, iconColors.1],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(iconBorder, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appCardTitleSemibold)
                    .foregroundColor(Color("MainText"))
                    .lineLimit(1)

                Text(subtitle)
                    .font(.appBody)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(badge.text)
                .font(.appSmallBodyBold)
                .foregroundColor(badge.foreground)
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(badge.background)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(badge.border, lineWidth: 1)
                )
        }
        .padding(16)
        .background(Color("CardBG"))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}





















