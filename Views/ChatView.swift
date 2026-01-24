//
//  ChatView.swift
//  PulseCor
//
//cora chat features

import SwiftUI

struct ChatView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Daily Pulse")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("chatfunction will go here")
            }
            .navigationTitle("Dashboard")
        }
    }
}
