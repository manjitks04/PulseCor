//  PulseCorApp.swift
//  PulseCor
//
// Main app entry point
// Configures SwiftData container, seeds articles, and force-initializes NotificationService singleton


import SwiftUI
import SwiftData

@main
struct PulseCorApp: App {

    //static property so intialised off main thread - prevents any freezing on launch
    //container is shared across entire app via .modelContainer modifier
    static let container: ModelContainer = {
        let schema = Schema([
            User.self,
            DailyCheckIn.self,
            Medication.self,
            MedicationLog.self,
            ChatMessage.self,
            ConversationFlow.self,
            Article.self,
            StepEntry.self,
            HeartRateEntry.self,
            RestingHeartRateEntry.self,
            HRVEntry.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        _ = NotificationService.shared // Force-initialise NotificationService singleton to set UNUserNotificationCenter delegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
            // Seeds articles from .txt files on first launch
            // Background priority prevents blocking main thread during startup
                .task(priority: .background) {
                    ArticleSeeder.seedIfNeeded(in: PulseCorApp.container.mainContext)
                }
                .modelContainer(PulseCorApp.container)
        }
    }
}
