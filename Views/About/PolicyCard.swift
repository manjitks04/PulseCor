//
//  PolicyCard.swift
//  PulseCor
//

import SwiftUI

struct PolicyCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("MainText"))

            Text(content)
                .font(.system(size: 12))
                .foregroundColor(Color("MainText"))
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("CardBG"))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
