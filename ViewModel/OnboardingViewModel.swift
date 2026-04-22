//
//  OnboardingViewModel.swift
//  PulseCor
//
// Manages first-time onboarding tutorial flow with step-by-step UI overlays


import SwiftUI
import SwiftData
import Combine

// Each step corresponds to a specific spotlight overlay or instruction card
enum OnboardingStep: Int, CaseIterable {
    case name = 0
    case dashboardCalendar
    case dashboardStreak
    case openSettings
    case settingsName
    case settingsBadges
    case settingsAppearance
    case settingsHealth
    case settingsNotifications
    case settingsMedication
    case openCora
    case coraCheckIn
    case coraCard
    case openBrowse
    case browseCategories
    case browseArticles
    case openHealth
    case healthView
    case complete
}

@MainActor
class OnboardingViewModel: ObservableObject {
    static let shared = OnboardingViewModel()

    // Persists onboarding completion status to UserDefaults
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Published var currentStep: OnboardingStep = .name
    @Published var isActive: Bool = false // Set to false during transitions to prevent UI flicker
    @Published var isTransitioning: Bool = false     // True during step transitions to temporarily hide overlay.
    @Published var shouldOpenSettings: Bool = false

    private init() {}

    func start() {
        guard !hasCompletedOnboarding else { return }
        currentStep = .name
        isActive = true
    }

    // Advances to next onboarding step with spring animation
    func next() {
        let raw = currentStep.rawValue
        if raw < OnboardingStep.complete.rawValue {
            let next = OnboardingStep(rawValue: raw + 1) ?? .complete
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep = next
            }
            shouldOpenSettings = isSettingsStep(next)
        } else {
            complete()
        }
    }

    func back() {
        let raw = currentStep.rawValue
        guard raw > 1 else { return }
        let prev = OnboardingStep(rawValue: raw - 1) ?? .name
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            currentStep = prev
        }
        shouldOpenSettings = isSettingsStep(prev)
    }

    func skip() { complete() }     // Skips onboarding entirely -- immediately calls complete()

    func backWithoutAnimation() {
        let raw = currentStep.rawValue
        guard raw > 1 else { return }
        currentStep = OnboardingStep(rawValue: raw - 1) ?? .name
        shouldOpenSettings = isSettingsStep(currentStep)
    }

    func nextWithoutAnimation() {
        let raw = currentStep.rawValue
        if raw < OnboardingStep.complete.rawValue {
            currentStep = OnboardingStep(rawValue: raw + 1) ?? .complete
            shouldOpenSettings = isSettingsStep(currentStep)
        } else {
            complete()
        }
    }

    // Handles user tapping tabs during tutorial
    func handleTabTap(_ tab: AppTab) {
        switch currentStep {
        case .openCora where tab == .cora: next()
        case .openBrowse where tab == .browse: next()
        case .openHealth where tab == .health: next()
        default: break
        }
    }

    // Resets to Home tab and persists completion to UserDefaults
    func complete() {
        withAnimation(.easeOut) {
            isActive = false
        }
        shouldOpenSettings = false
        NavigationManager.shared.selectedTab = .home
        hasCompletedOnboarding = true
    }

    func isSettingsStep(_ step: OnboardingStep? = nil) -> Bool {
        let s = step ?? currentStep
        switch s {
        case .settingsName, .settingsBadges, .settingsAppearance,
             .settingsHealth, .settingsNotifications, .settingsMedication:
            return true
        default: return false
        }
    }
    
    // True if current step requires user to switch tabs.
    var isTabSwitchStep: Bool {
        switch currentStep {
        case .openCora, .openBrowse, .openHealth: return true
        default: return false
        }
    }

    // Saves user's name to User model during onboarding name entry step
    func saveName(_ name: String, modelContext: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            user.name = trimmed
            try? modelContext.save()
        }
    }
}
