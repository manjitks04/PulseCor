//
//  PulseCorApp.swift
//  PulseCor
//
//  Created by Manjit Somal on 03/10/2025.
//
//
//import SwiftUI
//import SwiftData
//
//@main
//struct PulseCorApp: App {
//        init() {
//            _ = NotificationService.shared
//        }
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(NavigationManager.shared)
//        }
//        .modelContainer(for: [User.self, StepEntry.self, HeartRateEntry.self, RestingHeartRateEntry.self, HRVEntry.self])
//    }
//}

import SwiftUI
import SwiftData

@main
struct PulseCorApp: App {

    // Register ALL @Model types here
    let container: ModelContainer = {
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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Seed articles once 
                    ArticleSeeder.seedIfNeeded(in: container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
