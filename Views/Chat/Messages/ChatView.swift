//
//  ChatView.swift
//  PulseCor
//
//  Screen-level @Query for check-in status, the result is passed down to HeroCheckInCard as a parameter.

import SwiftUI
import SwiftData

struct ChatView: View {
    @Query private var users: [User]

    @Query(filter: #Predicate<DailyCheckIn> { $0.isComplete == true },
           sort: \DailyCheckIn.date, order: .reverse)
    private var checkIns: [DailyCheckIn]

    @StateObject private var cardViewModel = CoraCardViewModel()
    @ObservedObject private var navManager = NavigationManager.shared
    @State private var showingReflection = false

    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return checkIns.first.map {
            Calendar.current.startOfDay(for: $0.date) == today
        } ?? false
    }

    private var currentStreak: Int {
        users.first?.currentStreak ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 24) {
                        HeroCheckInCard(
                            userName: users.first?.name ?? "there",
                            hasCheckedInToday: hasCheckedInToday
                        )
                        .padding(.top, 15)

                        DailyStreakTracker(currentDay: currentStreak)

                        CoraCardView(
                            cardType: cardViewModel.cardType,
                            onViewReflection: { showingReflection = true }
                        )

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
            .onAppear {
                cardViewModel.load(checkIns: checkIns)
            }
            .onChange(of: checkIns.count) {
                cardViewModel.load(checkIns: checkIns)
            }
            .onReceive(navManager.$pendingWeeklyReflection) { pending in
                if pending {
                    showingReflection = true
                    NavigationManager.shared.pendingWeeklyReflection = false
                }
            }
            .fullScreenCover(isPresented: $showingReflection) {
                WeeklyReflectionView(userStreak: currentStreak)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, DailyCheckIn.self, configurations: config)
    let sampleUser = User(name: "Preview User", currentStreak: 5, longestStreak: 10)
    container.mainContext.insert(sampleUser)
    return ChatView().modelContainer(container)
}
