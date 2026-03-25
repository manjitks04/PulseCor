//
//  SettingsViewModel.swift
//  PulseCor
//
//  Responsibilities: Manages user profile updates and health data persistence operations
//  triggered from SettingsView. Owns all modelContext operations that SettingsView requires.
//  ModelContext: Injected via setContext(_:)

import Foundation
import Combine
import SwiftData

@MainActor
class SettingsViewModel: ObservableObject {

    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    init() {}

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func saveName(_ name: String) {
        guard let modelContext, !name.isEmpty else { return }
        var descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == 1 })
        descriptor.fetchLimit = 1
        guard let user = try? modelContext.fetch(descriptor).first else { return }
        user.name = name
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save name"
            print("SettingsViewModel saveName error: \(error)")
        }
    }

    func clearHealthData() {
        guard let modelContext else { return }
        do {
            try modelContext.delete(model: StepEntry.self)
            try modelContext.delete(model: HeartRateEntry.self)
            try modelContext.delete(model: RestingHeartRateEntry.self)
            try modelContext.delete(model: HRVEntry.self)
        } catch {
            errorMessage = "Failed to clear health data"
            print("SettingsViewModel clearHealthData error: \(error)")
        }
    }
}
