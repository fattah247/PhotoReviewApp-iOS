//
//  PhotoReviewRecord.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI

struct PhotoReviewRecord: Identifiable {
    let id: UUID
    let assetIdentifier: String
    let reviewDate: Date
    let userAction: UserAction
    
    init(
        id: UUID = UUID(),
        assetIdentifier: String,
        reviewDate: Date = Date(),
        userAction: UserAction
    ) {
        self.id = id
        self.assetIdentifier = assetIdentifier
        self.reviewDate = reviewDate
        self.userAction = userAction
    }
}

enum UserAction: String {
    case kept
    case deleted
}

