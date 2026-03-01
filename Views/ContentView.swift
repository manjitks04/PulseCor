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
            _ = await NotificationService.shared.requestAuthorization()

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
        .onChange(of: navManager.pendingMedication) { _, newValue in
            if newValue != nil {
                navManager.selectedTab = .home
            }
        }
        // Medication sheet lives here — always in the hierarchy, never affected by tab switches
        .sheet(item: $navManager.pendingMedication) { _ in
            MedicationAlertSheet(
                medicationName: navManager.pendingMedication?.name ?? "",
                dosage: navManager.pendingMedication?.dosage ?? "",
                scheduledTime: navManager.pendingMedication?.time ?? "",
                onTaken: { logPendingMedication(status: .taken) },
                onSkip: { logPendingMedication(status: .skipped) },
                onSnooze: {
                    if let med = navManager.pendingMedication {
                        NotificationService.shared.snoozeMedicationReminder(
                            medicationId: med.id,
                            medicationName: med.name,
                            dosage: med.dosage
                        )
                        logPendingMedication(status: .snoozed)
                    }
                },
                onDismiss: {
                    navManager.pendingMedication = nil
                }
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(true)
        }
        .alert("Health Access Disconnected", isPresented: $healthManager.accessRevoked) {
            Button("Open Settings") { healthManager.openSettings() }
            Button("Cancel", role: .cancel) { healthManager.accessRevoked = false }
        } message: {
            Text("PulseCor no longer has access to your Health data. To reconnect, please re-enable access in your iPhone Settings.")
        }
    }

    private func logPendingMedication(status: MedicationStatus) {
        if let med = navManager.pendingMedication {
            let log = MedicationLog(
                medicationLocalId: UUID(uuidString: med.id) ?? UUID(),
                medicationName: med.name,
                medicationDosage: med.dosage,
                status: status,
                scheduledTime: med.time
            )
            modelContext.insert(log)
            try? modelContext.save()
        }
        navManager.pendingMedication = nil
    }
}

#Preview {
    ContentView()
}
