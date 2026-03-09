//
//  ProfileButton.swift
//  PulseCor
//
import SwiftUI

struct ProfileButton: View {
    @Bindable var user: User

    var body: some View {
        NavigationLink(destination: SettingsView()) {
            Image(user.profilePic)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileButton(user: User(name: "Test User"))
}
