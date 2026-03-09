import SwiftUI
import SwiftData

@main
struct PulseCorApp: App {

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

    init() {
        _ = NotificationService.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    ArticleSeeder.seedIfNeeded(in: container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
