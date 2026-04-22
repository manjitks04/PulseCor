//
//  OnboardingOverlayView.swift
//  PulseCor
//

import SwiftUI
import SwiftData

struct OnboardingOverlayView: View {
    @ObservedObject var manager = OnboardingViewModel.shared
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if manager.isActive {
            switch manager.currentStep {
            case .name:
                NameEntrySlide()
                    .transition(.opacity)
            case .complete:
                OnboardingCompleteSlide()
                    .transition(.opacity)
            default:
                FeatureSlide()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
    }
}

private struct NameEntrySlide: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var manager = OnboardingViewModel.shared
    @State private var name: String = ""
    @State private var appeared = false
    @FocusState private var isFocused: Bool

    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Color("MainBG").ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color("AccentCoral").opacity(0.15))
                            .frame(width: 90, height: 90)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color("AccentCoral"))
                    }
                    .scaleEffect(appeared ? 1 : 0.5)
                    .opacity(appeared ? 1 : 0)

                    Text("Welcome to PulseCor 💙")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color("MainText"))
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)

                    Text("Before we begin, let's get familiar with each other. What would you like to be called?")
                        .font(.system(size: 15))
                        .foregroundColor(Color("MainText").opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                }

                VStack(spacing: 16) {
                    TextField("Your name or nickname", text: $name)
                        .font(.system(size: 17))
                        .foregroundColor(Color("MainText"))
                        .padding(16)
                        .background(Color("CardBG"))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(isFocused ? Color("AccentCoral") : Color("AccentCoral").opacity(0.3), lineWidth: 1.5))
                        .focused($isFocused)
                        .submitLabel(.go)
                        .onSubmit { if isValid { saveName() } }
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)

                    Button(action: { if isValid { saveName() } }) {
                        Text("Let's go →")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? Color("AccentCoral") : Color("MainText").opacity(0.2))
                            .cornerRadius(14)
                            .padding(.horizontal, 24)
                    }
                    .disabled(!isValid)
                    .animation(.spring(response: 0.3), value: isValid)
                    .opacity(appeared ? 1 : 0)
                }

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) { appeared = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { isFocused = true }
        }
    }

    private func saveName() {
        manager.saveName(name, modelContext: modelContext)
        manager.next()
    }
}


private struct FeatureSlide: View {
    @ObservedObject var manager = OnboardingViewModel.shared
    @State private var appeared = false

    private var step: OnboardingStep { manager.currentStep }
    private var info: OnboardingStepInfo { OnboardingStepInfo.info(for: step) }
    private var isTabStep: Bool {
        switch step {
        case .openCora, .openBrowse, .openHealth: return true
        default: return false
        }
    }

    private func tabIcon(for step: OnboardingStep) -> String {
        switch step {
        case .openCora: return "bubble.left.and.text.bubble.right"
        case .openBrowse: return "heart.text.clipboard"
        case .openHealth: return "figure.walk"
        default: return "arrow.right"
        }
    }

    private func tabButtonLabel(for step: OnboardingStep) -> String {
        switch step {
        case .openCora: return "Go to Cora →"
        case .openBrowse: return "Go to Browse →"
        case .openHealth: return "Go to My Health →"
        default: return "Continue →"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack {
                Spacer()

                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color("MainText").opacity(0.2))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                    ZStack {
                        Circle()
                            .fill(Color("AccentCoral").opacity(0.12))
                            .frame(width: 64, height: 64)
                        Image(systemName: info.icon)
                            .font(.system(size: 28))
                            .foregroundColor(Color("AccentCoral"))
                    }
                    .padding(.bottom, 16)

                    HStack(spacing: 5) {
                        ForEach(1..<OnboardingStep.complete.rawValue, id: \.self) { i in
                            Capsule()
                                .fill(i <= step.rawValue ? Color("AccentCoral") : Color("MainText").opacity(0.15))
                                .frame(width: i == step.rawValue ? 16 : 6, height: 6)
                                .animation(.spring(response: 0.3), value: step.rawValue)
                        }
                    }
                    .padding(.bottom, 8)

                    VStack(spacing: 8) {
                        Text(info.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("MainText"))
                            .multilineTextAlignment(.center)

                        Text(info.body)
                            .font(.system(size: 14))
                            .foregroundColor(Color("MainText").opacity(0.65))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // Tab switch button, triggers navigation and advances step after delay
                    if isTabStep {
                        VStack(spacing: 12) {
                            Button(action: {
                                manager.isTransitioning = true

                                DispatchQueue.main.async {
                                    switch step {
                                    case .openCora:
                                        NavigationManager.shared.selectedTab = .cora
                                    case .openBrowse:
                                        NavigationManager.shared.selectedTab = .browse
                                    case .openHealth:
                                        NavigationManager.shared.selectedTab = .health
                                    default: break
                                    }
                                }

                                let delay: Double = (step == .openHealth) ? 1.2 : 0.5
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    manager.isTransitioning = false
                                    manager.nextWithoutAnimation()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: tabIcon(for: step))
                                        .font(.system(size: 15))
                                    Text(tabButtonLabel(for: step))
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color("AccentCoral"))
                                .cornerRadius(14)
                            }
                            .padding(.horizontal, 24)

                            Button("Skip tutorial") { manager.skip() }
                                .font(.system(size: 13))
                                .foregroundColor(Color("MainText").opacity(0.35))
                                .padding(.bottom, 8)
                        }
                    }
                    // Standard navigation buttons for non-tab steps
                    if !isTabStep {
                        HStack(spacing: 12) {
                            if step.rawValue > 1 {
                                Button(action: { manager.backWithoutAnimation() }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color("AccentCoral"))
                                        .frame(width: 48, height: 48)
                                        .background(Color("AccentCoral").opacity(0.12))
                                        .cornerRadius(14)
                                }
                            }

                            Button(action: { manager.nextWithoutAnimation() }) {
                                Text("Next →")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color("AccentCoral"))
                                    .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }

                    if !isTabStep {
                        Button("Skip tutorial") { manager.skip() }
                            .font(.system(size: 13))
                            .foregroundColor(Color("MainText").opacity(0.35))
                            .padding(.vertical, 12)
                            .padding(.bottom, 8)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color("MainBG"))
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.15), radius: 20, y: -4)
                .offset(y: appeared ? 0 : 300)
                .allowsHitTesting(true)
            }
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(true)
        }
        .allowsHitTesting(true)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) { appeared = true }
        }
    }
}

