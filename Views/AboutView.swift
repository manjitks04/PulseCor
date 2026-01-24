//
//  AboutView.swift
//  PulseCor
//
//  pulseCor disclaimers
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Daily Pulse")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("PulseCor disclaimers will go here")
            }
            .navigationTitle("Dashboard")
        }
    }
}
