//DatabaseService.swift
//PulseCor


import Foundation
import SQLite

class DatabaseService {
    static let shared = DatabaseService()
    private var db: Connection?

    // Table Definitions

    private let users = Table("users")
    private let checkIns = Table("daily_check_ins")
    private let messages = Table("messages")
    private let flows = Table("conversation_flows")
    private let articles = Table("articles")
    private let medications = Table("medications")
    private let medicationLogs = Table("medication_logs")

    //Common Columns

    private let id = Expression<Int64>("id")
    private let userId = Expression<Int>("user_id")
    private let date = Expression<Date>("date")
    private let sessionId = Expression<String>("session_id")
    private let title = Expression<String>("title")
    private let summary = Expression<String>("summary")
    private let category = Expression<String>("category")
    private let articleType = Expression<String>("article_type")
    private let imageName = Expression<String?>("image_name")

    //Check-In Columns

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

    // Columns

    private let currentStep = Expression<String>("current_step")
    private let tempData = Expression<String>("temp_data")

    //User Columns

    private let name = Expression<String>("name")
    private let createdAt = Expression<Date>("created_at")
    private let currentStreak = Expression<Int>("current_streak")
    private let longestStreak = Expression<Int>("longest_streak")
    private let lastCheckInDate = Expression<Date?>("last_check_in_date")

    // Medication Columns

    private let medicationId = Expression<Int>("medication_id")
    private let dosage = Expression<String>("dosage")
    private let frequency = Expression<String>("frequency")
    private let reminderTimes = Expression<String?>("reminder_times")
    private let isActive = Expression<Bool>("is_active")
    private let status = Expression<String>("status")
    private let scheduledTime = Expression<String>("scheduled_time")

    //App Start Date (used to scope queries)

    private var appStartDate: Date = {
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }()

    //Init

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/pulsecor.sqlite3")
            try createTables()

