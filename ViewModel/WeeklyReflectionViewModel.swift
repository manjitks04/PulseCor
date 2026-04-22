//
//  Weeklyreflectionviewmodel.swift
//  PulseCor
//
//  Computes all weekly reflection data from the past 7 DailyCheckIns.
//

import SwiftUI
import Combine
import SwiftData

struct DayDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

struct CorrelationInsight: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let strength: Double
}

@MainActor
class WeeklyReflectionViewModel: ObservableObject {

    @Published var isLoaded = false
    @AppStorage("hasViewedWeeklyReflection") var hasViewedWeeklyReflection: Bool = false

    // Slide 1
    @Published var headlineInsight: String = ""
    @Published var checkInCount: Int = 0
    @Published var currentStreak: Int = 0

    // Slide 2
    @Published var avgSleepHours: Double = 0
    @Published var calmDays: Int = 0

    // Slide 3
    @Published var sleepData: [DayDataPoint] = []
    @Published var daysUnderSevenHours: Int = 0
    @Published var sleepCaption: String = ""

    // Slide 4
    @Published var stressData: [DayDataPoint] = []
    @Published var energyData: [DayDataPoint] = []
    @Published var stressEnergyCaption: String = ""

    // Slide 5
    @Published var waterLevels: [(label: String, count: Int, opacity: Double)] = []
    @Published var hydrationGoalDays: Int = 0
    @Published var hydrationCaption: String = ""

    // Slide 6
    @Published var topCorrelations: [CorrelationInsight] = []
    @Published var weekWin: String = ""

    // Slide 7
    @Published var closingMessage: String = ""

    // Computes all reflection data from last 7 days of check-ins, runs correlation analysis and generates personalised narratives

    func load(checkIns: [DailyCheckIn], userStreak: Int) {
        let sorted = lastWeekSorted(checkIns)
        checkInCount = sorted.count
        currentStreak = userStreak

        computeSleepData(sorted)
        computeStressEnergyData(sorted)
        computeWaterData(sorted)
        computeCorrelations(sorted)
        computeHeadline(sorted)
        computeWeekWin(sorted)
        computeClosingMessage(sorted)

        isLoaded = true
    }

    func markViewed() {
        hasViewedWeeklyReflection = true
    }

