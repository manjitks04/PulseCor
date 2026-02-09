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
                        
                        ThirtyDayProgress(data: last30DaysData)
                        
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
        .onAppear {
            loadData()
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

struct HeroCheckInCard: View {
    let userName: String
    
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
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hi there,👋")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Ready to check in?")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
                .padding(.top, 24)
                .padding(.leading, 20)
                
                Spacer()
                
                NavigationLink(destination: ConversationView()) {
                    Text("Let's go!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("AccentCoral"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .frame(height: 240)
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
    }
}

struct DailyStreakTracker: View {
    let currentDay: Int
    let rewards = [5, 5, 10, 10, 15, 15, 25]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily check in")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("MainText"))
                    
                    Text("Achieve a 7 day streak to unlock a special badge!")
                        .font(.subheadline)
                        .foregroundColor(Color("MainText").opacity(0.7))
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    DayCard(
                        day: day,
                        reward: rewards[day - 1],
                        isCompleted: day <= currentDay,
                        isCurrent: day == currentDay
                    )
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AccentCoral"), Color("AccentPink")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(min(currentDay, 7)) / 7, height: 4)
                }
                .cornerRadius(2)
            }
            .frame(height: 4)
            .padding(.horizontal, 4)
            
            HStack {
                HStack(spacing: 6) {
                    Text("Current streak: \(currentDay) day\(currentDay != 1 ? "s" : "")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("MainText"))
                }
                
                Spacer()
                
                let earnedPoints = rewards.prefix(min(currentDay, 7)).reduce(0, +)
                Text("\(earnedPoints)/\(rewards.reduce(0, +)) pts")
                    .font(.subheadline)
                    .foregroundColor(Color("MainText").opacity(0.6))
            }
        }
        .padding(20)
        .background(Color("CardBG"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

struct DayCard: View {
    let day: Int
    let reward: Int
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCompleted ?
                          LinearGradient(
                            colors: [Color("AccentCoral"), Color("AccentPink")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) : LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ))
                    .frame(width: 44, height: 44)
                
                if day == 7 {
                    Text(isCompleted ? "👑" : "🎁")
                        .font(.title3)
                } else if isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                } else {
                    Text("\(reward)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .scaleEffect(isCurrent ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: isCurrent)
            
            Text("Day\(day)")
                .font(.caption)
                .fontWeight(isCompleted ? .semibold : .regular)
                .foregroundColor(isCompleted ? Color("MainText") : Color.gray)
        }
    }
}

struct ThirtyDayProgress: View {
    let data: [DailyCheckIn]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("30-Day Progress")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color("MainText"))
            
            if #available(iOS 16.0, *) {
                Chart(data, id: \.id) { item in
                    LineMark(
                        x: .value("Day", item.date),
                        y: .value("Check-ins", item.isComplete ? 1 : 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("AccentCoral"), Color("AccentPink")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    
                    AreaMark(
                        x: .value("Day", item.date),
                        y: .value("Check-ins", item.isComplete ? 1 : 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color("AccentCoral").opacity(0.3),
                                Color("AccentPink").opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 180)
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisValueLabel(format: .dateTime.month().day())
                            .foregroundStyle(Color("MainText").opacity(0.6))
                    }
                }
            } else {
                SimpleFallbackGraph(data: data)
            }
        }
        .padding(20)
        .background(Color("CardBG"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

struct SimpleFallbackGraph: View {
    let data: [DailyCheckIn]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    guard !data.isEmpty else { return }
                    
                    let step = width / CGFloat(max(data.count - 1, 1))
                    
                    for (index, item) in data.enumerated() {
                        let x = CGFloat(index) * step
                        let y = item.isComplete ? height * 0.2 : height * 0.8
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [Color("AccentCoral"), Color("AccentPink")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 3
                )
            }
        }
        .frame(height: 180)
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
