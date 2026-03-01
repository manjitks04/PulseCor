//
//  ChatViewModel.swift
//  PulseCor
//
//  Manages chat interface state, conversation flow, and Cora's responses.
//  Uses SwiftData for persistence and async/await instead of DispatchQueue completion handlers.
//
import Foundation
import Combine
import SwiftData

@MainActor
class ChatViewModel: ObservableObject {

    @Published var messages: [ChatMessage] = []
    @Published var isTyping: Bool = false
    @Published var currentQuickReplies: [String] = []
    @Published var errorMessage: String?

    private var modelContext: ModelContext?
    private var currentSessionId: String = UUID().uuidString
    var currentFlow: ConversationFlow?

    init() {}

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        restoreOrCreateSession()
    }

    private func restoreOrCreateSession() {
        guard let modelContext else { return }
        // Find any incomplete conversation flow
        let descriptor = FetchDescriptor<ConversationFlow>(
            predicate: #Predicate { $0.isComplete == false }
        )
        guard let activeFlow = try? modelContext.fetch(descriptor).first else { return }

        currentSessionId = activeFlow.sessionId
        currentFlow = activeFlow

        // Reload messages for this session
        let sessionId = activeFlow.sessionId
        let msgDescriptor = FetchDescriptor<ChatMessage>(
            predicate: #Predicate { $0.sessionId == sessionId },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        messages = (try? modelContext.fetch(msgDescriptor)) ?? []
        restoreQuickRepliesForCurrentStep()
    }

    func startDailyCheckIn() {
        guard let modelContext else { return }
        let flow = ConversationFlow(
            sessionId: currentSessionId,
            userId: 1,
            flowType: .dailyCheckIn,
            currentStep: .greeting
        )
        modelContext.insert(flow)
        try? modelContext.save()
        currentFlow = flow

        Task {
            await sendCoraMessage(
                content: "Hey there! Ready to check in? 🌟",
                quickReplies: ["Yes, let's do it!", "Not right now"]
            )
        }
    }

    func handleUserResponse(_ response: String) {
        saveUserMessage(content: response)
        guard let flow = currentFlow else { return }

        Task {
            await processResponse(response, flow: flow)
        }
    }

    private func processResponse(_ response: String, flow: ConversationFlow) async {
        switch flow.currentStep {

        case .greeting:
            if response.lowercased().contains("yes") || response.lowercased().contains("do it") {
                moveToNextStep(.askSleepQuality, flow: flow)
                await sendCoraMessage(
                    content: "Awesome! Let's start. How did you sleep last night? 😴",
                    quickReplies: SleepQuality.allCases.map { $0.rawValue }
                )
            } else {
                await sendCoraMessage(content: "No problem! Check in when you're ready 💙")
                completeConversation(flow: flow)
            }

        case .askSleepQuality:
            flow.tempData["sleepQuality"] = response
            moveToNextStep(.askSleepHours, flow: flow)
            await sendCoraMessage(content: getSleepQualityResponse(response))
            await sendCoraMessage(
                content: "And how many hours did you get? 🌙",
                quickReplies: SleepHours.allCases.map { $0.rawValue }
            )

        case .askSleepHours:
            flow.tempData["sleepHours"] = response
            moveToNextStep(.askWater, flow: flow)
            await sendCoraMessage(content: getSleepHoursResponse(response))
            await sendCoraMessage(
                content: "Thanks for sharing! Now, water time — how many glasses have you had today? 💧",
                quickReplies: WaterIntake.allCases.map { $0.rawValue }
            )

        case .askWater:
            flow.tempData["water"] = response
            moveToNextStep(.askStress, flow: flow)
            await sendCoraMessage(content: getWaterResponse(response))
            await sendCoraMessage(
                content: "Nice! Quick stress check — how are you feeling today?",
                quickReplies: StressLevel.allCases.map { $0.rawValue }
            )

        case .askStress:
            flow.tempData["stress"] = response
            moveToNextStep(.askEnergy, flow: flow)
            await sendCoraMessage(content: getStressResponse(response))
            await sendCoraMessage(
                content: "I hear you. Now, energy check — how are your levels today? ⚡",
                quickReplies: EnergyLevel.allCases.map { $0.rawValue }
            )

        case .askEnergy:
            flow.tempData["energy"] = response
            moveToNextStep(.askActivity, flow: flow)
            await sendCoraMessage(content: getEnergyResponse(response))
            await sendCoraMessage(
                content: "Got it! Last thing — how active have you been today? 🏃‍♀️",
                quickReplies: ActivityLevel.allCases.map { $0.rawValue }
            )

        case .askActivity:
            flow.tempData["activity"] = response
            moveToNextStep(.completion, flow: flow)
            await sendCoraMessage(content: getActivityResponse(response))
            await completeCheckIn(flow: flow)

        default:
            break
        }
    }

    private func completeCheckIn(flow: ConversationFlow) async {
        guard let modelContext else { return }
        let checkIn = DailyCheckIn(
            userId: 1,
            date: Date(),
            sleepQuality: SleepQuality(rawValue: flow.tempData["sleepQuality"] ?? ""),
            sleepHours: SleepHours(rawValue: flow.tempData["sleepHours"] ?? ""),
            waterGlasses: WaterIntake(rawValue: flow.tempData["water"] ?? ""),
            stressLevel: StressLevel(rawValue: flow.tempData["stress"] ?? ""),
            energyLevel: EnergyLevel(rawValue: flow.tempData["energy"] ?? ""),
            activityLevel: ActivityLevel(rawValue: flow.tempData["activity"] ?? ""),
            isComplete: true
        )
        modelContext.insert(checkIn)

        do {
            let streak = try updateUserStreak(modelContext: modelContext)
            try modelContext.save()
            await sendCoraMessage(
                content: "Perfect, you're all done for the day! You're on a \(streak)-day streak! 🎉 See you tomorrow!"
            )
            completeConversation(flow: flow)
        } catch {
            await sendCoraMessage(content: "I had a little trouble saving your check-in. 💙")
        }
    }

    private func updateUserStreak(modelContext: ModelContext) throws -> Int {
        var descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == 1 })
        descriptor.fetchLimit = 1

        let user: User
        if let existing = try modelContext.fetch(descriptor).first {
            user = existing
        } else {
            let newUser = User(id: 1, name: "User")
            modelContext.insert(newUser)
            user = newUser
        }

        let calendar = Calendar.current
        var newStreak = 1

        if let lastCheckIn = user.lastCheckInDate {
            let lastStart = calendar.startOfDay(for: lastCheckIn)
            let todayStart = calendar.startOfDay(for: Date())
            let days = calendar.dateComponents([.day], from: lastStart, to: todayStart).day ?? 0
            if days == 1 { newStreak = user.currentStreak + 1 }
            else if days > 1 { newStreak = 1 }
            else { newStreak = user.currentStreak }
        }

        user.currentStreak = newStreak
        user.longestStreak = max(user.longestStreak, newStreak)
        user.lastCheckInDate = Date()
        return newStreak
    }

    private func moveToNextStep(_ step: ConversationStep, flow: ConversationFlow) {
        flow.currentStep = step
        currentFlow = flow
        try? modelContext?.save()
    }

    private func completeConversation(flow: ConversationFlow) {
        flow.isComplete = true
        flow.completedAt = Date()
        currentFlow = nil
        try? modelContext?.save()
    }

    private func sendCoraMessage(content: String, quickReplies: [String]? = nil) async {
        isTyping = true
        try? await Task.sleep(for: .seconds(1.2))
        isTyping = false

        let message = ChatMessage(
            sessionId: currentSessionId,
            sender: .cora,
            content: content,
            messageType: quickReplies != nil ? .quickReply : .text,
            quickReplies: quickReplies ?? []
        )
        modelContext?.insert(message)
        try? modelContext?.save()
        messages.append(message)
        currentQuickReplies = quickReplies ?? []
    }

    private func saveUserMessage(content: String) {
        let message = ChatMessage(
            sessionId: currentSessionId,
            sender: .user,
            content: content
        )
        modelContext?.insert(message)
        try? modelContext?.save()
        messages.append(message)
        currentQuickReplies = []
    }


    func restoreQuickRepliesForCurrentStep() {
        guard let flow = currentFlow else { return }
        switch flow.currentStep {
        case .greeting:       currentQuickReplies = ["Yes, let's do it!", "Not right now"]
        case .askSleepQuality: currentQuickReplies = SleepQuality.allCases.map { $0.rawValue }
        case .askSleepHours:   currentQuickReplies = SleepHours.allCases.map { $0.rawValue }
        case .askWater:        currentQuickReplies = WaterIntake.allCases.map { $0.rawValue }
        case .askStress:       currentQuickReplies = StressLevel.allCases.map { $0.rawValue }
        case .askEnergy:       currentQuickReplies = EnergyLevel.allCases.map { $0.rawValue }
        case .askActivity:     currentQuickReplies = ActivityLevel.allCases.map { $0.rawValue }
        default:               currentQuickReplies = []
        }
    }

    private func getSleepQualityResponse(_ quality: String) -> String {
        switch SleepQuality(rawValue: quality) {
        case .refreshed: return "That's wonderful! Good sleep makes such a difference ✨"
        case .okay:      return "Fair enough. At least you got some rest 😊"
        case .groggy:    return "I hear you. Some nights are harder than others 💙"
        default:         return "Thanks for sharing how you slept! 😴"
        }
    }

    private func getSleepHoursResponse(_ hours: String) -> String {
        switch SleepHours(rawValue: hours) {
        case .eightPlus, .sevenToEight: return "That's really good! Right in the sweet spot ✨"
        case .sixToSeven:               return "Not too bad, but maybe a little more rest tonight? 🌙"
        case .lessThanSix:              return "I understand. Hope you can catch up on rest soon 💙"
        default:                        return "Got it, thanks for tracking your rest! 🌙"
        }
    }

    private func getWaterResponse(_ water: String) -> String {
        switch WaterIntake(rawValue: water) {
        case .veryHigh: return "Wow! You're absolutely crushing hydration today!"
        case .high:     return "Great job! You're keeping yourself well hydrated!"
        case .moderate: return "Nice! You're on the right track 💙"
        case .low:      return "No worries! There's still time to catch up. Your body will thank you 💧"
        default:        return "Thanks for letting me know! 💧"
        }
    }

    private func getStressResponse(_ stress: String) -> String {
        switch StressLevel(rawValue: stress) {
        case .calm:     return "That's so good to hear! Keep riding that peaceful wave 😌✨"
        case .moderate: return "I hear you. Remember, you're doing your best. Take a deep breath. 🌬️"
        case .high:     return "I'm sorry it's a tough day. One step at a time, you've got this. 💙"
        default:        return "Thanks for checking in with your stress levels. 💙"
        }
    }

    private func getEnergyResponse(_ energy: String) -> String {
        switch EnergyLevel(rawValue: energy) {
        case .high:   return "Love that! You're crushing it today 🚀"
        case .medium: return "Steady and balanced — that's great! ⚡"
        case .low:    return "Listen to your body today. It's okay to take it slow. 🛌"
        default:      return "Thanks for sharing your energy levels! ⚡"
        }
    }

    private func getActivityResponse(_ activity: String) -> String {
        switch ActivityLevel(rawValue: activity) ?? .none {
        case .high:   return "Wow, look at you go! Movement is such a great mood booster. 🚀"
        case .medium: return "Nice job getting some movement in today! ✨"
        case .low, .none: return "That's okay! Rest is just as important as movement. 💙"
        }
    }
}
