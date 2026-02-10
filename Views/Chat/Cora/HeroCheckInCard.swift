//
//  HeroCheckInCard.swift
//  PulseCor
//
//
import SwiftUI
import SwiftData

struct HeroCheckInCard: View {
    let userName: String
    @State private var hasCheckedInToday = false
    @State private var isCheckingStatus = true
    
    var body: some View {
        ZStack(alignment: .leading) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AccentCoral").opacity(0.8),
                            Color("AccentPink").opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 280)
                .offset(x: -40, y: -20)
                .blur(radius: 2)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hi there, \(userName)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Ready to check in with Cora?")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                
                if isCheckingStatus {
                    ProgressView()
                        .tint(.white)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                } else {
                    NavigationLink(destination: destinationView()) {
                        Text("Let's go!")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("AccentCoral"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("CardBG"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color("AccentCoral"),
                    Color("AccentPink")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .onAppear {
            checkTodayStatus()
        }
    }
    
    @ViewBuilder
    private func destinationView() -> some View {
        if hasCheckedInToday {
            AlreadyCheckedInView()
        } else {
            ConversationView()
        }
    }
    
    private func checkTodayStatus() {
        do {
            hasCheckedInToday = try DatabaseService.shared.hasCheckedInToday()
            isCheckingStatus = false
//            hasCheckedInToday = false
//            isCheckingStatus = false
        } catch {
            print("Error checking today's status: \(error)")
            hasCheckedInToday = false
            isCheckingStatus = false
        }
    }
}
