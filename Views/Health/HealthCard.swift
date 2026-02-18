//
//  HealthCard.swift
//  PulseCor
//
//
import SwiftUI
import SwiftData

struct HealthMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let gradientColors: [Color]

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.appIcon)
                .foregroundStyle(
                    LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appCardTitle)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.appHeroBold)
                    .foregroundStyle(
                        LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
                    )

                Text(unit)
                    .font(.appSmallBody)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color("CardBG"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
