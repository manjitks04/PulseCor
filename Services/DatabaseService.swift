//DatabaseService.swift
//PulseCor


import Foundation
import SQLite

class DatabaseService {
    static let shared = DatabaseService()
    private var db: Connection?

    //Table & Column Definitions
    private let users = Table("users")
    private let checkIns = Table("daily_check_ins")
    private let messages = Table("messages")
    private let flows = Table("conversation_flows")

    // Common Columns
    private let id = Expression<Int64>("id")
    private let userId = Expression<Int>("user_id")
    private let date = Expression<Date>("date")
    private let sessionId = Expression<String>("session_id")

    // Check-In Columns
    private let sleepQuality = Expression<String?>("sleep_quality")
    private let sleepHours = Expression<String?>("sleep_hours")
    private let waterGlasses = Expression<String?>("water_glasses")
    private let stressLevel = Expression<String?>("stress_level")
    private let energyLevel = Expression<String?>("energy_level")
    private let activityLevel = Expression<String?>("activity_level")
    private let isComplete = Expression<Bool>("is_complete")

    // Message Columns
    private let sender = Expression<String>("sender")
    private let content = Expression<String>("content")
    private let timestamp = Expression<Date>("timestamp")

    // Flow Columns
    private let currentStep = Expression<String>("current_step")
    private let tempData = Expression<String>("temp_data") // Stored as JSON string

