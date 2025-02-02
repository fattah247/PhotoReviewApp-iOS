//
//  NotificationTypes.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//

import Foundation

enum RepeatInterval: String, CaseIterable, Identifiable, Codable {
    case daily, weekly, monthly
    var id: Self { self }
}

enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case sun = 1, mon, tue, wed, thu, fri, sat
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .sun: return "Sunday"
        case .mon: return "Monday"
        case .tue: return "Tuesday"
        case .wed: return "Wednesday"
        case .thu: return "Thursday"
        case .fri: return "Friday"
        case .sat: return "Saturday"
        }
    }
}
