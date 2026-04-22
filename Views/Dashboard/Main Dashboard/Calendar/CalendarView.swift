//
//  CalendarView.swift
//  PulseCor
//
//  Full calendar grid view showing all months from November 2025 to present.
//  Each day displays check-in and medication status indicators.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CalendarViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Day of week headers for calendar grid (Monday-first week)
    private let dayHeaders = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 24) {
                        if viewModel.isLoading {
                            ProgressView().padding(.top, 60)
                        } else {
                            // Renders one MonthGroupView per month from app start to present
                            ForEach(viewModel.monthGroups.indices, id: \.self) { monthIndex in
                                MonthGroupView(group: viewModel.monthGroups[monthIndex], dayHeaders: dayHeaders)
                                    .id(monthIndex)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .onAppear {
                    // Auto-scrolls to current month after brief delay
                    Task {
                        try? await Task.sleep(for: .seconds(0.2))
                        withAnimation {
                            if let currentIndex = viewModel.currentMonthIndex {
                                proxy.scrollTo(currentIndex, anchor: .top)
                            }
                        }
                    }
                }
            }
            .background(Color("MainBG"))
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // Loads all months and activity data from SwiftData
                viewModel.setContext(modelContext)
                viewModel.load()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(Color("AccentCoral"))
                }
            }
        }
    }
}

// Renders a single month's calendar grid with header and week rows
struct MonthGroupView: View {
    let group: MonthGroup
    let dayHeaders: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(group.monthTitle).font(.title3).fontWeight(.bold).foregroundColor(Color("TextBlue")).padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                ForEach(dayHeaders, id: \.self) { letter in
                    Text(letter).font(.caption).fontWeight(.semibold).foregroundColor(.secondary).frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            
            // Week rows (each row contains 7 days)
            ForEach(group.weeks.indices, id: \.self) { weekIndex in
                WeekRowView(week: group.weeks[weekIndex]).padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 16).background(Color("CardBG")).cornerRadius(20).padding(.horizontal, 16)
    }
}

// Renders a single week row (7 day cells)
struct WeekRowView: View {
    let week: [DayStatus]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                // Placeholder cells for leading/trailing empty days
                if day.isPlaceholder {
                    Color.clear.frame(maxWidth: .infinity).frame(height: 64)
                // Future days are not tappable
                } else if day.isFuture {
                    CalendarDayCell(day: day).frame(maxWidth: .infinity)
                // Past/present days link to detail view
                } else {
                    NavigationLink(destination: DayDetailView(dayStatus: day)) {
                        CalendarDayCell(day: day).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// Individual day cell showing date number and activity indicators
struct CalendarDayCell: View {
    let day: DayStatus
    
    private var dayNumber: Int { Calendar.current.component(.day, from: day.date) }
    
    var body: some View {
        VStack(spacing: 6) {
            // Day number (circled if today, dimmed if future)
            Text("\(dayNumber)")
                .font(.system(size: 16, weight: day.isToday ? .bold : .regular))
                .foregroundColor(day.isToday ? .white : day.isFuture ? Color("MainText").opacity(0.25) : Color("MainText"))
                .frame(width: 36, height: 36)
                .background(Circle().fill(day.isToday ? Color("FillBlue") : Color.clear))
            
            // Activity indicator dots (pink = check-in, coral = medication)
            HStack(spacing: 4) {
                if !day.isFuture {
                    Circle().fill(day.hasCheckIn ? Color("AccentPink") : Color.clear).frame(width: 6, height: 6)
                    Circle().fill(day.medicationLogs.isEmpty ? Color.clear : Color("AccentCoral")).frame(width: 6, height: 6)
                } else {
                    Circle().fill(Color.clear).frame(width: 6, height: 6)
                    Circle().fill(Color.clear).frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
        }
        .frame(height: 64)
    }
}
