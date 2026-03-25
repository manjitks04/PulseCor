//
//  DashboardViewModel.swift
//  PulseCor
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

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        loadDashboardData()
    }

    func loadDashboardData() {
        checkTodayCheckIn()
    }

    private func checkTodayCheckIn() {
        guard let modelContext else { return }
        let start = Calendar.current.startOfDay(for: Date())
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return }
        let descriptor = FetchDescriptor<DailyCheckIn>(
            predicate: #Predicate { $0.isComplete == true && $0.date >= start && $0.date < end }
        )
        hasCheckedInToday = ((try? modelContext.fetchCount(descriptor)) ?? 0) > 0
    }

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
