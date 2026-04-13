//
//  HeroCheckInCard.swift
//  PulseCor
//
//  Receives hasCheckedInToday as a parameter
//  The parent View (ChatView) provides the value via @Query at screen level.

import SwiftUI

enum CheckInDestination: Hashable {
    case conversation
    case alreadyCheckedIn
}

struct HeroCheckInCard: View {
    let userName: String
    let hasCheckedInToday: Bool

    var body: some View {
        ZStack(alignment: .leading) {

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hi there, \(userName)")
                        .font(.appHeroCardTitle)
                        .foregroundColor(.white)
                    Text("Ready to check in with Cora?")
                        .font(.appTitle2Semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 45)
                .padding(.leading, 20)

                NavigationLink(value: hasCheckedInToday ? CheckInDestination.alreadyCheckedIn : .conversation) {
                    Text("Let's go!")
                        .font(.appSubtitleSemibold)
                        .foregroundColor(Color("AccentCoral"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("CardBG"))
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 180)
        .background(
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [Color("AccentCoral"), Color("AccentPink")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(LinearGradient(
                        colors: [Color("AccentCoral").opacity(0.8), Color("AccentPink").opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 280, height: 280)
                    .offset(x: -40, y: -20)
                    .blur(radius: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
        )
        .cornerRadius(24)
        .padding(.horizontal, 20)
        .navigationDestination(for: CheckInDestination.self) { dest in
            switch dest {
            case .conversation:     ConversationView()
            case .alreadyCheckedIn: AlreadyCheckedInView()
            }
        }
    }
}
