//
//  ChatScreenViewModel.swift
//  PulseCor
//
//  Responsibilities: Manages all screen-level state for ChatView
//  Includes: check-in status, streak, weekly reflection routing, and Cora card logic
//  ModelContext: Injected via setContext(_:)
//

import SwiftUI
import SwiftData
import Combine

struct CoraTip {
    let text: String
    let source: String
}

enum CoraCardType {
    case tip(CoraTip)
    case stat(String)
    case sundayTeaser(stat: String)
    case sundayTopStat(String)
    case insufficientData
}

@MainActor
class ChatScreenViewModel: ObservableObject {

    // Screen State
    @Published var hasCheckedInToday: Bool = false
    @Published var currentStreak: Int = 0
    @Published var shouldShowReflection: Bool = false

    //Xard State
    @Published var cardType: CoraCardType = .insufficientData
    @AppStorage("hasViewedWeeklyReflection") var hasViewedWeeklyReflection: Bool = false

    private var modelContext: ModelContext?
    private let sessionTip: CoraTip

    //Tips
    private static let tips: [CoraTip] = [
        CoraTip(text: "Try box breathing: inhale for 4 counts, hold for 4, exhale for 4, hold for 4. Repeat 3 times.", source: "Cleveland Clinic"),
        CoraTip(text: "Try the 4-7-8 technique: inhale for 4, hold for 7, exhale slowly for 8. A natural calm in under a minute.", source: "Dr. Andrew Weil, Harvard Medical School"),
        CoraTip(text: "Even one slow belly breath which means expanding your stomach, not your chest activates your body's rest response.", source: "Harvard Medical School"),
        CoraTip(text: "Feeling overwhelmed? Pause and take 3 deep breaths before reacting. It genuinely changes your stress response.", source: "American Institute of Stress"),
        CoraTip(text: "Try keeping a water bottle visible on your desk, out of sight often means out of mind.", source: "British Journal of Health Psychology"),
        CoraTip(text: "Mild dehydration can feel like fatigue or brain fog. A glass of water is always worth trying first.", source: "University of Connecticut Human Performance Laboratory"),
        CoraTip(text: "Starting your morning with water before coffee or tea is a small habit with a surprisingly big energy payoff.", source: "British Dietetic Association"),
        CoraTip(text: "Herbal teas count toward your hydration — chamomile, peppermint, and ginger are all great choices.", source: "British Heart Foundation"),
        CoraTip(text: "Every 30–45 minutes, try standing up and rolling your shoulders back. Your spine will thank you.", source: "NHS Musculoskeletal Guidelines"),
        CoraTip(text: "A 5-minute walk after meals has been shown to reduce blood sugar spikes and support heart health. Get those steps in! (And don't forget your water.)", source: "American Diabetes Association"),
        CoraTip(text: "Tired from sitting? Try a 60-second hip flexor stretch, it can immediately ease lower back tension.", source: "NHS Back Care Guidelines"),
        CoraTip(text: "Even micro-movements count: calf raises at your desk, standing on calls, a short walk to refill your water.", source: "British Journal of Sports Medicine"),
        CoraTip(text: "When you notice tension in your body, try naming where it is. Awareness alone can soften stress. Then take action.", source: "Harvard Medical School, Mindfulness Research"),
        CoraTip(text: "The 5-4-3-2-1 grounding technique: name 5 things you see, 4 you hear, 3 you can touch, 2 you smell, 1 you taste.", source: "Cognitive Behavioural Therapy Research"),
        CoraTip(text: "Chronic stress raises cortisol over time. Today, try protecting even 10 minutes just for you. Spend time to unwind.", source: "American Heart Association"),
        CoraTip(text: "Writing down three things you're grateful for before bed has been shown to lower overnight heart rate.", source: "UC Berkeley Greater Good Science Center"),
    ]

    init() {
        sessionTip = ChatScreenViewModel.tips.randomElement() ?? ChatScreenViewModel.tips[0]
    }

