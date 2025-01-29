//
//  ContentView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var photoReviewVM: PhotoReviewViewModel
    @StateObject private var settingsVM: SettingsViewModel

    init() {
        // Initialize view models with custom initializers so you can inject dependencies if desired.
        let photoLibraryManager = PhotoLibraryManager()
        let photoDataStore = InMemoryPhotoDataStore()
        let notificationManager = NotificationManager()
        let dailySelectionManager = DailyPhotoSelectionManager()

        _photoReviewVM = StateObject(wrappedValue:
            PhotoReviewViewModel(
                photoLibraryManager: photoLibraryManager,
                dailySelectionManager: dailySelectionManager,
                photoDataStore: photoDataStore
            )
        )

        _settingsVM = StateObject(wrappedValue:
            SettingsViewModel(
                userSettingsStore: UserDefaultsSettingsStore(),
                notificationManager: notificationManager
            )
        )
    }

    var body: some View {
        TabView {
            PhotoReviewView()
                .environmentObject(photoReviewVM)
                .tabItem {
                    Label("Review", systemImage: "photo.on.rectangle")
                }

            SettingsView()
                .environmentObject(settingsVM)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            photoReviewVM.requestPhotoLibraryAccess()
            settingsVM.requestNotificationPermission()
        }
    }
}
