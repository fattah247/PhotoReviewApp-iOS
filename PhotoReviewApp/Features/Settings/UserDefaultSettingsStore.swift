//
//  UserDefaultSettingsStore.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 05/02/25.
//
import Foundation

final class UserDefaultsSettingsStore: SettingsStoreProtocol {
    private let defaults = UserDefaults.standard
    
    var isNotificationsEnabled: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.isNotificationsEnabled) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.isNotificationsEnabled) }
    }
    
    var notificationTime: Date {
        get { defaults.object(forKey: Constants.UserDefaultsKeys.notificationTime) as? Date ?? Date() }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.notificationTime) }
    }
    
    var repeatInterval: RepeatInterval {
        get {
            guard let rawValue = defaults.string(forKey: Constants.UserDefaultsKeys.repeatInterval) else {
                return .daily
            }
            return RepeatInterval(rawValue: rawValue) ?? .daily
        }
        set { defaults.set(newValue.rawValue, forKey: Constants.UserDefaultsKeys.repeatInterval) }
    }
    
    var photoLimit: Int {
        get { defaults.integer(forKey: Constants.UserDefaultsKeys.photoLimit) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.photoLimit) }
    }
    
    var sortOption: PhotoSortOption {
        get {
            guard let rawValue = defaults.string(forKey: Constants.UserDefaultsKeys.sortOption) else {
                return .random
            }
            return PhotoSortOption(rawValue: rawValue) ?? .random
        }
        set { defaults.set(newValue.rawValue, forKey: Constants.UserDefaultsKeys.sortOption) }
    }
    
    var showDeletionConfirmation: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.showDeletionConfirmation) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.showDeletionConfirmation) }
    }
    
    func loadSettings() {
        // Synchronization handled through property observers
    }
    
    func saveSettings() {
        defaults.synchronize()
    }
}

//protocol UserSettingsStoreProtocol: ObservableObject {
//    var notificationTime: Date { get set }
//    var repeatInterval: RepeatInterval { get set }
//    var selectedWeeklyDays: [Weekday] { get set }
//    var selectedMonthlyDays: [Int] { get set }
//    var isNotificationsEnabled: Bool { get set }
//    var photoLimit: Int { get set }
//    var sortOption: PhotoSortOption { get set }
//    var showDeletionConfirmation: Bool { get set }
//    func loadSettings()
//    func saveSettings()
//}
//
//class UserDefaultsSettingsStore: UserSettingsStoreProtocol {
//    private let defaults = UserDefaults.standard
//    @Published var notificationTime: Date = Date()
//    @Published var repeatInterval: RepeatInterval = .daily
//    @Published var selectedWeeklyDays: [Weekday] = []
//    @Published var selectedMonthlyDays: [Int] = []
//    @Published var isNotificationsEnabled: Bool = false
//    @Published var photoLimit: Int = 10
//    @Published var sortOption: PhotoSortOption = .random
//    @Published var showDeletionConfirmation: Bool = true
//    
//    init() { loadSettings() }
//    
//    func loadSettings() {
//        notificationTime = defaults.object(forKey: "notificationTime") as? Date ?? Date()
//        repeatInterval = RepeatInterval(rawValue: defaults.string(forKey: "repeatInterval") ?? "") ?? .daily
//        selectedWeeklyDays = (defaults.array(forKey: "selectedWeeklyDays") as? [Int] ?? []).compactMap(Weekday.init)
//        selectedMonthlyDays = defaults.array(forKey: "selectedMonthlyDays") as? [Int] ?? []
//        isNotificationsEnabled = defaults.bool(forKey: "isNotificationsEnabled")
//        photoLimit = defaults.integer(forKey: "photoLimit")
//        sortOption = PhotoSortOption(rawValue: defaults.string(forKey: "sortOption") ?? "") ?? .random
//        showDeletionConfirmation = defaults.bool(forKey: "showDeletionConfirmation")
//    }
//    
//    func saveSettings() {
//        defaults.set(notificationTime, forKey: "notificationTime")
//        defaults.set(repeatInterval.rawValue, forKey: "repeatInterval")
//        defaults.set(selectedWeeklyDays.map { $0.rawValue }, forKey: "selectedWeeklyDays")
//        defaults.set(selectedMonthlyDays, forKey: "selectedMonthlyDays")
//        defaults.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
//        defaults.set(photoLimit, forKey: "photoLimit")
//        defaults.set(sortOption.rawValue, forKey: "sortOption")
//        defaults.set(showDeletionConfirmation, forKey: "showDeletionConfirmation")
//    }
//}
//
//enum RepeatInterval: String, CaseIterable, Identifiable {
//    case daily, weekly, monthly
//    var id: Self { self }
//}
//
//enum Weekday: Int, CaseIterable, Identifiable {
//    case sun = 1, mon, tue, wed, thu, fri, sat
//    var id: Self { self }
//    var displayName: String {
//        switch self {
//        case .sun: return "Sunday"
//        case .mon: return "Monday"
//        case .tue: return "Tuesday"
//        case .wed: return "Wednesday"
//        case .thu: return "Thursday"
//        case .fri: return "Friday"
//        case .sat: return "Saturday"
//        }
//    }
//}
//
