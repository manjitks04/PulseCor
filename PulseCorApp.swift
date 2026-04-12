//  PulseCorApp.swift
//  PulseCor
//

import SwiftUI
import SwiftData

@main
struct PulseCorApp: App {

    //static property so intialised off main thread - prevents any freezing on launch
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
        _ = NotificationService.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task(priority: .background) {
                    ArticleSeeder.seedIfNeeded(in: PulseCorApp.container.mainContext)
                }
                .modelContainer(PulseCorApp.container)
        }
    }
}
