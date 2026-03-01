//
//  HeroCheckInCard.swift
//  PulseCor
//
import SwiftUI
import SwiftData

struct HeroCheckInCard: View {
    let userName: String

    @Query private var todaysCheckIns: [DailyCheckIn]

    // Derived from query
    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return todaysCheckIns.contains {
            $0.isComplete && Calendar.current.startOfDay(for: $0.date) == today
        }
    }

    init(userName: String) {
        self.userName = userName
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        _todaysCheckIns = Query(filter: #Predicate<DailyCheckIn> {
            $0.date >= start && $0.date < end
        })
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Circle()
                .fill(LinearGradient(
                    colors: [Color("AccentCoral").opacity(0.8), Color("AccentPink").opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 280, height: 280)
                .offset(x: -40, y: -20)
                .blur(radius: 2)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hi there, \(userName)")
                        .font(.appHeroCardTitle)
                        .foregroundColor(.white)

                    Text("Ready to check in with Cora?")
                        .font(.appTitle2Semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                .padding(.leading, 20)

                NavigationLink(destination: destinationView()) {
                    Text("Let's go!")
                        .font(.appSubtitleSemibold)
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
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(
            colors: [Color("AccentCoral"), Color("AccentPink")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .cornerRadius(24)
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if hasCheckedInToday {
            AlreadyCheckedInView()
        } else {
            ConversationView()
        }
    }
}
