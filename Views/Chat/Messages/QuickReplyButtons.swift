//
//  QuickReplyButtons.swift
//  PulseCor
//
//
import SwiftUI

struct QuickReplyButtons: View {
    let replies: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(replies, id: \.self) { reply in
                Button(action: { onSelect(reply) }) {
                    Text(reply)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("AccentCoral"))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}
