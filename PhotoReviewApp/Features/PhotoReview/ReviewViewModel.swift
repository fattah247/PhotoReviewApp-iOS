//
//  ReviewViewModel.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//
import SwiftUI
import Photos
import CoreData
import OSLog

@MainActor
final class ReviewViewModel: ObservableObject {
    @Published var state: ViewState = .idle
    @Published var sortOption: PhotoSortOption = .random
    @Published var photoLimit = 10
    @Published var showSettings = false
    @Published var showDeleteAlert = false
    @Published var pendingDeletePhoto: Photo?
    
    private let settings: SettingsViewModel
    private let photoService: any PhotoLibraryServiceProtocol
    private let haptic: any HapticServiceProtocol
    private let analytics: any AnalyticsServiceProtocol
    private let bookmarkManager: any BookmarkManagerProtocol
    private let trashManager: any TrashManagerProtocol
    private var currentTask: Task<Void, Never>?
    
    init(
        photoService: any PhotoLibraryServiceProtocol,
        haptic: any HapticServiceProtocol,
        analytics: any AnalyticsServiceProtocol,
        bookmarkManager: any BookmarkManagerProtocol,
        trashManager: any TrashManagerProtocol,
        settings: SettingsViewModel
    ) {
        self.photoService = photoService
        self.haptic = haptic
        self.analytics = analytics
        self.settings = settings
        self.bookmarkManager = bookmarkManager
        self.trashManager = trashManager
    }
    
    func loadInitialPhotos() async {
        cancelCurrentTask()
        currentTask = Task {
            await processPhotos()
        }
    }
    
    private func processPhotos() async {
        state = .loading
        do {
            let assets = try await photoService.fetchAssets(options: .init(
                limit: photoLimit,
                sortDescriptors: sortOption.sortDescriptors
            ))
            
            let photos = await withTaskGroup(of: Photo?.self) { group in
                var result = [Photo]()
                
                for asset in assets {
                    group.addTask { [weak self] in
                        guard let self else { return nil }
                        return await self.processAsset(asset)
                    }
                }
                
                for await photo in group {
                    if let photo = photo {
                        result.append(photo)
                    }
                }
                return result
            }
            
            state = .loaded(photos.shuffled())
        } catch {
            state = .error(error)
        }
    }
    
    private func processAsset(_ asset: PHAsset) async -> Photo? {
        guard let image = await photoService.loadImage(
            for: asset,
            size: CGSize(width: 800, height: 800)
        ) else { return nil }
        
        return Photo(
            id: asset.localIdentifier,
            image: image,
            creationDate: asset.creationDate,
            fileSize: Int64(asset.fileSize)
        )
    }
    
    func handleSwipe(_ direction: SwipeDirection, for photo: Photo) {
        switch direction {
        case .right:
            bookmarkManager.toggleBookmark(assetIdentifier: photo.id)
            haptic.notify(.success)
            
        case .left:
            if settings.showDeletionConfirmation {
                pendingDeletePhoto = photo
                showDeleteAlert = true
            } else {
                trashManager.addToTrash(assetIdentifier: photo.id)
                haptic.notify(.warning)
                removePhoto(photo)
            }
        }
        
        withAnimation { state.removePhoto(photo) }
    }
    
    
    private func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    private func removePhoto(_ photo: Photo) {
        withAnimation(.spring()) {
            state.removePhoto(photo)
        }
    }
    
    func confirmDeletion(of photo: Photo?) {
        guard let p = photo else { return }
        trashManager.addToTrash(assetIdentifier: p.id)
        haptic.notify(.warning)
        pendingDeletePhoto = nil
        showDeleteAlert = false
        removePhoto(p)
    }
}

extension ReviewViewModel {
    enum ViewState {
        case idle
        case loading
        case loaded([Photo])
        case error(Error)
        
        mutating func removePhoto(_ photo: Photo) {
            guard case .loaded(var photos) = self else { return }
            photos.removeAll { $0.id == photo.id }
            self = .loaded(photos)
        }
    }
}
