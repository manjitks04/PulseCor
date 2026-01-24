//
//  BrowseView.swift
//  PulseCor
//
//used for articles / educational content

import SwiftUI

struct BrowseView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Daily Pulse")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("educational content will go here")
            }
            .navigationTitle("Dashboard")
        }
    }
}
