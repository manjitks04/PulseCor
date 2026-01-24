//
//  ContentView.swift
//  PulseCor
//
//

import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "heart.fill")
                }

            AboutView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            ChatView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            BrowseView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }

        }
        .onAppear {
            HealthKitService.shared.requestAuth { success, error in
                if success {
                    print("HealthKit Authorized")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

