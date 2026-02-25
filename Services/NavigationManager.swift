//
//  NavigationManager.swift
//  PulseCor
//
//
import SwiftUI
import Combine

enum AppTab {
    case home, cora, browse, pulsecor, health
}

struct PendingMedication: Equatable {
    let id: Int
    let name: String
    let dosage: String
    let time: String
}

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    @Published var selectedTab: AppTab = .home
    @Published var pendingMedication: PendingMedication? = nil
    @Published var pendingTab: AppTab? = nil
    private init() {}
}
