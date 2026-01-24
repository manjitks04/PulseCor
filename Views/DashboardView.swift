//
//  DashboardView.swift
//  PulseCor
//
//main home view
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Daily Pulse")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("main homepage here")
            }
            .navigationTitle("Dashboard")
        }
    }
}
