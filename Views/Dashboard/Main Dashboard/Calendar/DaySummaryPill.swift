//
//  DaySummaryPill.swift
//  PulseCor
//
//
import SwiftUI

struct DaySummaryPill: View {
    let text: String
    let dotColor: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.appCardTitle)
                .foregroundColor(dotColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(dotColor.opacity(0.15))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(dotColor.opacity(0.25), lineWidth: 1)
        )
    }
}
