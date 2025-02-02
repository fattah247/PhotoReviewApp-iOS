//
//  UserDefaultsSettingsStore.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI
import Foundation

class UserDefaultsSettingsStore: UserSettingsStoreProtocol {
    private enum Keys {
        static let notificationTime = "notificationTime"
        static let repeatInterval = "repeatInterval"
        static let selectedDays = "selectedDays"
        static let isNotificationsEnabled = "isNotificationsEnabled"
        static let selectedWeeklyDays = "selectedWeeklyDays"
        static let selectedMonthlyDays = "selectedMonthlyDays"
    }
    
    var notificationTime: Date = Date()
    var repeatInterval: RepeatInterval = .daily
    var selectedDays: [Weekday] = []
    var isNotificationsEnabled: Bool = false
    
    var selectedWeeklyDays: [Weekday] = []
    var selectedMonthlyDays: [Int] = []
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        notificationTime = defaults.object(forKey: Keys.notificationTime) as? Date ?? Date()
        repeatInterval = RepeatInterval(rawValue: defaults.string(forKey: Keys.repeatInterval) ?? "") ?? .daily
        selectedDays = (defaults.array(forKey: Keys.selectedDays) as? [Int])?.compactMap { Weekday(rawValue: $0) } ?? []
        isNotificationsEnabled = defaults.bool(forKey: Keys.isNotificationsEnabled)
        
        selectedWeeklyDays = (defaults.array(forKey: Keys.selectedWeeklyDays) as? [Int])?
            .compactMap { Weekday(rawValue: $0) } ?? []
        selectedMonthlyDays = defaults.array(forKey: Keys.selectedMonthlyDays) as? [Int] ?? []
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(notificationTime, forKey: Keys.notificationTime)
        defaults.set(repeatInterval.rawValue, forKey: Keys.repeatInterval)
        defaults.set(selectedDays.map { $0.rawValue }, forKey: Keys.selectedDays)
        defaults.set(isNotificationsEnabled, forKey: Keys.isNotificationsEnabled)
        defaults.set(selectedWeeklyDays.map { $0.rawValue }, forKey: Keys.selectedWeeklyDays)
        defaults.set(selectedMonthlyDays, forKey: Keys.selectedMonthlyDays)
    }
}
