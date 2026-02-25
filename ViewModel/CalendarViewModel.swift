//
//  CalendarViewModel.swift
//  PulseCor
//
import Foundation
import Combine

struct MonthGroup {
    let monthTitle: String
    let weeks: [[DayStatus]]
}

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var monthGroups: [MonthGroup] = []
    @Published var isLoading = true
    var currentMonthIndex: Int? = nil

    func load() {
        Task {
            let calendar = Calendar.current
            let today = Date()

            // Two batch queries instead of one per day
            let checkInDates = Set(
                (try? DatabaseService.shared.getAllCheckInDates()) ?? []
            )

            let allMedLogs = (try? DatabaseService.shared.getAllMedicationLogs()) ?? []

            // Group med logs by start-of-day for O(1) lookup
            let medLogsByDay = Dictionary(grouping: allMedLogs) { log in
                calendar.startOfDay(for: log.timestamp)
            }

            var startComponents = DateComponents()
            startComponents.year = 2025
            startComponents.month = 11
            startComponents.day = 1
            guard let startDate = calendar.date(from: startComponents),
                  let endDate = calendar.date(byAdding: .month, value: 2, to: today)
            else {
                isLoading = false
                return
            }

            var groups: [MonthGroup] = []
            var currentDate = startDate

            while currentDate <= endDate {
                if calendar.isDate(currentDate, equalTo: today, toGranularity: .month) {
                    currentMonthIndex = groups.count
                }

                let weeks = buildWeeks(
                    for: currentDate,
                    today: today,
                    calendar: calendar,
                    checkInDates: checkInDates,
                    medLogsByDay: medLogsByDay
                )

                groups.append(MonthGroup(
                    monthTitle: monthYearString(for: currentDate),
                    weeks: weeks
                ))

                guard let next = calendar.date(byAdding: .month, value: 1, to: currentDate)
                else { break }
                currentDate = next
            }

            if currentMonthIndex == nil {
                currentMonthIndex = groups.count - 1
            }

            monthGroups = groups
            isLoading = false
        }
    }


    private func buildWeeks(
        for monthDate: Date,
        today: Date,
        calendar: Calendar,
        checkInDates: Set<Date>,
        medLogsByDay: [Date: [MedicationLogEntry]]
    ) -> [[DayStatus]] {
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (firstWeekday + 5) % 7 // Monday-start offset

        var days: [DayStatus] = []

        // Leading placeholders
        for _ in 0..<offset {
            days.append(placeholder())
        }

        // Actual days — all lookups are in-memory
        for dayNum in range {
            guard let date = calendar.date(byAdding: .day, value: dayNum - 1, to: firstOfMonth)
            else { continue }

            let startOfDay = calendar.startOfDay(for: date)
            let isFuture = startOfDay > calendar.startOfDay(for: today)

            let hasCheckIn = checkInDates.contains(startOfDay)
            let logsForDay = medLogsByDay[startOfDay] ?? []
            let medLogs: [(name: String, dosage: String, status: MedicationStatus)] = logsForDay.map {
                (name: $0.name, dosage: $0.dosage, status: $0.status)
            }

            days.append(DayStatus(
                date: date,
                hasCheckIn: isFuture ? false : hasCheckIn,
                medicationLogs: isFuture ? [] : medLogs,
                isFuture: isFuture,
                isToday: calendar.isDateInToday(date),
                isPlaceholder: false
            ))
        }

        // Trailing placeholders
        while days.count % 7 != 0 {
            days.append(placeholder())
        }

        return stride(from: 0, to: days.count, by: 7).map {
            Array(days[$0..<min($0 + 7, days.count)])
        }
    }

    private func placeholder() -> DayStatus {
        DayStatus(
            date: Date(),
            hasCheckIn: false,
            medicationLogs: [],
            isFuture: false,
            isToday: false,
            isPlaceholder: true
        )
    }

    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