    // User Columns
    private let name = Expression<String>("name")
    private let createdAt = Expression<Date>("created_at")
    private let currentStreak = Expression<Int>("current_streak")
    private let longestStreak = Expression<Int>("longest_streak")
    private let lastCheckInDate = Expression<Date?>("last_check_in_date")
    
    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/pulsecor.sqlite3")
            try createTables()
        } catch {
            print("Database setup failed: \(error)")
        }
    }

    
    private func createTables() throws {
        //User Table
        try db?.run(users.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name)
                t.column(createdAt)
                t.column(currentStreak, defaultValue: 0)
                t.column(longestStreak, defaultValue: 0)
                t.column(lastCheckInDate)
        })
        
        // Daily Check-ins Table
        try db?.run(checkIns.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(userId)
            t.column(date)
            t.column(sleepQuality)
            t.column(sleepHours)
            t.column(waterGlasses)
            t.column(stressLevel)
            t.column(energyLevel)
            t.column(activityLevel)
            t.column(isComplete)
        })

        // Conversation Flow Table (For session persistence)
        try db?.run(flows.create(ifNotExists: true) { t in
            t.column(sessionId, primaryKey: true)
            t.column(userId)
            t.column(currentStep)
            t.column(tempData)
            t.column(isComplete)
        })

        // Messages Table
        try db?.run(messages.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(sessionId)
            t.column(sender)
            t.column(content)
            t.column(timestamp)
        })
    }

    // Check-In Logic
    func createCheckIn(checkIn: DailyCheckIn) throws -> Bool {
        let insert = checkIns.insert(
            userId <- checkIn.userId,
            date <- checkIn.date,
            sleepQuality <- checkIn.sleepQuality?.rawValue,
            sleepHours <- checkIn.sleepHours?.rawValue,
            waterGlasses <- checkIn.waterGlasses?.rawValue,
            stressLevel <- checkIn.stressLevel?.rawValue,
            energyLevel <- checkIn.energyLevel?.rawValue,
            activityLevel <- checkIn.activityLevel?.rawValue,
            isComplete <- checkIn.isComplete
        )
        try db?.run(insert)
        return true
    }

    //Conversation & Messaging Logic
    func saveMessage(message: ChatMessage) throws -> Bool {
        let insert = messages.insert(
            sessionId <- message.sessionId,
            sender <- message.sender.rawValue,
            content <- message.content,
            timestamp <- Date()
        )
        try db?.run(insert)
        return true
    }

    func updateConversationFlow(sessionId idValue: String, currentStep step: ConversationStep, tempData data: [String: String]) throws {
        let flowRecord = flows.filter(sessionId == idValue)
        
        // Convert Dictionary to JSON String for storage
        let jsonData = try JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

        let update = flowRecord.update(
            currentStep <- step.rawValue,
            tempData <- jsonString
        )
        
        if try db?.run(update) == 0 {
            // If no record exists, create one [cite: 13]
            try db?.run(flows.insert(
                sessionId <- idValue,
                userId <- 1,
                currentStep <- step.rawValue,
                tempData <- jsonString,
                isComplete <- false
            ))
        }
    }
    
    func completeConversationFlow(sessionId idValue: String) throws {
        guard let database = db else {
            throw PulseCorError.databaseConnectionFailed
        }
        
        let flowRecord = flows.filter(sessionId == idValue)
        
        try database.run(flowRecord.update(
            isComplete <- true
        ))
    }

    func getMessages(sessionId idValue: String) throws -> [ChatMessage] {
        var loadedMessages: [ChatMessage] = []
        
        guard let database = db else {
            throw PulseCorError.databaseConnectionFailed
        }
        
        let query = messages.filter(sessionId == idValue).order(timestamp.asc)
        
        for msg in try database.prepare(query) {
            loadedMessages.append(ChatMessage(
                sessionId: msg[sessionId],
                sender: msg[sender] == "cora" ? .cora : .user,
                content: msg[content]
            ))
        }
        return loadedMessages
    }
    
    // User Methods
    func getUser(userId: Int = 1) throws -> User? {
        guard let database = db else {
            throw PulseCorError.databaseConnectionFailed
        }
        
        let query = users.filter(id == Int64(userId))
        
        if let row = try database.pluck(query) {
            return User(
                id: Int(row[id]),
                name: row[name],
                createdAt: row[createdAt],
                lastCheckInDate: row[lastCheckInDate],
                currentStreak: row[currentStreak],
                longestStreak: row[longestStreak]
            )
        }
        
        // If no user exists
        let newUser = User(id: userId, name: "User")
        try database.run(users.insert(
            id <- Int64(userId),
            name <- "User",
            createdAt <- Date(),
            currentStreak <- 0,
            longestStreak <- 0,
            lastCheckInDate <- nil
        ))
        return newUser
    }

    // Get Recent Check-Ins
    func getRecentCheckIns(userId: Int = 1, limit: Int = 7) throws -> [DailyCheckIn] {
        guard let database = db else {
                throw PulseCorError.databaseConnectionFailed
            }
        var checkInsList: [DailyCheckIn] = []
        let query = checkIns
            .filter(self.userId == userId)
            .order(date.desc)
            .limit(limit)
        
        for row in try database.prepare(query) {
            checkInsList.append(DailyCheckIn(
                id: Int(row[id]),
                userId: row[self.userId],
                date: row[date],
                sleepQuality: row[sleepQuality].flatMap { SleepQuality(rawValue: $0) },
                sleepHours: row[sleepHours].flatMap { SleepHours(rawValue: $0) },
                waterGlasses: row[waterGlasses].flatMap { WaterIntake(rawValue: $0) },
                stressLevel: row[stressLevel].flatMap { StressLevel(rawValue: $0) },
                energyLevel: row[energyLevel].flatMap { EnergyLevel(rawValue: $0) },
                activityLevel: row[activityLevel].flatMap { ActivityLevel(rawValue: $0) },
                isComplete: row[isComplete]
            ))
        }
        return checkInsList
    }

    // Helper: Get Current Streak
    private func getCurrentStreak(userId: Int) throws -> Int {
        guard let database = db else {
                throw PulseCorError.databaseConnectionFailed
            }
            
        var streak = 0
        let query = checkIns
            .filter(self.userId == userId)
            .filter(isComplete == true)
            .order(date.desc)
        
        var expectedDate = Calendar.current.startOfDay(for: Date())
        
        for row in try database.prepare(query) {
            let checkInDate = Calendar.current.startOfDay(for: row[date])
            
            if checkInDate == expectedDate {
                streak += 1
                expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: expectedDate)!
            } else {
                break
            }
        }
        return streak
    }

    // Helper: Get Longest Streak
    private func getLongestStreak(userId: Int) throws -> Int {
        guard let database = db else {
                throw PulseCorError.databaseConnectionFailed
            }
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        let query = checkIns
            .filter(self.userId == userId)
            .filter(isComplete == true)
            .order(date.asc)
        
        for row in try database.prepare(query) {
            let checkInDate = Calendar.current.startOfDay(for: row[date])
            
            if let last = lastDate {
                let daysBetween = Calendar.current.dateComponents([.day], from: last, to: checkInDate).day ?? 0
                
                if daysBetween == 1 {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            lastDate = checkInDate
        }
        
        return max(longestStreak, currentStreak)
    }

    // Helper: Get Last Check-In Date
    private func getLastCheckInDate(userId: Int) throws -> Date? {
        guard let database = db else {
                throw PulseCorError.databaseConnectionFailed
            }
        let query = checkIns
            .filter(self.userId == userId)
            .filter(isComplete == true)
            .order(date.desc)
            .limit(1)
        
        if let row = try database.pluck(query) {
            return row[date]
        }
        return nil
    }

    func getActiveConversation() throws -> ConversationFlow? {
        guard let database = db else {
                throw PulseCorError.databaseConnectionFailed
            }
        let query = flows.filter(isComplete == false).limit(1)
        if let row = try database.pluck(query) {
            // Decode JSON string back to Dictionary
            let data = row[tempData].data(using: .utf8)!
            let decodedData = try JSONDecoder().decode([String: String].self, from: data)
            
            return ConversationFlow(
                sessionId: row[sessionId],
                userId: row[userId],
                flowType: .dailyCheckIn,
                currentStep: ConversationStep(rawValue: row[currentStep]) ?? .greeting,
                isComplete: row[isComplete], 
                tempData: decodedData
            )
        }
        return nil
    }
    
    func updateUserStreak(userId: Int, currentStreak streak: Int, longestStreak longest: Int, lastCheckIn: Date) throws {
        guard let database = db else {
            throw PulseCorError.databaseConnectionFailed
        }
        
        let user = users.filter(id == Int64(userId))
        
        let rowsUpdated = try database.run(user.update(
            currentStreak <- streak,
            longestStreak <- longest,
            lastCheckInDate <- lastCheckIn
        ))
        
        // If no user exists
        if rowsUpdated == 0 {
            try database.run(users.insert(
                id <- Int64(userId),
                name <- "User",
                createdAt <- Date(),
                currentStreak <- streak,
                longestStreak <- longest,
                lastCheckInDate <- lastCheckIn
            ))
        }
    }
}