    //Setup

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        loadData()
    }

    func loadData() {
        checkTodayCheckIn()
        fetchCurrentStreak()
    }

    // Screen State Logic

    private func checkTodayCheckIn() {
        guard let modelContext else { return }
        let start = Calendar.current.startOfDay(for: Date())
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return }
        let descriptor = FetchDescriptor<DailyCheckIn>(
            predicate: #Predicate { $0.isComplete == true && $0.date >= start && $0.date < end }
        )
        hasCheckedInToday = ((try? modelContext.fetchCount(descriptor)) ?? 0) > 0
    }

    private func fetchCurrentStreak() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<User>()
        currentStreak = (try? modelContext.fetch(descriptor))?.first?.currentStreak ?? 0
    }

    func handlePendingWeeklyReflection(checkIns: [DailyCheckIn]) {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentCount = checkIns.filter { $0.date >= cutoff }.count
        if recentCount >= 4 { shouldShowReflection = true }
        NavigationManager.shared.pendingWeeklyReflection = false
    }

    //Card Logic

    func loadCards(checkIns: [DailyCheckIn]) {
        let weekday = Calendar.current.component(.weekday, from: Date())

        switch weekday {
        case 2, 4, 5, 7:
            cardType = .tip(sessionTip)

        case 3, 6:
            let lastWeek = recentCheckIns(checkIns)
            cardType = lastWeek.count >= 4 ? .stat(computeSimpleStat(lastWeek)) : .insufficientData

        case 1:
            let lastWeek = recentCheckIns(checkIns)
            if lastWeek.count >= 4 {
                cardType = !hasViewedWeeklyReflection
                    ? .sundayTeaser(stat: computeSimpleStat(lastWeek))
                    : .sundayTopStat(computeSimpleStat(lastWeek))
            } else {
                cardType = .insufficientData
            }

        default:
            cardType = .tip(sessionTip)
        }
    }

    private func recentCheckIns(_ checkIns: [DailyCheckIn]) -> [DailyCheckIn] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return checkIns.filter { $0.isComplete && $0.date >= cutoff }
    }

    private func computeSimpleStat(_ checkIns: [DailyCheckIn]) -> String {
        let waterScores = checkIns.compactMap { waterScore($0.waterGlasses) }
        if !waterScores.isEmpty {
            let avg = Double(waterScores.reduce(0, +)) / Double(waterScores.count)
            if avg <= 1.5 { return "This week you averaged around \(waterLabel(avg)) of water a day. Small sips more often can make a big difference!" }
            else if avg >= 3.0 { return "This week you averaged around \(waterLabel(avg)) of water a day, you're nailing your hydration!" }
        }
        let stressScores = checkIns.compactMap { stressScore($0.stressLevel) }
        if !stressScores.isEmpty {
            let avg = Double(stressScores.reduce(0, +)) / Double(stressScores.count)
            if avg >= 2.4 { return "It's been a high-stress week, it's okay it happens. Try protecting even 10 minutes just for you 💛" }
            else if avg <= 1.3 { return "You've stayed mostly calm this week. That consistency quietly does a lot for your heart 💙" }
        }
        let sleepScores = checkIns.compactMap { sleepScore($0.sleepHours) }
        if !sleepScores.isEmpty {
            let avg = Double(sleepScores.reduce(0, +)) / Double(sleepScores.count)
            if avg < 2.0 { return "Your sleep has been on the lower side this week. Even an extra 30 minutes can shift how you feel day to day." }
            else if avg >= 3.0 { return "You've got solid sleep this week! That's one of the best things you can do for your heart." }
        }
        return "You've completed \(checkIns.count) check-ins this week 🌟 Keep that momentum going."
    }

    private func waterScore(_ intake: WaterIntake?) -> Int? {
        switch intake {
        case .low: return 1; case .moderate: return 2
        case .high: return 3; case .veryHigh: return 4; case nil: return nil
        }
    }

    private func waterLabel(_ avg: Double) -> String {
        switch avg {
        case ..<1.5: return "1–2 glasses"
        case 1.5..<2.5: return "3–4 glasses"
        case 2.5..<3.5: return "5–6 glasses"
        default: return "7+ glasses"
        }
    }

    private func stressScore(_ level: StressLevel?) -> Int? {
        switch level {
        case .calm: return 1; case .moderate: return 2
        case .high: return 3; case nil: return nil
        }
    }

    private func sleepScore(_ hours: SleepHours?) -> Int? {
        switch hours {
        case .lessThanSix: return 1; case .sixToSeven: return 2
        case .sevenToEight: return 3; case .eightPlus: return 4; case nil: return nil
        }
    }
}
