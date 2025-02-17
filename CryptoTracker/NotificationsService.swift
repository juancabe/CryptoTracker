//
//  NotificationsService.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 4/1/25.
//

import Foundation
import UserNotifications

class NotificationsService {

    static let instance = NotificationsService()  // Singleton instance

    private let nCenter = UNUserNotificationCenter.current()  // Notification center
    private var _notificationsEnabled = true  // Flag for notification status
    private init() {}

    // Check if notifications are enabled
    func notificationsEnabled() async -> Bool {
        await withCheckedContinuation { continuation in
            nCenter.getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    debugPrint("Authorizations enabled")
                    self._notificationsEnabled = true
                    continuation.resume(returning: true)
                } else {
                    debugPrint("Authorization status: \(settings.authorizationStatus.rawValue)")
                    self._notificationsEnabled = false
                    continuation.resume(returning: false)
                }
            }
        }
    }

    // Request notification authorization
    func requestAuthorization() async -> Bool {
        let authorized = await notificationsEnabled()
        if authorized {
            return authorized
        }

        // Request authorization asynchronously
        return await withCheckedContinuation { continuation in
            nCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else {
                    debugPrint(
                        "Request authorization failed: \(error?.localizedDescription ?? "Unknown error")"
                    )
                    continuation.resume(returning: false)
                }
            }
        }
    }

    // Add a notification
    func addNotification(identifier: String, title: String, subtitle: String, when: Date) {

        if !_notificationsEnabled { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        // Create a trigger for the specified date
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second], from: when),
            repeats: false
        )

        // Create the notification request
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger)

        // Add the notification request to the notification center
        nCenter.add(request) { error in
            if let error = error {
                debugPrint("Error scheduling notification: \(error.localizedDescription)")
            } else {
                debugPrint("Notification scheduled successfully")
            }
        }
    }

    // Remove a notification
    func removeNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            identifier
        ])
    }

}
