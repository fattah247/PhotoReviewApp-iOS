//
//  TrashManager.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//

import CoreData
import Photos
import SwiftUI
import OSLog

protocol TrashManagerProtocol: ObservableObject {
    var trashedAssets: [PHAsset] { get }
    func addToTrash(assetIdentifier: String)
    func restoreFromTrash(assetIdentifier: String)
    func emptyTrash()
}

final class CoreDataTrashManager: NSObject, ObservableObject, @preconcurrency TrashManagerProtocol {
    // MARK: - Published state
    @Published var trashedAssets: [PHAsset] = []

    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    private let photoService: any PhotoLibraryServiceProtocol

    // MARK: - Init / Deinit
    init(
        context: NSManagedObjectContext,
        photoService: any PhotoLibraryServiceProtocol
    ) {
        self.context = context
        self.photoService = photoService
        super.init()
        // Start observing the Photos library for "Recently Deleted" changes
        PHPhotoLibrary.shared().register(self)
        // Initial load
        refresh()
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    // MARK: - TrashManagerProtocol

    func addToTrash(assetIdentifier: String) {
        let assets = PHAsset.fetchAssets(
            withLocalIdentifiers: [assetIdentifier],
            options: nil
        )
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets)
        } completionHandler: { success, error in
            if success {
                Task { @MainActor in self.refresh() }
            } else if let error {
                print("❌ couldn’t trash:", error)
            }
        }
    }

    @MainActor func restoreFromTrash(assetIdentifier: String) {
        // Note: Photos.app’s “Recently Deleted” can’t be programmatically undeleted.
        // Here we just clear any local DB entry if you had one.
        let request = TrashEntity.fetchRequest() as! NSFetchRequest<TrashEntity>
        request.predicate = NSPredicate(format: "assetIdentifier == %@", assetIdentifier)
        do {
            try context.fetch(request).forEach { context.delete($0) }
            saveContext()
            refresh()
        } catch {
            print("Error restoring from trash:", error)
        }
    }

    func emptyTrash() {
        guard let collection = recentlyDeletedCollection() else { return }
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets)
        } completionHandler: { success, error in
            if success {
                Task { @MainActor in self.refresh() }
            } else if let error {
                print("❌ couldn’t empty trash:", error)
            }
        }
    }

    // MARK: - Helpers

    /// Re‐query the “Recently Deleted” smart album and repopulate `trashedAssets`.
    func refresh() {
        guard let collection = recentlyDeletedCollection() else {
            trashedAssets = []
            return
        }
        let result = PHAsset.fetchAssets(in: collection, options: nil)
        trashedAssets = result.objects(at: IndexSet(0..<result.count))
    }

    /// Workaround rawValue hack for the “Recently Deleted” smart album
    private func recentlyDeletedCollection() -> PHAssetCollection? {
        let rawValue = 1000000201
        guard let subtype = PHAssetCollectionSubtype(rawValue: rawValue) else { return nil }
        return PHAssetCollection
            .fetchAssetCollections(
                with: .smartAlbum,
                subtype: subtype,
                options: nil
            )
            .firstObject
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving CoreData context in TrashManager:", error)
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension CoreDataTrashManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Whenever the user empties “Recently Deleted” in the Photos app,
        // re‐fetch the album so our UI stays in sync.
        Task { @MainActor in self.refresh() }
    }
}
