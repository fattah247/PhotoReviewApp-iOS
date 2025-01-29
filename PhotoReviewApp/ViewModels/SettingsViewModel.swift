//
//  SettingsViewModel.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//


import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var reviewHour: Int
    @Published var reviewMinute: Int
    
    private var userSettingsStore: UserSettingsStoreProtocol
    private var notificationManager: NotificationManager

    init(userSettingsStore: UserSettingsStoreProtocol,
         notificationManager: NotificationManager) {
        self.userSettingsStore = userSettingsStore
        self.notificationManager = notificationManager
        
        self.reviewHour = userSettingsStore.reviewHour
        self.reviewMinute = userSettingsStore.reviewMinute
    }
    
    func requestNotificationPermission() {
        notificationManager.requestNotificationPermissions()
    }
    
    func scheduleNotification() {
        userSettingsStore.reviewHour = reviewHour
        userSettingsStore.reviewMinute = reviewMinute
        userSettingsStore.saveSettings()
        
        notificationManager.scheduleDailyNotification(hour: reviewHour, minute: reviewMinute)
    }
}
