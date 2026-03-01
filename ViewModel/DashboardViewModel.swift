//
//  DashboardViewModel.swift
//  PulseCor
//
import Foundation
import SwiftData
import Combine

@MainActor
class DashboardViewModel: ObservableObject {

    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastCheckInDate: Date?
    @Published var recentCheckIns: [DailyCheckIn] = []
    @Published var weeklyCheckInCount: Int = 0
    @Published var featuredArticles: [Article] = []
    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    init() {}

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        loadDashboardData()
    }

    func loadDashboardData() {
        loadUserData()
        loadRecentCheckIns()
        loadWeeklyCount()
        loadFeaturedArticles()
    }

    private func loadUserData() {
        guard let modelContext else { return }
        var descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == 1 })
        descriptor.fetchLimit = 1
        guard let user = try? modelContext.fetch(descriptor).first else { return }
        currentStreak = user.currentStreak
        longestStreak = user.longestStreak
        lastCheckInDate = user.lastCheckInDate
    }

    private func loadRecentCheckIns() {
        guard let modelContext else { return }
        var descriptor = FetchDescriptor<DailyCheckIn>(
            predicate: #Predicate { $0.isComplete == true },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 7
        recentCheckIns = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func loadWeeklyCount() {
        guard let modelContext else { return }
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return }
        let start = weekStart
        let end = now
        let descriptor = FetchDescriptor<DailyCheckIn>(
            predicate: #Predicate { $0.isComplete == true && $0.date >= start && $0.date <= end }
        )
        weeklyCheckInCount = (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    private func loadFeaturedArticles() {
        guard let modelContext else { return }
        let all = (try? modelContext.fetch(FetchDescriptor<Article>())) ?? []
        featuredArticles = Array(all.filter { $0.articleType == .helpfulArticle }.shuffled().prefix(3))
    }
}
