//
//  ChatView.swift
//  PulseCor
//
//  Screen-level @Query for check-in status is acceptable here — ChatView is a tab root,
//  not a reusable component. The result is passed down to HeroCheckInCard as a parameter.

import SwiftUI
import SwiftData

struct ChatView: View {
    @Query private var users: [User]

    @Query(filter: #Predicate<DailyCheckIn> { $0.isComplete == true },
           sort: \DailyCheckIn.date, order: .reverse)
    private var checkIns: [DailyCheckIn]

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
