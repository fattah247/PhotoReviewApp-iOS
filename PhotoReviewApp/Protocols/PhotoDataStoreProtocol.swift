//
//  PhotoDataStoreProtocol.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import Foundation

protocol PhotoDataStoreProtocol {
    func saveRecord(_ record: PhotoReviewRecord)
    func fetchAllRecords() -> [PhotoReviewRecord]
}
