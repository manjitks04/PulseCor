//
//  DashboardView.swift
//  PulseCor
//
//main home view
//

import SwiftUI
import SwiftData

struct DashboardView: View {
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
                                                    .fill(day.isCurrentDay ? Color(red: 60/255, green: 86/255, blue: 120/255).opacity(1.5) : Color.clear)
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
                                colors: [Color(red: 255/255, green: 107/255, blue: 107/255), Color(red: 232/255, green: 93/255, blue: 117/255).opacity(0.65)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Other home content
                        Text("Other dashboard content...")
                            .padding()
                    }
                }
                .background(Color(red: 247/255, green: 249/255, blue: 252/255))
                .navigationTitle("Hi there, \(users.first?.name ?? "Partner")👋")
            }
            .task {
                // If the database is empty, create a temporary test user
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
