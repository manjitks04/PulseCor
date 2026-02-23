//
//  NotificationService.swift
//  PulseCor
//
//
//to create and implement in order to recieve alerts within app (medication, check-ins, reflections, foreground suppression logic)

import UserNotifications
import Foundation

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService() // single instance used app-wide
    
    private override init() {
        super.init() //inherit from NSObject
        UNUserNotificationCenter.current().delegate = self //register as delegate so iOS routes notification events here
    }
    
    //called when a notification arrives while the app is open — decides whether to show it or suppress it
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let id = notification.request.identifier
        
        if id.hasPrefix("medication-") || id == "weekly-reflection" {
            // shows even when app is open
            completionHandler([.banner, .sound, .badge])
        } else {
            // suppress daily check-in app
            completionHandler([])
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Error requesting notification auth: \(error)")
            }
            DispatchQueue.main.async { // jump to main thread before updating UI
                completion(granted)
            }
        }
    }
    
    func scheduleMedicationReminders(medicationId: Int, medicationName: String, dosage: String, times: [String]) {
        let center = UNUserNotificationCenter.current()
        
        for time in times {
            let components = time.split(separator: ":")
            guard components.count == 2,
                  let hour = Int(components[0]),
                  let minute = Int(components[1]) else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "💊 Medication Reminder"
            content.body = "\(medicationName), \(dosage)"
            content.sound = .default
            content.userInfo = [ // extra data passed along with the notification for handling on tap
                "medicationId": medicationId,
                "medicationName": medicationName,
                "dosage": dosage,
                "scheduledTime": time
            ]
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "medication-\(medicationId)-\(time)" // unique ID per medication per time slot
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling medication notification: \(error)")
                }
            }
        }
    }
    
    func cancelMedicationNotifications(medicationId: Int) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.hasPrefix("medication-\(medicationId)-") }
                .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    // schedules a daily repeating check-in reminder at the user's chosen time

    func scheduleDailyCheckIn(hour: Int, minute: Int, isAM: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-in"
        content.body = "Time to check in with Cora! 🌟"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = isAM ? (hour == 12 ? 0 : hour) : (hour == 12 ? 12 : hour + 12)
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-checkin", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily check-in: \(error)")
            }
        }
    }
    
    func cancelDailyCheckIn() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])
    }
    
    // schedules a weekly reflection every Sunday at the user's chosen time
    func scheduleWeeklyReflection(hour: Int, minute: Int, isAM: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weekly-reflection"])
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Reflection"
        content.body = "Time to reflect on your week with Cora 🌸"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = isAM ? (hour == 12 ? 0 : hour) : (hour == 12 ? 12 : hour + 12)
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-reflection", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling weekly reflection: \(error)")
            }
        }
    }
    
    func cancelWeeklyReflection() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly-reflection"])
    }
    
    // called when the user taps a notification — routes them to the correct tab
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let id = response.notification.request.identifier
        
        if id == "daily-checkin" || id == "weekly-reflection" {
            NavigationManager.shared.pendingTab = .cora
        } else if id.hasPrefix("medication-") {
            NavigationManager.shared.pendingTab = .pulsecor
        }
        
        completionHandler()
    }
}
