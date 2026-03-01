//
//  HealthKitManager.swift
//  PulseCor
//
// in-app HealthKit state (auth status, revocation alert).
import SwiftUI
import HealthKit
import SwiftData
import Combine


@MainActor //forces all property updates to run on the main thread — prevents UI crashes from HK's background threads
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    @Published var accessRevoked = false
    @Published var isAuthorized = false
    
    private let service = HealthKitService.shared
    
    private init() {}
    
    func setup(context: ModelContext) {
        Task { [weak self] in
            let (success, _) = await self?.service.requestAuth() ?? (false, nil)
            self?.isAuthorized = success
            if success {
                self?.service.startObserving(context: context)
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
