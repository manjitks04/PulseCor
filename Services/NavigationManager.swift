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

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    @Published var selectedTab: AppTab = .home
    var pendingTab: AppTab? = nil
    private init() {}
}
