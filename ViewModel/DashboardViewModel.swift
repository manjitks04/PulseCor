//
//  DashboardViewModel.swift
//  PulseCor
//
//
import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastCheckInDate: Date?
    @Published var recentCheckIns: [DailyCheckIn] = []
    @Published var weeklyCheckInCount: Int = 0
    
    @Published var averageSleepHours: Double = 0
    @Published var averageWaterGlasses: Double = 0
    @Published var errorMessage: String?
    
    @Published var featuredArticles: [Article] = []
    
    @Published var pendingMedicationAlert: (id: Int, name: String, dosage: String, time: String)? = nil
    
    private let databaseService: DatabaseService
    
    //Initialisation
    init(databaseService: DatabaseService = .shared) {
        self.databaseService = databaseService
        loadDashboardData()
    }
    
    //loads data
    func loadDashboardData() {
        do {
            //load user streak data
            if let user = try databaseService.getUser() {
                currentStreak = user.currentStreak
                longestStreak = user.longestStreak
                lastCheckInDate = user.lastCheckInDate
            }
            
            weeklyCheckInCount = try databaseService.getWeeklyCount(userId: 1)
            
            //recent check-ins for the chart/averages
            recentCheckIns = try databaseService.getRecentCheckIns(limit: 7)
            
            // Load 3 random articles for dashboard
            featuredArticles = try databaseService.getRandomArticles(
                category: nil,
                type: .helpfulArticle,
                limit: 3
            )
            
//            calculateAverages()
            
        } catch let error as PulseCorError {
            self.errorMessage = error.errorDescription
        } catch {
            print("Unexpected Dashboard Error: \(error)")
        }
    }
    
    //calc Logic
//    private func calculateAverages() {
//        guard !recentCheckIns.isEmpty else {
//            averageSleepHours = 0
//            averageWaterGlasses = 0
//            return
//        }
//        
//        // -avg water
//        let waterValues = recentCheckIns.compactMap { checkIn -> Double? in
//            guard let intake = checkIn.waterGlasses else { return nil }
//            
//            switch intake {
//            case .veryHigh: return 8.0
//            case .high:     return 5.5
//            case .moderate: return 3.5
//            case .low:      return 1.0
//            }
//        }
//        
//        averageWaterGlasses = waterValues.isEmpty ? 0 : waterValues.reduce(0, +) / Double(waterValues.count)
//        
//        func hasCheckedInToday() -> Bool {
//            guard let lastCheckIn = lastCheckInDate else { return false }
//            return Calendar.current.isDateInToday(lastCheckIn)
//        }
//    }
}
