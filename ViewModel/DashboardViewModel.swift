//
//  DashboardViewModel.swift
//  PulseCor
//
// Manages dashboard state: today's check-in status and medication logging.
//

import Foundation
import SwiftData
import Combine

@MainActor
class DashboardViewModel: ObservableObject {

    @Published var hasCheckedInToday: Bool = false
    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    init() {}

    // Injects ModelContext and loads initial dashboard state
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        loadDashboardData()
    }

    func loadDashboardData() {
        checkTodayCheckIn()
    }

    // Queries for completed check-in dated today (midnight to midnight)
    private func checkTodayCheckIn() {
        guard let modelContext else { return }
        let start = Calendar.current.startOfDay(for: Date())
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return }
        let descriptor = FetchDescriptor<DailyCheckIn>(
            predicate: #Predicate { $0.isComplete == true && $0.date >= start && $0.date < end }
        )
        hasCheckedInToday = ((try? modelContext.fetchCount(descriptor)) ?? 0) > 0
    }

    // Logs user's response to medication reminder notification, called when user taps Taken/Skipped/Snoozed on medication prompt.
    func logMedicationAction(med: PendingMedication, status: MedicationStatus) {
        guard let modelContext else { return }
        let log = MedicationLog(
            medicationLocalId: UUID(uuidString: med.id) ?? UUID(),
            medicationName: med.name,
            medicationDosage: med.dosage,
            status: status,
            scheduledTime: med.time
        )
        modelContext.insert(log)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to log medication action"
            print("DashboardViewModel logMedicationAction error: \(error)")
        }
    }
}
