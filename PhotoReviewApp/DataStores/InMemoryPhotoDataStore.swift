//
//  InMemoryPhotoDataStore.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI
import Foundation

class InMemoryPhotoDataStore: ObservableObject, PhotoDataStoreProtocol {
    @Published private(set) var records: [PhotoReviewRecord] = []
    
    func saveRecord(_ record: PhotoReviewRecord) {
        records.append(record)
    }

    func fetchAllRecords() -> [PhotoReviewRecord] {
        records
    }
}