struct OnboardingStepInfo {
    let icon: String
    let title: String
    let body: String

    static func info(for step: OnboardingStep) -> OnboardingStepInfo {
        switch step {
        case .dashboardCalendar:
            return OnboardingStepInfo(icon: "calendar", title: "Your weekly calendar", body: "Tap any day to see your check-in history and any medications logged. Your health journey, one day at a time.")
        case .dashboardStreak:
            return OnboardingStepInfo(icon: "flame.fill", title: "Weekly check-ins & streak", body: "Track how many days you've checked in this week and keep your streak alive. Consistency is everything.")
        case .openSettings:
            return OnboardingStepInfo(icon: "person.circle.fill", title: "Let's set up your profile", body: "Tap Open Settings to personalise your name, appearance, health sync, and notifications before you get started.")
        case .settingsName:
            return OnboardingStepInfo(icon: "pencil", title: "Your profile", body: "You can update your name or nickname here at any time from Settings.")
        case .settingsBadges:
            return OnboardingStepInfo(icon: "rosette", title: "Streak badges", body: "Earn badges as your streak grows — from 7 days all the way to a full year. Keep checking in to unlock them all.")
        case .settingsAppearance:
            return OnboardingStepInfo(icon: "paintbrush.fill", title: "Light or dark?", body: "Choose the look that works best for you. PulseCor looks great either way.")
        case .settingsHealth:
            return OnboardingStepInfo(icon: "heart.circle.fill", title: "Apple Health sync", body: "Connect your Apple Health data to see steps, heart rate, and HRV alongside your check-ins on the My Health tab.")
        case .settingsNotifications:
            return OnboardingStepInfo(icon: "bell.fill", title: "Stay on track", body: "Three notification types keep you consistent — a daily check-in reminder, your Sunday reflection alert, and a gentle nudge if you haven't checked in for 2 days.")
        case .settingsMedication:
            return OnboardingStepInfo(icon: "pill.fill", title: "Medication reminders", body: "Add any medications you take and PulseCor will remind you at the times you choose.")
        case .openCora:
            return OnboardingStepInfo(icon: "bubble.left.and.text.bubble.right", title: "Meet Cora", body: "Tap the Cora tab below to meet your daily check-in companion.")
        case .coraCheckIn:
            return OnboardingStepInfo(icon: "checkmark.circle.fill", title: "Daily check-in", body: "Each day, Cora guides you through a short check-in covering sleep, hydration, stress, energy, and activity. It takes under 2 minutes.")
        case .coraCard:
            return OnboardingStepInfo(icon: "lightbulb.fill", title: "Tips & insights", body: "Come back here daily. On most days Cora shares a wellness tip. On Tuesdays, Fridays, and Sundays Cora will surface real insights drawn from your own data.")
        case .openBrowse:
            return OnboardingStepInfo(icon: "heart.text.clipboard", title: "Explore health content", body: "Tap the Browse tab below to discover articles tailored to your health.")
        case .browseCategories:
            return OnboardingStepInfo(icon: "square.grid.2x2.fill", title: "Your health topics", body: "Cardiovascular health, sleep, and general wellness — three pillars of holistic health, all in one place.")
        case .browseArticles:
            return OnboardingStepInfo(icon: "doc.richtext.fill", title: "Tailored articles", body: "Evidence-based articles written to help you understand and improve your health.")
        case .openHealth:
            return OnboardingStepInfo(icon: "figure.walk", title: "Your health data", body: "Tap the My Health tab below to see all your health metrics in one place.")
        case .healthView:
            return OnboardingStepInfo(icon: "waveform.path.ecg", title: "All your data, one place", body: "Steps, heart rate, resting HR, and HRV — read directly from Apple Health and displayed here for you to review at a glance.")
        default:
            return OnboardingStepInfo(icon: "heart.fill", title: "", body: "")
        }
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private struct OnboardingCompleteSlide: View {
    @ObservedObject var manager = OnboardingViewModel.shared
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color("MainBG").ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color("AccentCoral").opacity(0.15))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 54))
                        .foregroundColor(Color("AccentCoral"))
                }
                .scaleEffect(appeared ? 1 : 0.4)
                .opacity(appeared ? 1 : 0)

                VStack(spacing: 12) {
                    Text("You're all set! 💙")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color("MainText"))

                    Text("PulseCor is ready for you. Check in with Cora every day, keep your streak going, and come back each Sunday for your weekly reflection.")
                        .font(.system(size: 15))
                        .foregroundColor(Color("MainText").opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 32)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                Spacer()

                Button(action: { manager.complete() }) {
                    Text("Start your journey →")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("AccentCoral"))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) { appeared = true }
        }
    }
}
