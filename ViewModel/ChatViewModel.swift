//
//  ChatViewModel.swift
//  PulseCor
//
//Manages chat interface state, conversation flow, and Cora's responses.
//
//

import Foundation
import Combine
import SQLite

class ChatViewModel: ObservableObject {
    
    //Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var isTyping: Bool = false
    @Published var currentQuickReplies: [String] = []
    @Published var errorMessage: String?
    
    // Properties
    private let databaseService: DatabaseService
    private var currentSessionId: String
    private var currentFlow: ConversationFlow?
    private var cancellables = Set<AnyCancellable>()
    
    // Initialisation
    init(databaseService: DatabaseService = .shared) {
        self.databaseService = databaseService
        
        do {
            if let activeFlow = try databaseService.getActiveConversation() {
                self.currentSessionId = activeFlow.sessionId
                self.currentFlow = activeFlow
                loadExistingMessages()
            } else {
                self.currentSessionId = UUID().uuidString
            }
        } catch {
            print("Failed to load active conversation: \(error)")
            self.currentSessionId = UUID().uuidString
        }
        if currentFlow != nil {
                loadExistingMessages()
            }
    }
    
    func startDailyCheckIn() {
        let flow = ConversationFlow(
            sessionId: currentSessionId,
            userId: 1,
            flowType: .dailyCheckIn,
            currentStep: .greeting,
            isComplete: false
        )
        
        do {
            try databaseService.updateConversationFlow(
                sessionId: flow.sessionId,
                currentStep: flow.currentStep,
                tempData: flow.tempData
            )
            currentFlow = flow
            
            sendCoraMessage(
                content: "Hey there! Ready to check in? 🌟",
                quickReplies: ["Yes, let's do it!", "Not right now"]
            )
        } catch {
            handleError(PulseCorError.saveFailed("Could not start conversation"))
        }
    }
    
    func handleUserResponse(_ response: String) {
        saveUserMessage(content: response)
        
        guard var flow = currentFlow else {
            handleError(PulseCorError.sessionNotFound)
            return
        }
        
        processResponse(response, flow: &flow)
    }
    
    //Conversation Logic
    private func processResponse(_ response: String, flow: inout ConversationFlow) {
        switch flow.currentStep {
            
        case .greeting:
            if response.lowercased().contains("yes") || response.lowercased().contains("do it") {
                moveToNextStep(.askSleepQuality, flow: &flow)
                sendCoraMessage(
                    content: "Awesome! Let's start. How did you sleep last night? 😴",
                    quickReplies: SleepQuality.allCases.map { $0.rawValue }
                )
            } else {
                sendCoraMessage(content: "No problem! Check in when you're ready 💙")
                completeConversation(flow: &flow)
            }
            
        case .askSleepQuality:
            flow.tempData["sleepQuality"] = response
            moveToNextStep(.askSleepHours, flow: &flow)
            sendCoraMessage(content: getSleepQualityResponse(response))
            delayCoraAction {
                self.sendCoraMessage(
                    content: "And how many hours did you get? 🌙",
                    quickReplies: SleepHours.allCases.map { $0.rawValue }
                )
            }
            
        case .askSleepHours:
            flow.tempData["sleepHours"] = response
            moveToNextStep(.askWater, flow: &flow)
            sendCoraMessage(content: getSleepHoursResponse(response))
            delayCoraAction {
                self.sendCoraMessage(
                    content: "Thanks for sharing! Now, water time—how many glasses have you had today? 💧",
                    quickReplies: WaterIntake.allCases.map { $0.rawValue }
                )
            }
            
        case .askWater:
            flow.tempData["water"] = response
            moveToNextStep(.askStress, flow: &flow)
            sendCoraMessage(content: getWaterResponse(response))
            delayCoraAction {
                self.sendCoraMessage(
                    content: "Nice! Quick stress check—how are you feeling today?",
                    quickReplies: StressLevel.allCases.map { $0.rawValue }
                )
            }
            
        case .askStress:
            flow.tempData["stress"] = response
            moveToNextStep(.askEnergy, flow: &flow)
            sendCoraMessage(content: getStressResponse(response))
            delayCoraAction {
                self.sendCoraMessage(
                    content: "I hear you. Now, energy check—how are your levels today? ⚡",
                    quickReplies: EnergyLevel.allCases.map { $0.rawValue }
                )
            }
            
        case .askEnergy:
            flow.tempData["energy"] = response
            moveToNextStep(.askActivity, flow: &flow)
            sendCoraMessage(content: getEnergyResponse(response))
            delayCoraAction {
                self.sendCoraMessage(
                    content: "Got it! Last thing—how active have you been today? 🏃‍♀️",
                    quickReplies: ActivityLevel.allCases.map { $0.rawValue }
                )
            }

        case .askActivity:
            flow.tempData["activity"] = response
            moveToNextStep(.completion, flow: &flow)
            // You can add a specific helper for this too!
            sendCoraMessage(content: getActivityResponse(response))
            delayCoraAction {
                self.completeCheckIn()
            }
            
        default:
            handleError(PulseCorError.invalidStepTransition)
        }
    }
    
