//
//  TermsOfUseView.swift
//  PulseCor
//
//
import SwiftUI

struct TermsOfUseView: View {
    var body: some View {
        ScrollView {
            Text("Terms of Use content TO DO")
                .padding()
        }
        .navigationTitle("Terms of Use")
        .background(Color("MainBG"))
        .toolbarBackground(Color("MainBG"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
