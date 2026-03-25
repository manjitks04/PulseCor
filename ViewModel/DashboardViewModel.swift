//
//  DashboardViewModel.swift
//  PulseCor

//  Responsibilities: Manages all dashboard state including streak data, weekly check-in count,
//  featured articles, today's check-in status, and medication log persistence.
//  ModelContext: Injected via setContext(_:)
//  Services: None — all operations handled via SwiftData ModelContext

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
    @Published var hasCheckedInToday: Bool = false
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
        checkTodayCheckIn()
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
        let end = now
        let descriptor = FetchDescriptor<DailyCheckIn>(
            predicate: #Predicate { $0.isComplete == true && $0.date >= weekStart && $0.date <= end }
        )
        weeklyCheckInCount = (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    private func loadFeaturedArticles() {
        guard let modelContext else { return }
        let all = (try? modelContext.fetch(FetchDescriptor<Article>())) ?? []
        featuredArticles = Array(all.filter { $0.articleType == .helpfulArticle }.shuffled().prefix(3))
    }

    // Determines whether the user has already completed a check-in today.
    private func checkTodayCheckIn() {
        guard let modelContext else { return }
        let start = Calendar.current.startOfDay(for: Date())
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return }
        let descriptor = FetchDescriptor<DailyCheckIn>(
            predicate: #Predicate { $0.isComplete == true && $0.date >= start && $0.date < end }
        )
        hasCheckedInToday = ((try? modelContext.fetchCount(descriptor)) ?? 0) > 0
    }

    func logMedicationAction(med: PendingMedication, status: MedicationStatus) {
        guard let modelContext else { return }
        let log = MedicationLog(
            medicationLocalId: UUID(uuidString: med.id) ?? UUID(),
            medicationName: med.name,
            medicationDosage: med.dosage,
            status: status,
            scheduledTime: med.time
        )
        modelContext.insert(log)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to log medication action"
            print("DashboardViewModel logMedicationAction error: \(error)")
        }
    }
}
