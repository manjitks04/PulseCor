//
//  ProfileButton.swift
//  PulseCor
//
import SwiftUI

struct ProfileButton: View {
    @Bindable var user: User
    
    var body: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "person.fill")
                .foregroundColor(.gray)
                .font(.appSubtitle)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color("LightGreen")))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileButton(user: User(name: "Test User"))
}
