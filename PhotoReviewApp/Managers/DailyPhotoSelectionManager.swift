//
//  DailyPhotoSelectionManager.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI
import Photos

class DailyPhotoSelectionManager {
    func pickRandomPhotos(from assets: [PHAsset], count: Int = 10) -> [PHAsset] {
        guard !assets.isEmpty else { return [] }
        let shuffled = assets.shuffled()
        return Array(shuffled.prefix(count))
    }
}

