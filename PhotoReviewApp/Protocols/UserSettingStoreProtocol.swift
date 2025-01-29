//
//  UserSettingStoreProtocol.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import Foundation

protocol UserSettingsStoreProtocol {
    var reviewHour: Int { get set }
    var reviewMinute: Int { get set }
    
    func loadSettings()
    func saveSettings()
}

