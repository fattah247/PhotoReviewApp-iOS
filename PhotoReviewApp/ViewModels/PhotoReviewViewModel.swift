//
//  PhotoReviewViewModel.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//


import SwiftUI
import Photos

class PhotoReviewViewModel: ObservableObject {
    @Published var dailyPhotos: [PHAsset] = []
    @Published var currentIndex: Int = 0
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String? = nil
    
    private let photoLibraryManager: PhotoLibraryManager
    private let dailySelectionManager: DailyPhotoSelectionManager
    private let photoDataStore: PhotoDataStoreProtocol

    init(photoLibraryManager: PhotoLibraryManager,
         dailySelectionManager: DailyPhotoSelectionManager,
         photoDataStore: PhotoDataStoreProtocol) {
        self.photoLibraryManager = photoLibraryManager
        self.dailySelectionManager = dailySelectionManager
        self.photoDataStore = photoDataStore
    }
    
    func requestPhotoLibraryAccess() {
        photoLibraryManager.requestPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.photoLibraryManager.fetchPhotos()
            } else {
                // Handle denial - set up an error message or provide in-app instructions
                self.errorMessage = "Photo library access denied. Please grant access in Settings."
                self.showErrorAlert = true
            }
        }
    }
    
    func generateDailyPhotos() {
        let allAssets = photoLibraryManager.allPhotos
        dailyPhotos = dailySelectionManager.pickRandomPhotos(from: allAssets, count: 10)
        currentIndex = 0
    }
    
    @MainActor
    func generateNewPhotos() {
        let allAssets = photoLibraryManager.allPhotos
        if allAssets.isEmpty {
            print("No assets available in the photo library.")
        } else {
            // Pick new random photos
            dailyPhotos = dailySelectionManager.pickRandomPhotos(from: allAssets, count: 10)
            currentIndex = 0  // Reset to the first photo
            
            // Manually notify about the change
            objectWillChange.send()
            // Debugging: Check the new photos
            print("Generated new photos: \(dailyPhotos)")
        }
    }
    
    @MainActor func deleteCurrentPhoto() {
        guard currentIndex < dailyPhotos.count else { return }
        let asset = dailyPhotos[currentIndex]
        
        // Move to the next photo immediately
        if currentIndex + 1 < dailyPhotos.count {
            let nextIndex = currentIndex + 1 < dailyPhotos.count ? currentIndex + 1 : max(0, dailyPhotos.count - 1)
            
            // Proceed to delete the photo asynchronously
            photoLibraryManager.deletePhoto(asset) { [weak self] success in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if success {
                        // Record the action and remove the photo
                        self.recordAction(for: asset, action: .deleted)
                        self.dailyPhotos.remove(at: self.currentIndex)
                        
                        // If no photos are left, generate new ones and reset currentIndex to 0
                        if self.dailyPhotos.isEmpty {
                            print("No photos left, generating new photos...")
                            self.generateNewPhotos()
                            self.currentIndex = 0  // Reset to the first photo
                        } else {
                            // Otherwise, update currentIndex to the next valid photo
                            self.currentIndex = nextIndex
                        }
                    } else {
                        self.errorMessage = "Failed to delete photo."
                        self.showErrorAlert = true
                    }
                }
            }
            
        } else {
            // If no photos left, generate new ones and reset currentIndex to 0
            print("No photos left, generating new photos...")
            self.generateNewPhotos()
            self.currentIndex = 0  // Reset to the first photo
        }
    }

    @MainActor func keepCurrentPhoto() {
        guard currentIndex < dailyPhotos.count else { return }
        let asset = dailyPhotos[currentIndex]
        
        // Record the action for kept photo
        recordAction(for: asset, action: .kept)
        
        // Move to the next photo immediately
        if currentIndex + 1 < dailyPhotos.count {
            self.currentIndex += 1
        } else {
            // If no photos left, generate new ones and reset currentIndex to 0
            print("No photos left, generating new photos...")
            self.generateNewPhotos()
            self.currentIndex = 0  // Reset to the first photo
        }
    }


    func moveToPreviousPhoto() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    private func recordAction(for asset: PHAsset, action: UserAction) {
        let record = PhotoReviewRecord(
            assetIdentifier: asset.localIdentifier,
            userAction: action
        )
        photoDataStore.saveRecord(record)
    }
}

