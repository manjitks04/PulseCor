//
//  DashboardView.swift
//  PulseCor
//
//main home view
//
import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var hasCheckedInToday = false
    @State private var isCheckingStatus = true
    
    var weekDays: [CalendarDay] {
        WeeklyCalendarHelper.getCurrentWeek()
    }
    
    var monthYear: String {
        WeeklyCalendarHelper.getMonthYear()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Hi there, \(users.first?.name ?? "Partner")👋")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("MainText"))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 55)
                        
                        VStack(spacing: 16) {
                            Text(monthYear)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 0) {
                                ForEach(weekDays) { day in
                                    VStack(spacing: 3) {
                                        Text(day.dayLetter)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white.opacity(1))
                                        
                                        Text("\(day.dayNum)")
                                            .font(.system(size: 15, weight: day.isCurrentDay ? .bold : .regular))
                                            .foregroundColor(.white)
                                            .frame(width: 32, height: 28)
                                            .background(
                                                Circle()
                                                    .fill(day.isCurrentDay ? Color("FillBlue") : Color.clear)
                                            )
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            
                            VStack(spacing: 8) {
                                Text("Ready to check in...?")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                if isCheckingStatus {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    NavigationLink(destination: destinationView()) {
                                        Text("Let's go!")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.pink)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 8)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color("AccentCoral"), Color("AccentPink").opacity(0.65)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        HStack(spacing: 16){
                            WeeklyCheckIn(completedDays: viewModel.weeklyCheckInCount)
                            StreakCard(currentStreak: viewModel.currentStreak)
                        }
                        .padding(.horizontal)
                    }
                    .onAppear {
                        checkTodayStatus()
                    }
                    
                    if let currentUser = users.first {
                        ProfileButton(user: currentUser)
                            .padding(.trailing, 16)
                            .padding(.top, 20)
                    }
                }
            }
            .background(Color("MainBG"))
            .navigationBarHidden(true)
            .task {
                if users.isEmpty {
                    let tempUser = User(name: "Test")
                    modelContext.insert(tempUser)
                }
                
                viewModel.loadDashboardData()
            }
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
        } catch {
            print("Error checking today's status: \(error)")
            hasCheckedInToday = false
            isCheckingStatus = false
        }
    }
}

#Preview("Full Dashboard") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, configurations: config)
    
    let sampleUser = User(
        id: 1,
        name: "Manjit",
        createdAt: Date(),
        lastCheckInDate: Date(),
        currentStreak: 5,
        longestStreak: 12
    )
    container.mainContext.insert(sampleUser)
    
    return DashboardViewPreviewWrapper()
        .modelContainer(container)
}

struct DashboardViewPreviewWrapper: View {
    @Query private var users: [User]
    
    var weekDays: [CalendarDay] {
        WeeklyCalendarHelper.getCurrentWeek()
    }
    
    var monthYear: String {
        WeeklyCalendarHelper.getMonthYear()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Hi there, \(users.first?.name ?? "Partner")👋")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("MainText"))
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 55)
                    
                    VStack(spacing: 16) {
                        Text(monthYear)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 0) {
                            ForEach(weekDays) { day in
                                VStack(spacing: 3) {
                                    Text(day.dayLetter)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(1))
                                    
                                    Text("\(day.dayNum)")
                                        .font(.system(size: 15, weight: day.isCurrentDay ? .bold : .regular))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 28)
                                        .background(
                                            Circle()
                                                .fill(day.isCurrentDay ? Color("FillBlue") : Color.clear)
                                        )
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text("Ready to check in...?")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            NavigationLink(destination: Text("Conversation")) {
                                Text("Let's go!")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.pink)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color("AccentCoral"), Color("AccentPink").opacity(0.65)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    HStack(spacing: 16){
                        WeeklyCheckIn(completedDays: 3)
                        StreakCard(currentStreak: users.first?.currentStreak ?? 0)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color("MainBG"))
            .navigationBarHidden(true)
        }
        .overlay(alignment: .topTrailing) {
            if let currentUser = users.first {
                ProfileButton(user: currentUser)
                    .padding(.trailing, 16)
                    .padding(.top, 20)
            }
        }
    }
}
