//
//  PulseCorApp.swift
//  PulseCor
//
//  Created by Manjit Somal on 03/10/2025.
//

import SwiftUI
import SwiftData

@main
struct PulseCorApp: App {
        init() {
            _ = NotificationService.shared
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [User.self, StepEntry.self, HeartRateEntry.self, RestingHeartRateEntry.self, HRVEntry.self])
    }
}