            // Only seed articles once — avoids a query on every launch
            if !UserDefaults.standard.bool(forKey: "hasSeededArticles") {
                try seedInitialArticles()
                UserDefaults.standard.set(true, forKey: "hasSeededArticles")
            }
        } catch {
            print("Database setup failed: \(error)")
        }
    }

    //Create Tables

    private func createTables() throws {
        try db?.run(users.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(name)
            t.column(createdAt)
            t.column(currentStreak, defaultValue: 0)
            t.column(longestStreak, defaultValue: 0)
            t.column(lastCheckInDate)
        })

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

        try db?.run(flows.create(ifNotExists: true) { t in
            t.column(sessionId, primaryKey: true)
            t.column(userId)
            t.column(currentStep)
            t.column(tempData)
            t.column(isComplete)
        })

        try db?.run(messages.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(sessionId)
            t.column(sender)
            t.column(content)
            t.column(timestamp)
        })

        try db?.run(medications.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(userId)
            t.column(name)
            t.column(dosage)
            t.column(frequency)
            t.column(reminderTimes)
            t.column(isActive)
            t.column(createdAt)
        })

        try db?.run(medicationLogs.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(medicationId)
            t.column(status)
            t.column(timestamp)
            t.column(scheduledTime)
        })

        try db?.run(articles.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(title)
            t.column(summary)
            t.column(content)
            t.column(category)
            t.column(articleType)
            t.column(imageName)
        })

        // Indexes for commonly filtered columns
        try db?.run(checkIns.createIndex(userId, date, ifNotExists: true))
        try db?.run(checkIns.createIndex(isComplete, ifNotExists: true))
        try db?.run(medicationLogs.createIndex(timestamp, ifNotExists: true))
        try db?.run(medications.createIndex(userId, isActive, ifNotExists: true))
    }

    // Check-Ins

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

    func getRecentCheckIns(userId: Int = 1, limit: Int = 7) throws -> [DailyCheckIn] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let query = checkIns
            .filter(self.userId == userId)
            .order(date.desc)
            .limit(limit)

        return try database.prepare(query).map { row in
            DailyCheckIn(
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
            )
        }
    }

    func getLast30DaysCheckIns(userId: Int = 1) throws -> [DailyCheckIn] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!

        let query = checkIns
            .filter(self.userId == userId)
            .filter(date >= thirtyDaysAgo && date <= today)
            .order(date.asc)

        return try database.prepare(query).map { row in
            DailyCheckIn(
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
            )
        }
    }

    func hasCheckedInToday(userId: Int = 1) throws -> Bool {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let query = checkIns
            .filter(self.userId == userId)
            .filter(isComplete == true)
            .filter(date >= startOfToday && date < endOfToday)

        return try database.scalar(query.count) > 0
    }

    func getWeeklyCount(userId: Int = 1) throws -> Int {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let calendar = Calendar.current
        let now = Date()

        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return 0 }

        let query = checkIns
            .filter(self.userId == userId)
            .filter(isComplete == true)
            .filter(date >= weekStart && date <= now)

        return try database.scalar(query.count)
    }

    // Batch query — returns all check-in dates as start-of-day values for calendar use
    func getAllCheckInDates(userId: Int = 1) throws -> [Date] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let query = checkIns
            .filter(self.userId == userId)
            .filter(isComplete == true)
            .filter(date >= appStartDate)
            .select(date)

        return try database.prepare(query).map {
            Calendar.current.startOfDay(for: $0[date])
        }
    }

    // Streaks

    func getCurrentStreak(userId: Int) throws -> Int {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

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

    func getLongestStreak(userId: Int) throws -> Int {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

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

    // Users

    func getUser(userId: Int = 1) throws -> User? {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

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

        try database.run(users.insert(
            id <- Int64(userId),
            name <- "User",
            createdAt <- Date(),
            currentStreak <- 0,
            longestStreak <- 0,
            lastCheckInDate <- nil
        ))
        return User(id: userId, name: "User")
    }

    func updateUserStreak(userId: Int, currentStreak streak: Int, longestStreak longest: Int, lastCheckIn: Date) throws {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let user = users.filter(id == Int64(userId))
        let rowsUpdated = try database.run(user.update(
            currentStreak <- streak,
            longestStreak <- longest,
            lastCheckInDate <- lastCheckIn
        ))

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

    // Medications

    func createMedication(medication: Medication) throws -> Int64 {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let reminderTimesString = medication.reminderTimes?.joined(separator: ",") ?? ""
        let insert = medications.insert(
            userId <- medication.userId,
            name <- medication.name,
            dosage <- medication.dosage,
            frequency <- medication.frequency,
            reminderTimes <- reminderTimesString,
            isActive <- medication.isActive,
            createdAt <- medication.createdAt
        )
        return try database.run(insert)
    }

    func getMedications(userId: Int = 1) throws -> [Medication] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let query = medications.filter(self.userId == userId && isActive == true)

        return try database.prepare(query).map { row in
            let timesString = row[reminderTimes] ?? ""
            let timesArray = timesString.isEmpty ? [] : timesString.components(separatedBy: ",")
            return Medication(
                id: Int(row[id]),
                userId: row[self.userId],
                name: row[name],
                dosage: row[dosage],
                frequency: row[frequency],
                reminderTimes: timesArray,
                isActive: row[isActive],
                createdAt: row[createdAt]
            )
        }
    }

    func updateMedication(medicationId: Int, name: String, dosage: String, frequency: String, reminderTimes: [String]) throws {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let medication = medications.filter(id == Int64(medicationId))
        try database.run(medication.update(
            self.name <- name,
            self.dosage <- dosage,
            self.frequency <- frequency,
            self.reminderTimes <- reminderTimes.joined(separator: ",")
        ))
    }

    func deleteMedication(medicationId: Int) throws {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        // Soft delete — preserves log history
        let medication = medications.filter(id == Int64(medicationId))
        try database.run(medication.update(isActive <- false))
    }

    // Medication Logs

    func logMedicationStatus(medicationId: Int, status: MedicationStatus, scheduledTime: String) throws {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        try database.run(medicationLogs.insert(
            self.medicationId <- medicationId,
            self.status <- status.rawValue,
            timestamp <- Date(),
            self.scheduledTime <- scheduledTime
        ))
    }

    // Batch query — returns all logs from app start date for calendar use
    func getAllMedicationLogs(userId: Int = 1) throws -> [MedicationLogEntry] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        // Build id → (name, dosage) lookup once
        let userMeds = try getMedications(userId: userId)
        let medInfo: [Int: (String, String)] = Dictionary(
            uniqueKeysWithValues: userMeds.compactMap { med -> (Int, (String, String))? in
                guard let medId = med.id else { return nil }
                return (medId, (med.name, med.dosage))
            }
        )

        let query = medicationLogs.filter(timestamp >= appStartDate)

        return try database.prepare(query).compactMap { row in
            let rowMedId = row[medicationId]
            guard let info = medInfo[rowMedId],
                  let medStatus = MedicationStatus(rawValue: row[self.status])
            else { return nil }

            return MedicationLogEntry(
                medicationId: rowMedId,
                name: info.0,
                dosage: info.1,
                status: medStatus,
                timestamp: row[timestamp]
            )
        }
    }

    // Messages

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

    func getMessages(sessionId idValue: String) throws -> [ChatMessage] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let query = messages.filter(sessionId == idValue).order(timestamp.asc)

        return try database.prepare(query).map { msg in
            ChatMessage(
                sessionId: msg[sessionId],
                sender: msg[sender] == "Cora" ? .cora : .user,
                content: msg[content]
            )
        }
    }

    // Conversation Flows

    func updateConversationFlow(sessionId idValue: String, currentStep step: ConversationStep, tempData data: [String: String]) throws {
        let flowRecord = flows.filter(sessionId == idValue)

        let jsonData = try JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

        if try db?.run(flowRecord.update(
            currentStep <- step.rawValue,
            tempData <- jsonString
        )) == 0 {
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
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }
        let flowRecord = flows.filter(sessionId == idValue)
        try database.run(flowRecord.update(isComplete <- true))
    }

    func getActiveConversation() throws -> ConversationFlow? {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let query = flows.filter(isComplete == false).limit(1)
        if let row = try database.pluck(query) {
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

    // Articles

    func getArticlesByCategory(category: ArticleCategory, type: ArticleType? = nil) throws -> [Article] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        var query = articles.filter(self.category == category.rawValue)
        if let type = type { query = query.filter(articleType == type.rawValue) }

        return try database.prepare(query).map { row in
            Article(
                id: Int(row[id]),
                title: row[title],
                summary: row[summary],
                content: row[content],
                category: ArticleCategory(rawValue: row[self.category]) ?? .generalWellness,
                articleType: ArticleType(rawValue: row[articleType]) ?? .helpfulArticle,
                imageName: row[imageName]
            )
        }
    }

    func getRandomArticles(category: ArticleCategory? = nil, type: ArticleType? = nil, limit: Int = 3) throws -> [Article] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        var query = articles.select(articles[*])
        if let category = category { query = query.filter(self.category == category.rawValue) }
        if let type = type { query = query.filter(articleType == type.rawValue) }
        query = query.order(Expression<Int>.random()).limit(limit)

        return try database.prepare(query).map { row in
            Article(
                id: Int(row[id]),
                title: row[title],
                summary: row[summary],
                content: row[content],
                category: ArticleCategory(rawValue: row[self.category]) ?? .generalWellness,
                articleType: ArticleType(rawValue: row[articleType]) ?? .helpfulArticle,
                imageName: row[imageName]
            )
        }
    }

    func getAllGeneralArticles() throws -> [Article] {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        let query = articles.filter(category == ArticleCategory.generalWellness.rawValue)

        return try database.prepare(query).map { row in
            Article(
                id: Int(row[id]),
                title: row[title],
                summary: row[summary],
                content: row[content],
                category: ArticleCategory(rawValue: row[self.category]) ?? .generalWellness,
                articleType: ArticleType(rawValue: row[articleType]) ?? .helpfulArticle,
                imageName: row[imageName]
            )
        }
    }

    private func seedInitialArticles() throws {
        guard let database = db else { throw PulseCorError.databaseConnectionFailed }

        func loadArticleContent(filename: String) -> String {
            guard let filepath = Bundle.main.path(forResource: filename, ofType: "txt"),
                  let content = try? String(contentsOfFile: filepath, encoding: .utf8)
            else { return "Content not available." }
            return content
        }

        let sampleArticles: [(title: String, summary: String, content: String, category: String, type: String, image: String?)] = [
            ("Improve your sleep", "Better sleep changes everything", loadArticleContent(filename: "improve_sleep"), ArticleCategory.sleep.rawValue, ArticleType.helpfulArticle.rawValue, "improve_sleep"),
            ("Move more, sit less", "Simple ways to stay active", loadArticleContent(filename: "move_more"), ArticleCategory.generalWellness.rawValue, ArticleType.helpfulArticle.rawValue, "move_more"),
            ("Practice mindfulness", "Find calm in your day", loadArticleContent(filename: "mindfulness"), ArticleCategory.generalWellness.rawValue, ArticleType.helpfulArticle.rawValue, "mindfulness"),
            ("Holistic heart care", "Taking care of your heart naturally", loadArticleContent(filename: "heart_care"), ArticleCategory.cardiovascular.rawValue, ArticleType.helpfulArticle.rawValue, "heart_care"),
            ("Prioritise your health", "Make yourself a priority", loadArticleContent(filename: "prioritise_health"), ArticleCategory.generalWellness.rawValue, ArticleType.helpfulArticle.rawValue, "prioritise_health"),
            ("Fuel your body", "Nutrition for better energy", loadArticleContent(filename: "fuel_body"), ArticleCategory.generalWellness.rawValue, ArticleType.helpfulArticle.rawValue, "fuel_body"),
            ("What are heart disease risk factors?", "Understanding and reducing your risk", loadArticleContent(filename: "heart_disease_risk"), ArticleCategory.cardiovascular.rawValue, ArticleType.helpfulArticle.rawValue, "heart_disease_risk"),
            ("Can stress affect my body?", "Understanding the stress-body connection", loadArticleContent(filename: "stress_body"), ArticleCategory.generalWellness.rawValue, ArticleType.helpfulArticle.rawValue, "stress_body"),
            ("How much water should I have?", "Staying properly hydrated", loadArticleContent(filename: "water_should"), ArticleCategory.generalWellness.rawValue, ArticleType.helpfulArticle.rawValue, "water_should")
        ]

        for article in sampleArticles {
            try database.run(articles.insert(
                title <- article.title,
                summary <- article.summary,
                content <- article.content,
                category <- article.category,
                articleType <- article.type,
                imageName <- article.image
            ))
        }
    }
}
