//
//  NavigationManager.swift
//  PulseCor
//
// Global navigatio state coordinator for tab selection
import SwiftUI
import Combine

enum AppTab {
    case home, cora, browse, pulsecor, health
}

// Represents medication reminder notifcation that triggered app launch, used to restore notif contextafter cold launch
struct PendingMedication: Equatable, Identifiable {
    let id: String
    let name: String
    let dosage: String
    let time: String
}

// Centralised navigation state manager
class NavigationManager: ObservableObject {
    static let shared = NavigationManager()

    @Published var selectedTab: AppTab = .home
    @Published var pendingTab: AppTab? = nil // Tab to navigate after completing current flow
    @Published var pendingWeeklyReflection: Bool = false

    // Backs up to UserDefaults whenever set so cold launches can restore it
    @Published var pendingMedication: PendingMedication? = nil {
        didSet {
            if let med = pendingMedication {
                UserDefaults.standard.set(med.id,     forKey: "pendingMedId")
                UserDefaults.standard.set(med.name,   forKey: "pendingMedName")
                UserDefaults.standard.set(med.dosage, forKey: "pendingMedDosage")
                UserDefaults.standard.set(med.time,   forKey: "pendingMedTime")
            } else {
                UserDefaults.standard.removeObject(forKey: "pendingMedId")
                UserDefaults.standard.removeObject(forKey: "pendingMedName")
                UserDefaults.standard.removeObject(forKey: "pendingMedDosage")
                UserDefaults.standard.removeObject(forKey: "pendingMedTime")
            }
        }
    }

    private init() {}

    // Called from DashboardView.onAppear & restores medication from UserDefaults
    func restorePendingMedicationIfNeeded() {
        guard pendingMedication == nil,
              let id     = UserDefaults.standard.string(forKey: "pendingMedId"),
              let name   = UserDefaults.standard.string(forKey: "pendingMedName"),
              let dosage = UserDefaults.standard.string(forKey: "pendingMedDosage"),
              let time   = UserDefaults.standard.string(forKey: "pendingMedTime")
        else { return }

        print("NavigationManager: restoring pendingMedication from UserDefaults — \(name)")
        pendingMedication = PendingMedication(id: id, name: name, dosage: dosage, time: time)
    }
}
