//
//  DaySectionLabel.swift
//  PulseCor
//
//
import SwiftUI

struct DaySectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.appSmallBodyBold)
            .kerning(1)
            .foregroundColor(.secondary)
            .padding(.horizontal, 4)
    }
}





















