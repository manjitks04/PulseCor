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
            
            //process the data for the UI
            calculateAverages()
            
        } catch let error as PulseCorError {
            self.errorMessage = error.errorDescription
        } catch {
            print("Unexpected Dashboard Error: \(error)")
        }
    }
    
    //calc Logic
    private func calculateAverages() {
        guard !recentCheckIns.isEmpty else {
            averageSleepHours = 0
            averageWaterGlasses = 0
            return
        }
        
        // -avg sleep
        let sleepValues = recentCheckIns.compactMap { checkIn -> Double? in
            guard let hours = checkIn.sleepHours else { return nil }
            switch hours {
            case .eightPlus: return 8.5
            case .sevenToEight: return 7.5
            case .sixToSeven: return 6.5
            case .lessThanSix: return 5.0
            }
        }
        
        averageSleepHours = sleepValues.isEmpty ? 0 : sleepValues.reduce(0, +) / Double(sleepValues.count)
        
        // -avg water
        let waterValues = recentCheckIns.compactMap { checkIn -> Double? in
            // Now using the Enum property 'waterGlasses'
            guard let intake = checkIn.waterGlasses else { return nil }
            
            switch intake {
            case .veryHigh: return 8.0  // Reprsenting "7+ glasses"
            case .high:     return 5.5  // Representing "5-6 glasses"
            case .moderate: return 3.5  // Representing "3-4 glasses"
            case .low:      return 1.0  // Representing "0-2 glasses"
            }
        }
        
        averageWaterGlasses = waterValues.isEmpty ? 0 : waterValues.reduce(0, +) / Double(waterValues.count)
        
        func hasCheckedInToday() -> Bool {
            guard let lastCheckIn = lastCheckInDate else { return false }
            return Calendar.current.isDateInToday(lastCheckIn)
        }
    }
}
