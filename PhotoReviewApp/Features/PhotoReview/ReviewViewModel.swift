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
    
    private let photoService: any PhotoLibraryServiceProtocol
    private let haptic: any HapticServiceProtocol
    private let analytics: any AnalyticsServiceProtocol
    private var currentTask: Task<Void, Never>?
    
    init(
        photoService: any PhotoLibraryServiceProtocol,
        haptic: any HapticServiceProtocol,
        analytics: any AnalyticsServiceProtocol
    ) {
        self.photoService = photoService
        self.haptic = haptic
        self.analytics = analytics
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
    
    // ReviewViewModel.swift (Updated)
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
        haptic.impact(direction == .left ? .heavy : .medium)

        switch direction {
        case .left:
            analytics.trackDeletion(fileSize: photo.fileSize)
            print("Photo Deleted")
        case .right:
            analytics.trackBookmark()
            print("Photo Deleted")
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            state.removePhoto(photo)
        }
    }
    
    private func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
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
