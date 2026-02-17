//
//  AccessibilityStatementView.swift
//  PulseCor
//
//
import SwiftUI

struct AccessibilityStatementView: View {
    var body: some View {
        ScrollView {
            Text("Accessibility Statement TO DO ")
        }
        .background(Color("MainBG"))
        .navigationTitle("Accessibility Statement")
        .toolbarBackground(Color("MainBG"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
