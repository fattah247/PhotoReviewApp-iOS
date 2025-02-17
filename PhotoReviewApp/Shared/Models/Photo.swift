//
//  Photo.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 06/02/25.
//
import Foundation
import Photos
import UIKit

struct Photo: Identifiable, Equatable {
    let id: String
//    let asset: PHAsset
    var image: UIImage?
    let creationDate: Date?
    let fileSize: Int64
}

// Enums.swift
enum RepeatInterval: String, CaseIterable {
    case daily, weekly, monthly, never
}

enum PhotoSortOption: String, CaseIterable {
    case random, newestFirst, oldestFirst
    
    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .newestFirst: return [NSSortDescriptor(key: "creationDate", ascending: false)]
        case .oldestFirst: return [NSSortDescriptor(key: "creationDate", ascending: true)]
        case .random: return []
        }
    }
}

enum Weekday: Int, CaseIterable {
    case sun = 1, mon, tue, wed, thu, fri, sat
}
