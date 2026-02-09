//
//  BrowseView.swift
//  PulseCor
//
//used for articles / educational content

import SwiftUI
import SwiftData

struct BrowseView: View {
    @Query private var users: [User]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 20) {
                        Text("Your Daily Pulse")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color("MainText"))
                            .padding(.top, 55)
                        
                        Text("educational content will go here")
                            .foregroundColor(Color("MainText"))
                        
                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                    if let currentUser = users.first {
                        ProfileButton(user: currentUser)
                            .padding(.trailing, 16)
                            .padding(.top, 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("MainBG"))
            .navigationBarHidden(true)
        }
    }
}