    //Data Completion
    private func completeCheckIn() {
        guard var flow = currentFlow else { return }
        let checkIn = DailyCheckIn(
            userId: 1,
            date: Date(),
            sleepQuality: mapToSleepQuality(flow.tempData["sleepQuality"] ?? ""),
            sleepHours: mapToSleepHours(flow.tempData["sleepHours"] ?? ""),
            waterGlasses: mapToWaterIntake(flow.tempData["water"] ?? ""),
            stressLevel: mapToStressLevel(flow.tempData["stress"] ?? ""),
            energyLevel: mapToEnergyLevel(flow.tempData["energy"] ?? ""),
            activityLevel: ActivityLevel(rawValue: flow.tempData["activity"] ?? ""),
            isComplete: true
        )
        
        do {
            _ = try databaseService.createCheckIn(checkIn: checkIn)
            try updateUserStreak()
            
            let streak = try databaseService.getUser()?.currentStreak ?? 1
            sendCoraMessage(content: "Perfect! You're on a \(streak)-day streak! 🎉 See you tomorrow!")
            
            completeConversation(flow: &flow)
        } catch {
            handleError(PulseCorError.saveFailed("Check-in record failed"))
        }
    }

    //Helpers
    private func mapToSleepQuality(_ str: String) -> SleepQuality? { SleepQuality(rawValue: str) }
    private func mapToSleepHours(_ str: String) -> SleepHours? { SleepHours(rawValue: str) }
    private func mapToStressLevel(_ str: String) -> StressLevel? { StressLevel(rawValue: str) }
    private func mapToEnergyLevel(_ str: String) -> EnergyLevel? { EnergyLevel(rawValue: str) }
    private func mapToWaterIntake(_ str: String) -> WaterIntake? { WaterIntake(rawValue: str) }

    //Scripts
    private func getSleepQualityResponse(_ quality: String) -> String {
        //converts string to the Enum to use the power of switch cases
        guard let qualityEnum = SleepQuality(rawValue: quality) else {
            return "Thanks for sharing how you slept! 😴"
        }
        
        switch qualityEnum {
        case .refreshed:
            return "That's wonderful! Good sleep makes such a difference ✨"
        case .okay:
            return "Fair enough. At least you got some rest 😊"
        case .groggy:
            return "I hear you. Some nights are harder than others 💙"
        }
    }

    private func getSleepHoursResponse(_ hours: String) -> String {
        guard let hoursEnum = SleepHours(rawValue: hours) else {
            return "Got it, thanks for tracking your rest! 🌙"
        }
        
        switch hoursEnum {
        case .eightPlus, .sevenToEight:
            return "That's really good! Right in the sweet spot ✨"
        case .sixToSeven:
            return "Not too bad, but maybe a little more rest tonight? 🌙"
        case .lessThanSix:
            return "I understand. Hope you can catch up on rest soon 💙"
        }
    }
    
    private func getWaterResponse(_ water: String) -> String {
        // Exact mapping from your requirements image
        switch water {
        case WaterIntake.veryHigh.rawValue: // "7+ glasses"
            return "Wow! You're absolutely crushing hydration today!"
        case WaterIntake.high.rawValue:     // "5-6 glasses"
            return "Great job! You're keeping yourself well hydrated!"
        case WaterIntake.moderate.rawValue: // "3-4 glasses"
            return "Nice! You're on the right track 💙"
        case WaterIntake.low.rawValue:      // "0-2 glasses"
            return "No worries! There's still time to catch up. Your body will thank you 💧"
        default:
            return "Thanks for letting me know! 💧"
        }
    }

