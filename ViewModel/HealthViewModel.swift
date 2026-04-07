//
//  HealthViewModel.swift
//  PulseCor
//
//  Responsibilities: Manages health data sync logic, sync timing decisions, and loading state.
//  Delegates HealthKit auth and data fetching to HealthKitService and HealthKitManager.
//  ModelContext: Injected via setContext(_:)
//  Services: HealthKitService (data fetching), HealthKitManager (auth state)

import Foundation
import Combine
import SwiftData

@MainActor
class HealthViewModel: ObservableObject {

    @Published var isSyncing: Bool = false
    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    init() {}

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func syncIfNeeded(healthSyncEnabled: Bool, lastSyncDate: Date?) async {
        guard healthSyncEnabled, shouldSync(lastSyncDate: lastSyncDate) else { return }
        guard let modelContext else { return }

        isSyncing = true
        let (success, _) = await HealthKitService.shared.requestAuth()
        guard success else {
            isSyncing = false
            return
        }
        await HealthKitService.shared.syncWeeklySummary(context: modelContext)
        try? await Task.sleep(for: .seconds(2))
        isSyncing = false
    }

    private func shouldSync(lastSyncDate: Date?) -> Bool {
        guard let lastSync = lastSyncDate else { return true }
        return Date().timeIntervalSince(lastSync) > 3600
    }
}
