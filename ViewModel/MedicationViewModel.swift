//
//  MedicationViewModel.swift
//  PulseCor
//
//

import Foundation
import Combine

class MedicationViewModel: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var errorMessage: String?
    
    private let databaseService: DatabaseService
    private let notificationService: NotificationService
    
    init(databaseService: DatabaseService = .shared, notificationService: NotificationService = .shared) {
        self.databaseService = databaseService
        self.notificationService = notificationService
        loadMedications()
    }
    
    func loadMedications() {
        do {
            medications = try databaseService.getMedications()
        } catch {
            errorMessage = "Failed to load medications"
            print("Error loading medications: \(error)")
        }
    }
    
    func addMedication(name: String, dosage: String, frequency: String, reminderTimes: [String]) {
        let medication = Medication(
            userId: 1,
            name: name,
            dosage: dosage,
            frequency: frequency,
            reminderTimes: reminderTimes,
            isActive: true
        )
        
        do {
            let medicationId = try databaseService.createMedication(medication: medication)
            
            if let times = medication.reminderTimes {
                notificationService.scheduleMedicationReminders(
                    medicationId: Int(medicationId),
                    medicationName: name,
                    dosage: dosage,
                    times: times
                )
            }
            
            loadMedications()
        } catch {
            errorMessage = "Failed to add medication"
            print("Error adding medication: \(error)")
        }
    }
    
    func deleteMedication(medicationId: Int) {
        do {
            try databaseService.deleteMedication(medicationId: medicationId)
            notificationService.cancelMedicationNotifications(medicationId: medicationId)
            loadMedications()
        } catch {
            errorMessage = "Failed to delete medication"
            print("Error deleting medication: \(error)")
        }
    }
    
    func logMedicationAction(medicationId: Int, status: MedicationStatus, scheduledTime: String) {
        do {
            try databaseService.logMedicationStatus(
                medicationId: medicationId,
                status: status,
                scheduledTime: scheduledTime
            )
        } catch {
            errorMessage = "Failed to log medication status"
            print("Error logging medication: \(error)")
        }
    }
    
    func updateMedication(medicationId: Int, name: String, dosage: String, frequency: String, reminderTimes: [String]) {
        do {
            notificationService.cancelMedicationNotifications(medicationId: medicationId)
            
            try databaseService.updateMedication(
                medicationId: medicationId,
                name: name,
                dosage: dosage,
                frequency: frequency,
                reminderTimes: reminderTimes
            )
            
            if !reminderTimes.isEmpty {
                notificationService.scheduleMedicationReminders(
                    medicationId: medicationId,
                    medicationName: name,
                    dosage: dosage,
                    times: reminderTimes
                )
            }
            
            loadMedications()
        } catch {
            errorMessage = "Failed to update medication"
            print("Error updating medication: \(error)")
        }
    }
}
