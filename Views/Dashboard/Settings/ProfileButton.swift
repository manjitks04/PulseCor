//
//  ProfileButton.swift
//  PulseCor
//
import SwiftUI

struct ProfileButton: View {
    @Bindable var user: User
    @State private var showingSettings = false
    
    var body: some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "person.fill")
                .foregroundColor(.gray)
                .font(.appSubtitle)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color("LightGreen")))
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ProfileButton(user: User(name: "Test User"))
}
