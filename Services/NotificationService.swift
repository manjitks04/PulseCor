//
//  NotificationService.swift
//  PulseCor
//
//  Handles alerts within app (medication, check-ins, reflections, foreground suppression logic)
import UserNotifications
import Foundation

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let id = notification.request.identifier
        if id.hasPrefix("medication-") || id.hasPrefix("snooze-") || id == "weekly-reflection" {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([])
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let id = response.notification.request.identifier
        let userInfo = response.notification.request.content.userInfo
        
        if (id.hasPrefix("medication-") || id.hasPrefix("snooze-")),
           let medId = userInfo["medicationId"] as? String,
           let name = userInfo["medicationName"] as? String,
           let dosage = userInfo["dosage"] as? String,
           let time = userInfo["scheduledTime"] as? String {

            UserDefaults.standard.set(medId,forKey: "pendingMedId")
            UserDefaults.standard.set(name,forKey: "pendingMedName")
            UserDefaults.standard.set(dosage,forKey: "pendingMedDosage")
            UserDefaults.standard.set(time,forKey: "pendingMedTime")
        }

        Task { @MainActor in
            if id == "daily-checkin" || id == "weekly-reflection" {
                NavigationManager.shared.pendingTab = .cora
            } else if id.hasPrefix("medication-") || id.hasPrefix("snooze-") {
                if let medId = userInfo["medicationId"] as? String,
                   let medName = userInfo["medicationName"] as? String,
                   let dosage = userInfo["dosage"] as? String,
                   let time = userInfo["scheduledTime"] as? String {
                    NavigationManager.shared.pendingMedication = PendingMedication(
                        id: medId,
                        name: medName,
                        dosage: dosage,
                        time: time
                    )
                }
                NavigationManager.shared.pendingTab = .home
            }
        }

        completionHandler()
    }


    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("NotificationService: authorization error — \(error)")
            return false
        }
    }

    func scheduleMedicationReminders(medicationId: String, medicationName: String, dosage: String, times: [String]) {
        let center = UNUserNotificationCenter.current()
        for time in times {
            let components = time.split(separator: ":")
            guard components.count == 2,
                  let hour = Int(components[0]),
                  let minute = Int(components[1]) else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Here's your medication reminder 💊"
            content.body = "\(medicationName) · \(dosage)"
            content.sound = .default
            content.userInfo = [
                "medicationId": medicationId,
                "medicationName": medicationName,
                "dosage": dosage,
                "scheduledTime": time
            ]

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "medication-\(medicationId)-\(time)",
                content: content,
                trigger: trigger
            )
            Task {
                do {
                    try await center.add(request)
                } catch {
                    print("NotificationService: error scheduling medication — \(error)")
                }
            }
        }
    }

    func cancelMedicationNotifications(medicationId: String) {
        Task {
            let center = UNUserNotificationCenter.current()
            let requests = await center.pendingNotificationRequests()
            let identifiers = requests
                .filter { $0.identifier.hasPrefix("medication-\(medicationId)-") }
                .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    func snoozeMedicationReminder(medicationId: String, medicationName: String, dosage: String) {
        let content = UNMutableNotificationContent()
        content.title = "💊 Medication Reminder"
        content.body = "\(medicationName), \(dosage)"
        content.sound = .default
        content.userInfo = [
            "medicationId": medicationId,
            "medicationName": medicationName,
            "dosage": dosage,
            "scheduledTime": ""
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 120, repeats: false)
        let request = UNNotificationRequest(identifier: "snooze-\(medicationId)", content: content, trigger: trigger)
        Task {
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("NotificationService: error scheduling snooze — \(error)")
            }
        }
    }

    func scheduleDailyCheckIn(hour: Int, minute: Int, isAM: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])

        let content = UNMutableNotificationContent()
        content.title = "Daily Check-in"
        content.body = "Time to check in with Cora! 🌟"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-checkin", content: content, trigger: trigger)
        Task {
            do {
                try await center.add(request)
            } catch {
                print("NotificationService: error scheduling daily check-in — \(error)")
            }
        }
    }

    func cancelDailyCheckIn() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])
    }

    func scheduleWeeklyReflection(hour: Int, minute: Int, isAM: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weekly-reflection"])

        let content = UNMutableNotificationContent()
        content.title = "Weekly Reflection"
        content.body = "Time to reflect on your week with Cora 🌸"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-reflection", content: content, trigger: trigger)
        Task {
            do {
                try await center.add(request)
            } catch {
                print("NotificationService: error scheduling weekly reflection — \(error)")
            }
        }
    }

    func cancelWeeklyReflection() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly-reflection"])
    }
}