    private func getStressResponse(_ stress: String) -> String {
        guard let stressEnum = StressLevel(rawValue: stress) else {
            return "Thanks for checking in with your stress levels. 💙"
        }
        
        switch stressEnum {
        case .calm:
            return "That's so good to hear! Keep riding that peaceful wave 😌✨"
        case .moderate:
            return "I hear you. Remember, you're doing your best. Take a deep breath. 🌬️"
        case .high:
            return "I'm sorry it's a tough day. One step at a time, you've got this. 💙"
        }
    }

    private func getEnergyResponse(_ energy: String) -> String {
        guard let energyEnum = EnergyLevel(rawValue: energy) else {
            return "Thanks for sharing your energy levels! ⚡"
        }
        
        switch energyEnum {
        case .high:
            return "Love that! You're crushing it today 🚀"
        case .medium:
            return "Steady and balanced—that's great! ⚡"
        case .low:
            return "Listen to your body today. It's okay to take it slow. 🛌"
        }
    }
    
    private func getActivityResponse(_ activity: String) -> String {
        switch ActivityLevel(rawValue: activity) ?? .none {
        case .high:
            return "Wow, look at you go! Movement is such a great mood booster. 🚀"
        case .medium:
            return "Nice job getting some movement in today! ✨"
        case .low, .none:
            return "That's okay! Rest is just as important as movement. 💙"
        }
    }

    // Messaging & System Logic
    private func handleError(_ error: PulseCorError) {
        print("PulseCor Error: \(error.localizedDescription)")
        self.errorMessage = error.errorDescription
        sendCoraMessage(content: error.errorDescription ?? "I'm having a little trouble right now. 💙")
    }
    
    private func delayCoraAction(action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: action)
    }
    
    private func moveToNextStep(_ nextStep: ConversationStep, flow: inout ConversationFlow) {
        flow.currentStep = nextStep
        currentFlow = flow
        do {
            try databaseService.updateConversationFlow(sessionId: flow.sessionId, currentStep: nextStep, tempData: flow.tempData)
        } catch {
            handleError(PulseCorError.saveFailed("Could not update progress"))
        }
    }
    
    private func completeConversation(flow: inout ConversationFlow) {
        do {
            try databaseService.completeConversationFlow(sessionId: flow.sessionId)
            currentFlow = nil
        } catch {
            handleError(PulseCorError.saveFailed("Session closure failed"))
        }
    }
    
    private func sendCoraMessage(content: String, quickReplies: [String]? = nil) {
        isTyping = true
        delayCoraAction {
            self.isTyping = false
            let message = ChatMessage(sessionId: self.currentSessionId, sender: .cora, content: content, messageType: quickReplies != nil ? .quickReply : .text, quickReplies: quickReplies)
            do {
                _ = try self.databaseService.saveMessage(message: message)
                self.messages.append(message)
                self.currentQuickReplies = quickReplies ?? []
            } catch {
                self.handleError(PulseCorError.saveFailed("Message history error"))
            }
        }
    }
    
    private func saveUserMessage(content: String) {
        let message = ChatMessage(sessionId: currentSessionId, sender: .user, content: content)
        do {
            _ = try databaseService.saveMessage(message: message)
            messages.append(message)
            currentQuickReplies = []
        } catch {
            handleError(PulseCorError.saveFailed("User message history error"))
        }
    }
    
    private func loadExistingMessages() {
        do {
            messages = try databaseService.getMessages(sessionId: currentSessionId)
        } catch {
            handleError(PulseCorError.fetchFailed("Conversation history unavailable"))
        }
    }

    private func updateUserStreak() throws {
        guard let user = try databaseService.getUser() else { return }
        let calendar = Calendar.current
        var newStreak = 1
        if let lastCheckIn = user.lastCheckInDate {
            let days = calendar.dateComponents([.day], from: lastCheckIn, to: Date()).day ?? 0
            if days == 1 { newStreak = user.currentStreak + 1 }
            else if days > 1 { newStreak = 1 }
            else { newStreak = user.currentStreak }
        }
        try databaseService.updateUserStreak(userId: user.id, currentStreak: newStreak, longestStreak: max(user.longestStreak, newStreak), lastCheckIn: Date())
    }
}


