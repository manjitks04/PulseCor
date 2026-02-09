//
//  ContentView.swift
//  PulseCor
//
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "heart.fill")
                }

            ChatView()
                .tabItem {
                    Label("Cora", systemImage: "bubble.left.and.text.bubble.right")
                }

            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "heart.text.clipboard")
                }
            
            AboutView()
                .tabItem {
                    Label("PulseCor", systemImage: "checkmark.shield")
                }

        }
        .background(Color("MainBG"))
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            HealthKitService.shared.requestAuth { success, error in
                if success {
                    print("HealthKit Authorized")
                }
            }
        }
        // .onAppear {
        // NotificationService().requestAuthorization()
        //}
    }
}

#Preview {
    ContentView()
}
