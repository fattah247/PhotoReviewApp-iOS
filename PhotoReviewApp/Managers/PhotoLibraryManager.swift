//
//  PhotoLibraryManager.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import Photos
import SwiftUI

class PhotoLibraryManager: ObservableObject {
    @Published var allPhotos: [PHAsset] = []
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
    
    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        DispatchQueue.main.async {
            self.allPhotos = assets
        }
    }
    
    func deletePhotoAsync(_ asset: PHAsset) async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }, completionHandler: { success, error in
                if let error = error {
                    print("Error deleting photo: \(error)")
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: success)
                }
            })
        }
    }
}
