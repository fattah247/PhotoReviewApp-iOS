//
//  PhotoReviewAppApp.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//
import SwiftUI
import Foundation
import CoreData
import Photos
import OSLog

@main
struct PhotoReviewApp: App {
    @StateObject private var appState = AppStateManager()
    @StateObject private var photoService = PhotoLibraryService()
    @StateObject private var hapticService = HapticService()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var dataManager = CoreDataManager.shared

    // Single instances for managers - using StateObject wrapper class
    @StateObject private var analyticsService = CoreDataAnalyticsService(
        context: CoreDataManager.shared.viewContext
    )

    @StateObject private var bookmarkManager: CoreDataBookmarkManager

    @StateObject private var trashManager: CoreDataTrashManager

    @StateObject private var settingsViewModel: SettingsViewModel

    // Determine if onboarding is needed
    private var needsOnboarding: Bool {
        !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    init() {
        // Create shared instances
        let sharedPhotoService = PhotoLibraryService()
        let sharedNotificationService = NotificationService()
        let context = CoreDataManager.shared.viewContext

        let sharedBookmarkManager = CoreDataBookmarkManager(
            context: context,
            photoService: sharedPhotoService
        )

        let sharedTrashManager = CoreDataTrashManager(
            context: context,
            photoService: sharedPhotoService
        )

        let sharedSettingsViewModel = SettingsViewModel(
            settingsStore: UserDefaultsSettingsStore(),
            trashManager: sharedTrashManager,
            notificationService: sharedNotificationService
        )

        // Initialize StateObjects with shared instances
        _photoService = StateObject(wrappedValue: sharedPhotoService)
        _notificationService = StateObject(wrappedValue: sharedNotificationService)
        _bookmarkManager = StateObject(wrappedValue: sharedBookmarkManager)
        _trashManager = StateObject(wrappedValue: sharedTrashManager)
        _settingsViewModel = StateObject(wrappedValue: sharedSettingsViewModel)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if needsOnboarding {
                    NavigationStack {
                        OnboardingView()
                            .onDisappear {
                                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            }
                    }
                } else {
                    MainTabView()
                }
            }
            // Inject all necessary environment objects.
            .environmentObject(appState)
            .environmentObject(photoService)
            .environmentObject(hapticService)
            .environmentObject(notificationService)
            .environmentObject(settingsViewModel)
            .environmentObject(analyticsService)
            .environmentObject(bookmarkManager)
            .environmentObject(trashManager)
            .environment(\.managedObjectContext, dataManager.viewContext)
            .onAppear {
                appState.configureServices(
                    photoService: photoService,
                    notificationService: notificationService
                )
            }
        }
    }
}
