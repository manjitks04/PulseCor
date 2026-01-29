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
                        // Calendar Section
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
                                
                                Button(action: {
                                    // LATER ADD IN CALENDAR LOGIC
                                }) {
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
                            WeeklyCheckIn(completedDays: viewModel.weeklyCheckInCount)
                            StreakCard(currentStreak: viewModel.currentStreak)
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Hi there, \(users.first?.name ?? "Partner")👋")
            }
            .task {
                // (tsetr)
                if users.isEmpty {
                    let tempUser = User(name: "Test Participant")
                    modelContext.insert(tempUser)
                }
            }
        }
    }

#Preview {
    DashboardView()
}
