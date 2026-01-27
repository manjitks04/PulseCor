//
//  Calendar.swift
//  PulseCor
//
//calendar needed for dashboard view

import Foundation

struct CalendarDay: Identifiable{
    let id = UUID()
    let date: Date
    let dayNum: Int
    let dayLetter: String
    let isCurrentDay: Bool
}

class WeeklyCalendarHelper {
    static func getCurrentWeek() -> [CalendarDay] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        
        var weekDays: [CalendarDay] = []
        
        // Generate 7 days starting from Sunday
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                let dayNumber = calendar.component(.day, from: date)
                let dayLetter = getDayLetter(for: date)
                let isToday = calendar.isDateInToday(date)
                
                weekDays.append(CalendarDay(
                    date: date,
                    dayNum: dayNumber,
                    dayLetter: dayLetter,
                    isCurrentDay: isToday
                ))
            }
        }
        
        return weekDays
    }
    
    static func getDayLetter(for date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEEE"
            return dateFormatter.string(from: date)
        }
    
    static func getMonthYear() -> String {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM" // Month name
            let month = formatter.string(from: date)
            
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let suffix = getDaySuffix(for: day)
            
            return "\(day)\(suffix) \(month)"
        }
    
    static func getDaySuffix(for day: Int) -> String {
        switch day {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
            
        }
    }
}
