//
//  ContentView.swift
//  PulseCor
//
import SwiftUI
import SwiftData
import HealthKit

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var healthManager = HealthKitManager.shared
    @ObservedObject private var navManager = NavigationManager.shared

    var body: some View {
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

            HealthView()
                .tag(AppTab.health)
                .tabItem { Label("My Health", systemImage: "figure.walk") }

            AboutView()
                .tag(AppTab.pulsecor)
                .tabItem { Label("PulseCor", systemImage: "checkmark.shield") }
        }
        .environmentObject(navManager)
        .toolbarBackground(Color("MainBG"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .task {
            healthManager.setup(context: modelContext)
            let granted = await NotificationService.shared.requestAuthorization()
            
            if granted {
                NotificationService.shared.scheduleDailyCheckIn(hour: 11, minute: 0, isAM: true)
                NotificationService.shared.scheduleWeeklyReflection(hour: 18, minute: 0, isAM: false)
            }
            
            if let pending = navManager.pendingTab {
                navManager.selectedTab = pending
                navManager.pendingTab = nil
            }
        }
        .onChange(of: navManager.pendingTab) {
            if let pending = navManager.pendingTab {
                navManager.selectedTab = pending
                navManager.pendingTab = nil
            }
        }
        .alert("Health Access Disconnected", isPresented: $healthManager.accessRevoked) {
            Button("Open Settings") { healthManager.openSettings() }
            Button("Cancel", role: .cancel) { healthManager.accessRevoked = false }
        } message: {
            Text("PulseCor no longer has access to your Health data. To reconnect, please re-enable access in your iPhone Settings.")
        }
    }
}

#Preview {
    ContentView()
}
