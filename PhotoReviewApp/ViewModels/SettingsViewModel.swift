//
//  SettingsViewModel.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//


import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var notificationTime: Date
    @Published var repeatInterval: RepeatInterval
    @Published var selectedDays: [Weekday]
    @Published var isNotificationsEnabled: Bool
    
    @Published var selectedWeeklyDays: [Weekday] = []
    @Published var selectedMonthlyDays: [Int] = []
    
    private var userSettingsStore: UserSettingsStoreProtocol
    private var notificationManager: NotificationManager

    init(userSettingsStore: UserSettingsStoreProtocol,
         notificationManager: NotificationManager) {
        self.userSettingsStore = userSettingsStore
        self.notificationManager = notificationManager
        
        self.notificationTime = userSettingsStore.notificationTime
        self.repeatInterval = userSettingsStore.repeatInterval
        self.selectedDays = userSettingsStore.selectedDays
        self.isNotificationsEnabled = userSettingsStore.isNotificationsEnabled
        
        self.selectedWeeklyDays = userSettingsStore.selectedWeeklyDays
        self.selectedMonthlyDays = userSettingsStore.selectedMonthlyDays
    }
    
    func requestNotificationPermission() {
        notificationManager.requestNotificationPermissions()
    }
    
    func saveSettings() {
        userSettingsStore.notificationTime = notificationTime
        userSettingsStore.repeatInterval = repeatInterval
        userSettingsStore.selectedDays = selectedDays
        userSettingsStore.isNotificationsEnabled = isNotificationsEnabled
        userSettingsStore.saveSettings()
        userSettingsStore.selectedWeeklyDays = selectedWeeklyDays
        userSettingsStore.selectedMonthlyDays = selectedMonthlyDays
        
        if isNotificationsEnabled {
            notificationManager.scheduleNotifications(
                time: notificationTime,
                repeatInterval: repeatInterval,
                days: selectedDays
            )
        } else {
            notificationManager.cancelAllNotifications()
        }
    }
}

