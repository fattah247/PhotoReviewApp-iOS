//
//  UserDefaultsSettingsStore.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI
import Foundation

class UserDefaultsSettingsStore: UserSettingsStoreProtocol {
    private let hourKey = "reviewHour"
    private let minuteKey = "reviewMinute"
    
    var reviewHour: Int = 8   // default
    var reviewMinute: Int = 0 // default
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        let storedHour = defaults.integer(forKey: hourKey)
        // Check if storedHour is non-zero or else fallback to the default
        reviewHour = (storedHour == 0) ? 8 : storedHour
        
        let storedMinute = defaults.integer(forKey: minuteKey)
        // Similarly, you could do a check for minute if 0 is not your intended default
        reviewMinute = storedMinute
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(reviewHour, forKey: hourKey)
        defaults.set(reviewMinute, forKey: minuteKey)
    }
}

