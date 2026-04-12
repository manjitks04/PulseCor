//
//  SettingsOnboardingOverlay.swift
//  PulseCor
//

import SwiftUI

struct SettingsOnboardingOverlay: View {
    @ObservedObject var manager = OnboardingViewModel.shared

    var body: some View {
        if manager.isActive && manager.isSettingsStep() {
            let info = OnboardingStepInfo.info(for: manager.currentStep)

            VStack {
                Spacer()

                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color("MainText").opacity(0.2))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 16)

                    ZStack {
                        Circle()
                            .fill(Color("AccentCoral").opacity(0.12))
                            .frame(width: 52, height: 52)
                        Image(systemName: info.icon)
                            .font(.system(size: 24))
                            .foregroundColor(Color("AccentCoral"))
                    }
                    .padding(.bottom, 12)

                    // Progress dots
                    HStack(spacing: 5) {
                        ForEach(1..<OnboardingStep.complete.rawValue, id: \.self) { i in
                            Capsule()
                                .fill(i <= manager.currentStep.rawValue ? Color("AccentCoral") : Color("MainText").opacity(0.15))
                                .frame(width: i == manager.currentStep.rawValue ? 16 : 6, height: 6)
                                .animation(.spring(response: 0.3), value: manager.currentStep.rawValue)
                        }
                    }
                    .padding(.bottom, 10)

                    VStack(spacing: 6) {
                        Text(info.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color("MainText"))
                            .multilineTextAlignment(.center)

                        Text(info.body)
                            .font(.system(size: 13))
                            .foregroundColor(Color("MainText").opacity(0.65))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    HStack(spacing: 12) {
                        if manager.currentStep.rawValue > 1 {
                            Button(action: { manager.backWithoutAnimation() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color("AccentCoral"))
                                    .frame(width: 44, height: 44)
                                    .background(Color("AccentCoral").opacity(0.12))
                                    .cornerRadius(12)
                            }
                        }
                        Button(action: { manager.nextWithoutAnimation() }) {
                            Text("Next →")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color("AccentCoral"))
                                .cornerRadius(12)
                        }
                        Button("Skip") { manager.skip() }
                            .font(.system(size: 13))
                            .foregroundColor(Color("MainText").opacity(0.35))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)
                .background(Color("MainBG"))
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.12), radius: 20, y: -4)
            }
            .ignoresSafeArea(edges: .bottom)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.4, dampingFraction: 0.78), value: manager.currentStep)
        }
    }
}
