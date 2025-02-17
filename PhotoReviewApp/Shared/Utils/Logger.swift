//
//  Logger.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 04/02/25.
//
import Foundation
import os.log

struct AppLogger {
    static let general = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "General"
    )
    
    static let coreData = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "CoreData"
    )
}
