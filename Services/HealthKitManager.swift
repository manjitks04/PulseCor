//
//  HealthKitManager.swift
//  PulseCor
//
// In-app HealthKit state (auth status, revocation alert)
// Singleton wrapper around HealthKitService; provides @Published properties for UI observation
//

import SwiftUI
import HealthKit
import SwiftData
import Combine


@MainActor // forces all property updates to run on the main thread — prevents UI crashes from HK's background threads
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    @Published var accessRevoked = false
    @Published var isAuthorized = false
    
    private let service = HealthKitService.shared
    
    private init() {}
    
    // Requests HealthKit auth, if granted data sync begins, called during onboarding flow
    func setup(context: ModelContext) {
        Task { [weak self] in
            let (success, _) = await self?.service.requestAuth() ?? (false, nil)
            self?.isAuthorized = success
            if success {
                self?.service.startObserving(context: context)
            }
        }
    }
    
    // Called by HealthKitService when it detects authorization loss
    func handleRevocation() {
        accessRevoked = true
    }
}
