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

protocol TrashManagerProtocol: ObservableObject{
    var trashedAssets: [PHAsset] { get }
    func addToTrash(assetIdentifier: String)
    func restoreFromTrash(assetIdentifier: String)
    func emptyTrash()
}

final class CoreDataTrashManager: ObservableObject, TrashManagerProtocol {
    private let context: NSManagedObjectContext
    private let photoService: any PhotoLibraryServiceProtocol
    
    @Published var trashedAssets: [PHAsset] = []
    
    init(context: NSManagedObjectContext, photoService: any PhotoLibraryServiceProtocol) {
        self.context = context
        self.photoService = photoService
        refreshTrash()
    }
    
    func addToTrash(assetIdentifier: String) {
        let newItem = TrashEntity(context: context)
        newItem.id = UUID()
        newItem.assetIdentifier = assetIdentifier
        newItem.dateDeleted = Date()
        saveContext()
        refreshTrash()
    }
    
    func restoreFromTrash(assetIdentifier: String) {
        let request = TrashEntity.fetchRequest() as! NSFetchRequest<TrashEntity>
        request.predicate = NSPredicate(format: "assetIdentifier == %@", assetIdentifier)
        
        do {
            try context.fetch(request).forEach { context.delete($0) }
            saveContext()
            refreshTrash()
        } catch {
            print("Error restoring from trash: \(error)")
        }
    }
    
    func emptyTrash() {
        let request = TrashEntity.fetchRequest() as! NSFetchRequest<TrashEntity>
        do {
            try context.fetch(request).forEach { context.delete($0) }
            saveContext()
            refreshTrash()
        } catch {
            print("Error emptying trash: \(error)")
        }
    }
    
    private func refreshTrash() {
        let request = TrashEntity.fetchRequest() as! NSFetchRequest<TrashEntity>
        do {
            let identifiers = try context.fetch(request).compactMap { $0.assetIdentifier }
            let result = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
            trashedAssets = result.objects(at: IndexSet(0..<result.count))
        } catch {
            print("Error fetching trash: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving trash changes: \(error)")
        }
    }
}