    // Filters check-ins to last 7 days and sorts chronologically
    private func lastWeekSorted(_ checkIns: [DailyCheckIn]) -> [DailyCheckIn] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return checkIns.filter { $0.isComplete && $0.date >= cutoff }
            .sorted { $0.date < $1.date }
    }

    private func computeSleepData(_ checkIns: [DailyCheckIn]) {
        sleepData = checkIns.map { DayDataPoint(day: dayLabel(for: $0.date), value: sleepHourValue($0.sleepHours)) }
        let total = sleepData.map { $0.value }.reduce(0, +)
        avgSleepHours = sleepData.isEmpty ? 0 : total / Double(sleepData.count)
        daysUnderSevenHours = checkIns.filter { $0.sleepHours == .lessThanSix || $0.sleepHours == .sixToSeven }.count

        if avgSleepHours < 6.5 {
            sleepCaption = "Sleep was a struggle this week. Even 30 extra minutes can shift how you feel each day."
        } else if avgSleepHours >= 7.5 {
            sleepCaption = "Solid sleep this week, it's one of the best things you can do for your heart."
        } else {
            sleepCaption = "Decent sleep overall. A consistent bedtime could help lock in those gains."
        }
    }

    private func computeStressEnergyData(_ checkIns: [DailyCheckIn]) {
        stressData = checkIns.map { DayDataPoint(day: dayLabel(for: $0.date), value: Double(stressScore($0.stressLevel))) }
        energyData = checkIns.map { DayDataPoint(day: dayLabel(for: $0.date), value: Double(energyScore($0.energyLevel))) }
        calmDays = checkIns.filter { $0.stressLevel == .calm }.count

        let avgS = avg(stressData)
        let avgE = avg(energyData)

        if avgS >= 2.3 {
            stressEnergyCaption = "A high-stress week. Notice how energy dipped when stress peaked, your body was working hard."
        } else if avgE >= 2.5 {
            stressEnergyCaption = "Great energy despite the ups and downs. Keep doing whatever you're doing."
        } else {
            stressEnergyCaption = "Stress and energy ebbed and flowed this week, keep an eye on this!."
        }
    }

    private func computeWaterData(_ checkIns: [DailyCheckIn]) {
        let high = checkIns.filter { $0.waterGlasses == .veryHigh || $0.waterGlasses == .high }.count
        let moderate = checkIns.filter { $0.waterGlasses == .moderate }.count
        let low = checkIns.filter { $0.waterGlasses == .low }.count
        hydrationGoalDays = high

        waterLevels = [
            (label: "Well hydrated (5+ glasses)", count: high, opacity: 1.0),
            (label: "Moderate (3-4 glasses)", count: moderate, opacity: 0.5),
            (label: "Low intake (0-2 glasses)", count: low, opacity: 0.25),
        ]

        if high >= 5 {
            hydrationCaption = "You're nailing hydration. Keep that water bottle visible and you'll keep this up."
        } else if low >= 3 {
            hydrationCaption = "Hydration was a challenge this week. Try starting each morning with a full glass before anything else."
        } else {
            hydrationCaption = "Decent hydration on most days, just a couple of dips. A visible water bottle helps more than you'd think."
        }
    }

    // Detects correlations between wellness metrics, only fires if correltion strength > 0.4 & sufficient data exists
    private func computeCorrelations(_ checkIns: [DailyCheckIn]) {
        guard checkIns.count >= 4 else { return }
        var found: [CorrelationInsight] = []

        let lowSleep  = checkIns.filter { $0.sleepHours == .lessThanSix || $0.sleepHours == .sixToSeven }
        let highSleep = checkIns.filter { $0.sleepHours == .sevenToEight || $0.sleepHours == .eightPlus }
        let highAct   = checkIns.filter { $0.activityLevel == .high || $0.activityLevel == .medium }
        let lowAct    = checkIns.filter { $0.activityLevel == .low  || $0.activityLevel == ActivityLevel.none }
        let lowWater  = checkIns.filter { $0.waterGlasses == .low }
        let highWater = checkIns.filter { $0.waterGlasses == .high || $0.waterGlasses == .veryHigh }
        let highStress = checkIns.filter { $0.stressLevel == .high }
        let calmCheck  = checkIns.filter { $0.stressLevel == .calm }

        // Sleep → Energy
        if lowSleep.count >= 2, highSleep.count >= 1 {
            let diff = avgEnergyOf(highSleep) - avgEnergyOf(lowSleep)
            if diff > 0.4 { found.append(.init(title: "Less sleep, less energy", body: "On nights you slept under 7 hours, your energy next day was consistently lower. Your body is drawing a clear line between rest and how you feel.", strength: diff)) }
        }

        // Sleep → Stress
        if lowSleep.count >= 2, highSleep.count >= 1 {
            let diff = avgStressOf(lowSleep) - avgStressOf(highSleep)
            if diff > 0.4 { found.append(.init(title: "Poor sleep, higher stress", body: "Your stress was noticeably higher after shorter sleep nights. Rest isn't just about energy, it's your stress shield too.", strength: diff)) }
        }

        // Stress → Energy
        if highStress.count >= 1, calmCheck.count >= 1 {
            let diff = avgEnergyOf(calmCheck) - avgEnergyOf(highStress)
            if diff > 0.4 { found.append(.init(title: "Stress drains energy", body: "On high-stress days your energy was noticeably lower. Stress is expensive, your body pays for it in how you feel.", strength: diff)) }
        }

        // Hydration → Energy
        if lowWater.count >= 1, highWater.count >= 1 {
            let diff = avgEnergyOf(highWater) - avgEnergyOf(lowWater)
            if diff > 0.4 { found.append(.init(title: "Water fuels energy", body: "Your energy was higher on the days you stayed well hydrated. It sounds simple because it is, water genuinely works.", strength: diff)) }
        }

        // Hydration → Stress
        if lowWater.count >= 1, highWater.count >= 1 {
            let diff = avgStressOf(lowWater) - avgStressOf(highWater)
            if diff > 0.4 { found.append(.init(title: "Low hydration, higher stress", body: "Your lowest hydration days were also your highest stress days. Dehydration and stress feed each other more than most people realise.", strength: diff)) }
        }

        // Activity → Stress
        if highAct.count >= 1, lowAct.count >= 1 {
            let diff = avgStressOf(lowAct) - avgStressOf(highAct)
            if diff > 0.4 { found.append(.init(title: "Moving reduces stress", body: "On active days your stress was measurably lower. Movement is one of the most underrated stress tools out there.", strength: diff)) }
        }

        // Activity → Energy
        if highAct.count >= 1, lowAct.count >= 1 {
            let diff = avgEnergyOf(highAct) - avgEnergyOf(lowAct)
            if diff > 0.4 { found.append(.init(title: "Activity boosts energy", body: "Your energy was noticeably higher on active days. Movement gives back more than it takes, even a short walk counts.", strength: diff)) }
        }

        topCorrelations = Array(found.sorted { $0.strength > $1.strength }.prefix(2))
    }

    // Generates headline insight based on check-in count and wellness averages
    // Priority: high stress + perfect week > low sleep + perfect week > high energy + perfect week > else
    private func computeHeadline(_ checkIns: [DailyCheckIn]) {
        let s = avgStressOf(checkIns)
        let sl = avgSleepOf(checkIns)
        let e = avgEnergyOf(checkIns)

        if s >= 2.3 && checkInCount == 7 {
            headlineInsight = "It was a high-stress week but you didn't miss a single day"
        } else if sl < 6.5 && checkInCount == 7 {
            headlineInsight = "Sleep was tough this week but you showed up every day"
        } else if e >= 2.5 && checkInCount == 7 {
            headlineInsight = "Great energy this week and a perfect check-in record to match"
        } else if checkInCount == 7 {
            headlineInsight = "A full week of check-ins. Whatever life threw at you, you kept showing up"
        } else if s >= 2.3 {
            headlineInsight = "A stressful week, but you kept coming back to check in"
        } else if sl < 6.5 {
            headlineInsight = "Sleep was on the lower side this week, let's see what the data says"
        } else {
            headlineInsight = "Another week in the books, let's see how it went"
        }
    }

    // Identifies biggest accomplishment of the week
    // Priority order: 7/7 check-ins > 4+ calm days > 5+ hydrated days > good sleep > showed up on hardest day
    private func computeWeekWin(_ checkIns: [DailyCheckIn]) {
        if checkInCount == 7 {
            weekWin = "You completed every single check-in this week. No excuses, no skips, just showing up."
        } else if calmDays >= 4 {
            weekWin = "You had \(calmDays) calm days this week. That's your nervous system working well."
        } else if hydrationGoalDays >= 5 {
            weekWin = "You stayed well hydrated on \(hydrationGoalDays) out of 7 days. Your body noticed."
        } else if daysUnderSevenHours <= 2 {
            weekWin = "Most of your nights hit 7+ hours of sleep. Your heart appreciates it more than you know."
        } else {
            weekWin = "Even on your hardest day this week, you still showed up and checked in. That's your win."
        }
    }

    //Closing Message (3 check-in tiers & 4 mood variants)

    private func computeClosingMessage(_ checkIns: [DailyCheckIn]) {
        let s   = avgStressOf(checkIns)
        let sl  = avgSleepOf(checkIns)
        let e   = avgEnergyOf(checkIns)
        let isHighStress = s >= 2.3
        let isLowSleep   = sl < 6.5
        let isLowEnergy  = e < 1.8
        let isPositive   = !isHighStress && !isLowSleep && !isLowEnergy

        switch checkInCount {
        case 7:
            if isHighStress {
                closingMessage = "Perfect attendance through a tough week, that's real dedication. I'm proud of you! Next week, let's focus on bringing that stress down a notch. You've got this 💙"
            } else if isLowSleep {
                closingMessage = "Seven check-ins even on the tired days, that consistency is exactly how habits stick. Try protecting your bedtime this week, even 30 minutes earlier helps."
            } else if isLowEnergy {
                closingMessage = "You showed up every day even when energy was low. Rest, hydrate, and keep going your body is listening 💙"
            } else {
                closingMessage = "Seven for seven. A genuinely great week, keep that momentum and let's make next week even better 💙"
            }
        case 5, 6:
            if isHighStress {
                closingMessage = "A tough week, but you kept coming back. Missing a day or two is human but what matters is you didn't stop. Next week, take it one day at a time 💙"
            } else if isLowSleep {
                closingMessage = "Not a full week, but you're still here and that counts. A little more sleep and consistency will go a long way next week."
            } else if isPositive {
                closingMessage = "Nearly a full week and a good one at that. One more check-in next week and you'll have a perfect run, you're so close 💙"
            } else {
                closingMessage = "Most of the week done. Keep building that habit and it'll start to feel effortless 💙"
            }
        default:
            if isHighStress {
                closingMessage = "A hard week on multiple fronts. The fact that you're here reviewing your data says a lot. Take care of yourself, start small 💙"
            } else {
                closingMessage = "Every check-in makes the next one easier. You've started and now let's build on it together 💙"
            }
        }
    }
    
    // Converts SleepHours enum to numeric value for chart display and averaging
    func sleepHourValue(_ hours: SleepHours?) -> Double {
        switch hours {
        case .lessThanSix: return 5.0
        case .sixToSeven:  return 6.5
        case .sevenToEight: return 7.5
        case .eightPlus:   return 8.5
        case nil:          return 0
        }
    }

    private func stressScore(_ l: StressLevel?) -> Int { switch l { case .calm: return 1; case .moderate: return 2; case .high: return 3; default: return 2 } }
    private func energyScore(_ l: EnergyLevel?) -> Int { switch l { case .high: return 3; case .medium: return 2; case .low: return 1; default: return 2 } }

    private func avgStressOf(_ c: [DailyCheckIn]) -> Double {
        guard !c.isEmpty else { return 0 }
        return Double(c.map { stressScore($0.stressLevel) }.reduce(0, +)) / Double(c.count)
    }
    private func avgEnergyOf(_ c: [DailyCheckIn]) -> Double {
        guard !c.isEmpty else { return 0 }
        return Double(c.map { energyScore($0.energyLevel) }.reduce(0, +)) / Double(c.count)
    }
    private func avgSleepOf(_ c: [DailyCheckIn]) -> Double {
        guard !c.isEmpty else { return 0 }
        return c.map { sleepHourValue($0.sleepHours) }.reduce(0, +) / Double(c.count)
    }
    private func avg(_ pts: [DayDataPoint]) -> Double {
        guard !pts.isEmpty else { return 0 }
        return pts.map { $0.value }.reduce(0, +) / Double(pts.count)
    }
    
    // Converts date to single-letter weekday abbreviation
    private func dayLabel(for date: Date) -> String {
        let labels = ["S","M","T","W","T","F","S"]
        return labels[Calendar.current.component(.weekday, from: date) - 1]
    }
}
