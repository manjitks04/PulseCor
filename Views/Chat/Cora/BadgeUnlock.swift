//
//  BadgeUnlock.swift
//  PulseCor
import SwiftUI
import Combine

struct BadgeUnlockSheet: View {
    let badge: StreakBadge
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color("MainBG").ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Text("🎉 Badge Unlocked!")
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(Color("MainText"))

                Image(badge.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .scaleEffect(scale)
                    .opacity(opacity)

                VStack(spacing: 8) {
                    Text(badge.label)
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(Color("AccentCoral"))

                    Text("You've earned your \(badge.label) streak badge. Keep it up — Cora's proud of you 💙")
                        .font(.subheadline)
                        .foregroundColor(Color("MainText").opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                Button(action: onDismiss) {
                    Text("Thanks, Cora!")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("AccentCoral"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.15)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
