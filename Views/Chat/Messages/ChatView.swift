//
//  ChatView.swift
//  PulseCor
//
//cora chat features

import SwiftUI
import SwiftData
import Charts

struct ChatView: View {
    @State private var currentStreak: Int = 0
    @State private var weeklyCount: Int = 0
    @State private var last30DaysData: [DailyCheckIn] = []
    @Query private var users: [User]
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 24) {
                        HeroCheckInCard(userName: users.first?.name ?? "there")
                            .padding(.top, 15)
                        
                        DailyStreakTracker(currentDay: currentStreak)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 75)
                    
                    
                    if let currentUser = users.first {
                        ProfileButton(user: currentUser)
                            .padding(.trailing, 16)
                            .padding(.top, 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("MainBG"))
            .onAppear(){
                loadData()
            }
            .refreshable {
                loadData()
            }
        }
    }

    
    private func loadData() {
        do {
            let user = try DatabaseService.shared.getUser(userId: 1)
            currentStreak = user?.currentStreak ?? 0
            weeklyCount = try DatabaseService.shared.getWeeklyCount(userId: 1)
            last30DaysData = try DatabaseService.shared.getLast30DaysCheckIns(userId: 1)
        } catch {
            print("Failed to load data: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, configurations: config)
    
    let sampleUser = User(name: "Preview User", currentStreak: 5, longestStreak: 10)
    container.mainContext.insert(sampleUser)
    
    return ChatView()
        .modelContainer(container)
}
