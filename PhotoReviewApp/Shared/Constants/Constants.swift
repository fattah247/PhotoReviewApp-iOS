//
//  Constants.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 04/02/25.
//
import Foundation

enum Constants {
    enum UserDefaultsKeys {
        static let isNotificationsEnabled = "isNotificationsEnabled"
        static let notificationTime = "notificationTime"
        static let repeatInterval = "repeatInterval"
        static let photoLimit = "photoLimit"
        static let sortOption = "sortOption"
        static let showDeletionConfirmation = "showDeletionConfirmation"
        static let selectedWeeklyDays = "selectedWeeklyDays"
        static let selectedMonthlyDay = "selectedMonthlyDay"
    }
    
    enum Notifications {
        static let reviewReminderID = "photo-review-reminder"
    }
    
    enum Widget {
        static let kind = "PhotoReviewStats"
    }
    
    enum DeepLink {
        static let scheme = "photoreviewapp"
        static let host = "photoreview.com"
    }
}
