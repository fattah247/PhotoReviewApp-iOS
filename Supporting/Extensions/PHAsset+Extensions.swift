//
//  PHAsset+Extensions.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//
import Photos

private var fileSizeCache = [String: Int64]()

extension PHAsset {
    var fileSize: Int64 {
        get {
            if let size = fileSizeCache[self.localIdentifier] {
                return size
            }
            
            let resources = PHAssetResource.assetResources(for: self)
            guard let resource = resources.first else { return 0 }
            
            let size = resource.value(forKey: "fileSize") as? Int64 ?? 0
            fileSizeCache[self.localIdentifier] = size
            return size
        }
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        return formatter.string(fromByteCount: fileSize)
    }
    
    var formattedCreationDate: String {
        guard let date = creationDate else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
