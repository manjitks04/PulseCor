//
//  CalendarView.swift
//  PulseCor
//
//
import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @Environment(\.dismiss) private var dismiss

    private let dayHeaders = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 60)
                        } else {
                            ForEach(viewModel.monthGroups.indices, id: \.self) { monthIndex in
                                let group = viewModel.monthGroups[monthIndex]

                                VStack(alignment: .leading, spacing: 12) {
                                    // Month header
                                    Text(group.monthTitle)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("TextBlue"))
                                        .padding(.horizontal, 20)

                                    // Day headers
                                    HStack(spacing: 0) {
                                        ForEach(dayHeaders, id: \.self) { letter in
                                            Text(letter)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.secondary)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.horizontal, 12)

                                    // Weeks
                                    ForEach(group.weeks.indices, id: \.self) { weekIndex in
                                        HStack(spacing: 0) {
                                            ForEach(group.weeks[weekIndex]) { day in
                                                if day.isPlaceholder {
                                                    // Empty cell for days outside this month
                                                    Color.clear
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 64)
                                                } else if day.isFuture {
                                                    CalendarDayCell(day: day)
                                                        .frame(maxWidth: .infinity)
                                                } else {
                                                    NavigationLink(destination: DayDetailView(dayStatus: day)) {
                                                        CalendarDayCell(day: day)
                                                            .frame(maxWidth: .infinity)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                    }
                                }
                                .padding(.vertical, 16)
                                .background(Color("CardBG"))
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .id(monthIndex)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            // Scroll to current month
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AccentCoral"))
                }
            }
        }
        .onAppear { viewModel.load() }
    }
}

struct CalendarDayCell: View {
    let day: DayStatus

    private var dayNumber: Int {
        Calendar.current.component(.day, from: day.date)
    }

    var body: some View {
        VStack(spacing: 6) {
            // Day number
            Text("\(dayNumber)")
                .font(.system(size: 16, weight: day.isToday ? .bold : .regular))
                .foregroundColor(
                    day.isToday ? .white :
                    day.isFuture ? Color("MainText").opacity(0.25) :
                    Color("MainText")
                )
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(day.isToday ? Color("FillBlue") : Color.clear)
                )

            // Dots row
            HStack(spacing: 4) {
                if !day.isFuture {
                    // Cora check-in dot
                    Circle()
                        .fill(day.hasCheckIn ? Color("AccentPink") : Color.clear)
                        .frame(width: 6, height: 6)

                    // Medication dot
                    Circle()
                        .fill(day.medicationLogs.isEmpty ? Color.clear : Color("AccentCoral"))
                        .frame(width: 6, height: 6)
                } else {
                    // Keep spacing consistent for future days
                    Circle().fill(Color.clear).frame(width: 6, height: 6)
                    Circle().fill(Color.clear).frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
        }
        .frame(height: 64)
    }
}
