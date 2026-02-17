//
//  PrivacyPolicyView.swift
//  PulseCor
//
//
import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy TO DO")
                .padding()
        }
        .navigationTitle("Privacy Policy")
        .background(Color("MainBG"))
        .toolbarBackground(Color("MainBG"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
