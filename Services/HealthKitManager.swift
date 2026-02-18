//
//  HealthKitManager.swift
//  PulseCor
//
//e in-app HealthKit state (auth status, revocation alert).
import SwiftUI
import HealthKit
import SwiftData
import Combine


@MainActor // no risk of app crashing when trying to update the UI, any UI updates happen on main thread, HK background threads
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    @Published var accessRevoked = false
    @Published var isAuthorized = false
    
    private let service = HealthKitService.shared
    
    private init() {}
    
    func setup(context: ModelContext) {
        service.requestAuth { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.service.startObserving(context: context)
                }
            }
        }
    }
    
    func handleRevocation() {
        accessRevoked = true
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        accessRevoked = false
    }
}
