//
//  MedicationViewModel.swift
//  PulseCor
//
import Foundation
import SwiftData
import Combine

@MainActor
class MedicationViewModel: ObservableObject {

    @Published var medications: [Medication] = []
    @Published var errorMessage: String?

    private var modelContext: ModelContext?
    private let notificationService: NotificationService

    init() {
        self.notificationService = NotificationService.shared
    }

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        loadMedications()
    }

    func loadMedications() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<Medication>(predicate: #Predicate { $0.isActive == true })
        medications = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addMedication(name: String, dosage: String, frequency: String, reminderTimes: [String]) {
        guard let modelContext else { return }
        let medication = Medication(userId: 1, name: name, dosage: dosage, frequency: frequency, reminderTimes: reminderTimes)
        modelContext.insert(medication)
        do {
            try modelContext.save()
            notificationService.scheduleMedicationReminders(
                medicationId: medication.localId.uuidString,
                medicationName: name, dosage: dosage, times: reminderTimes
            )
            loadMedications()
        } catch {
            errorMessage = "Failed to add medication"
            print("MedicationViewModel addMedication error: \(error)")
        }
    }

    func deleteMedication(_ medication: Medication) {
        guard let modelContext else { return }
        notificationService.cancelMedicationNotifications(medicationId: medication.localId.uuidString)
        medication.isActive = false
        do {
            try modelContext.save()
            loadMedications()
        } catch {
            errorMessage = "Failed to delete medication"
            print("MedicationViewModel deleteMedication error: \(error)")
        }
    }

    func updateMedication(_ medication: Medication, name: String, dosage: String, frequency: String, reminderTimes: [String]) {
        guard let modelContext else { return }
        notificationService.cancelMedicationNotifications(medicationId: medication.localId.uuidString)
        medication.name = name
        medication.dosage = dosage
        medication.frequency = frequency
        medication.reminderTimes = reminderTimes
        do {
            try modelContext.save()
            if !reminderTimes.isEmpty {
                notificationService.scheduleMedicationReminders(
                    medicationId: medication.localId.uuidString,
                    medicationName: name, dosage: dosage, times: reminderTimes
                )
            }
            loadMedications()
        } catch {
            errorMessage = "Failed to update medication"
            print("MedicationViewModel updateMedication error: \(error)")
        }
    }

    func logMedicationAction(medication: Medication, status: MedicationStatus, scheduledTime: String) {
        guard let modelContext else { return }
        let log = MedicationLog(
            medicationLocalId: medication.localId,
            medicationName: medication.name,
            medicationDosage: medication.dosage,
            status: status,
            scheduledTime: scheduledTime
        )
        modelContext.insert(log)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to log medication status"
            print("MedicationViewModel logMedicationAction error: \(error)")
        }
    }
}
