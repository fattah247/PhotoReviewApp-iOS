//
//  PhotoReviewAppApp.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI

@main
struct PhotoReviewApp: App {
    // Instantiate shared singletons or services here, if truly global.
    let photoLibraryManager = PhotoLibraryManager()
    let notificationManager = NotificationManager()
    let photoDataStore = InMemoryPhotoDataStore()  // or your persistent store

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Pass dependencies through environment objects or other injection methods.
                .environmentObject(photoLibraryManager)
                .environmentObject(notificationManager)
                .environmentObject(photoDataStore)
        }
    }
}
