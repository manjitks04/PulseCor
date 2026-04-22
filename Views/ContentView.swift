//
//  ContentView.swift
//  PulseCor
//
// Root view containing tab navigation and app initialisation logic
// Handles HealthKit setup, notification scheduling, onboarding trigger, and pending tab navigation
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var navManager = NavigationManager.shared

    // Passed as parameters to HealthView to avoid duplicate @Query in View
    @Query(sort: \StepEntry.date, order: .reverse) private var stepEntries: [StepEntry]
    @Query(sort: \HeartRateEntry.date, order: .reverse) private var heartRateEntries: [HeartRateEntry]
    @Query(sort: \RestingHeartRateEntry.date, order: .reverse) private var restingEntries: [RestingHeartRateEntry]
    @Query(sort: \HRVEntry.date, order: .reverse) private var hrvEntries: [HRVEntry]

    var body: some View {
        ZStack {
            TabView(selection: $navManager.selectedTab) {
                DashboardView()
                    .tag(AppTab.home)
                    .tabItem { Label("Home", systemImage: "heart.fill") }

                ChatView()
                    .tag(AppTab.cora)
                    .tabItem { Label("Cora", systemImage: "bubble.left.and.text.bubble.right") }

                BrowseView()
                    .tag(AppTab.browse)
                    .tabItem { Label("Browse", systemImage: "heart.text.clipboard") }

                HealthView(
                    stepEntries: stepEntries,
                    heartRateEntries: heartRateEntries,
                    restingEntries: restingEntries,
                    hrvEntries: hrvEntries
                )
                .tag(AppTab.health)
                .tabItem { Label("My Health", systemImage: "figure.walk") }

                AboutView()
                    .tag(AppTab.pulsecor)
                    .tabItem { Label("PulseCor", systemImage: "checkmark.shield") }
            }
            .environmentObject(navManager)
            .toolbarBackground(Color("MainBG"), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)

            OnboardingLayer()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .task {
            // App launch initialisation sequence:

            //1. healthkit auth
            HealthKitManager.shared.setup(context: modelContext)

            //2. request notif permissions
            let granted = await NotificationService.shared.requestAuthorization()
            if granted {
                NotificationService.shared.scheduleDailyCheckIn(hour: 11, minute: 0, isAM: true)
                NotificationService.shared.scheduleWeeklyReflection(hour: 18, minute: 0, isAM: false)
            }

            //3. handle pnding tab navigation
            if let pending = navManager.pendingTab {
                navManager.selectedTab = pending
                navManager.pendingTab = nil
            }

            //4.start onboarding tut 
            OnboardingViewModel.shared.start()
        }
        .onChange(of: navManager.pendingTab) {
            if let pending = navManager.pendingTab {
                navManager.selectedTab = pending
                navManager.pendingTab = nil
            }
        }
    }
}

private struct OnboardingLayer: View {
    @ObservedObject private var onboarding = OnboardingViewModel.shared

    var body: some View {
        if onboarding.isActive && !onboarding.isTransitioning {
            OnboardingOverlayView()
                .ignoresSafeArea()
                .zIndex(999)
        }
    }
}


#Preview {
    ContentView()
}
