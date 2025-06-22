//
//  PhotoLibraryManager.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//
import Photos
import Combine
import CoreData
import SwiftUI
import OSLog

extension NSSortDescriptor: @unchecked @retroactive Sendable {}

protocol PhotoLibraryServiceProtocol: ObservableObject {
    var authorizationStatus: PHAuthorizationStatus { get }
    func requestAuthorization() async -> PHAuthorizationStatus
    func fetchAssets(options: FetchOptions) async throws -> [PHAsset]
    func loadImage(for asset: PHAsset, size: CGSize) async -> UIImage?
    func deleteAssets(_ assets: [PHAsset]) async throws
}

final class PhotoLibraryService: PhotoLibraryServiceProtocol {
    @Published private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    private let imageManager = PHImageManager.default()
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.authorizationStatus = status
                    continuation.resume(returning: status)
                }
            }
        }
    }
    
    func fetchAssets(options: FetchOptions) async throws -> [PHAsset] {
        // Capture the needed values locally.
        let sortDescriptors = options.sortDescriptors
        let limit = options.limit
        let mediaType = options.mediaType
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = sortDescriptors
                fetchOptions.fetchLimit = limit
                
                let result = PHAsset.fetchAssets(with: mediaType, options: fetchOptions)
                var assets = [PHAsset]()
                result.enumerateObjects { asset, _, _ in assets.append(asset) }
                continuation.resume(returning: assets)
            }
        }
    }
    
    func loadImage(for asset: PHAsset, size: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .highQualityFormat
            
            imageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    func deleteAssets(_ assets: [PHAsset]) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }
    }
}

struct FetchOptions {
    var mediaType: PHAssetMediaType = .image
    var limit: Int = 100
    var sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "creationDate", ascending: false)]
}
