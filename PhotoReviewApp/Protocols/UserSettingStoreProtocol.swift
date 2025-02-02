//
//  UserSettingStoreProtocol.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import Foundation

protocol UserSettingsStoreProtocol {
    var notificationTime: Date { get set }
    var repeatInterval: RepeatInterval { get set }
    var selectedDays: [Weekday] { get set }
    var isNotificationsEnabled: Bool { get set }
    
    // Add these properties so that SettingsViewModel can use them.
    var selectedWeeklyDays: [Weekday] { get set }
    var selectedMonthlyDays: [Int] { get set }
    
    func loadSettings()
    func saveSettings()
}

