//
//  NotificationManager.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
            if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
            }
        }
    }
    
    func scheduleNotifications(time: Date, repeatInterval: RepeatInterval, days: [Weekday]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        switch repeatInterval {
        case .daily:
            scheduleDailyNotification(hour: components.hour!, minute: components.minute!)
            
        case .weekly:
            for day in days {
                var dateComponents = DateComponents()
                dateComponents.hour = components.hour
                dateComponents.minute = components.minute
                dateComponents.weekday = day.rawValue
                scheduleNotification(components: dateComponents, repeats: true)
            }
            
        case .monthly:
            let day = calendar.component(.day, from: time)
            var dateComponents = DateComponents()
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute
            dateComponents.day = day
            scheduleNotification(components: dateComponents, repeats: true)
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func scheduleDailyNotification(hour: Int, minute: Int) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        scheduleNotification(components: dateComponents, repeats: true)
    }
    
    private func scheduleNotification(components: DateComponents, repeats: Bool) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        
        let content = UNMutableNotificationContent()
        content.title = "Photo Review Time"
        content.body = "It's time to review your photos!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
