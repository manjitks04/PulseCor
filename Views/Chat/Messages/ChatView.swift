//
//  ChatView.swift
//  PulseCor
//
//  Cora chat features
//
import SwiftUI
import SwiftData

struct ChatView: View {
    @Query private var users: [User]

    // Fetch completed check-ins from the last 30 days for streak display
    @Query(filter: #Predicate<DailyCheckIn> { $0.isComplete == true },
           sort: \DailyCheckIn.date, order: .reverse)
    private var checkIns: [DailyCheckIn]

    private var currentStreak: Int {
        users.first?.currentStreak ?? 0
    }

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
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, DailyCheckIn.self, configurations: config)

    let sampleUser = User(name: "Preview User", currentStreak: 5, longestStreak: 10)
    container.mainContext.insert(sampleUser)

    return ChatView()
        .modelContainer(container)
}
