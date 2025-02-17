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
    
    // Managers for analytics, bookmarks, and trash.
    private var analyticsService: CoreDataAnalyticsService {
        CoreDataAnalyticsService(context: dataManager.viewContext)
    }
    
    private var bookmarkManager: CoreDataBookmarkManager {
        CoreDataBookmarkManager(
            context: dataManager.viewContext,
            photoService: photoService
        )
    }
    
    private var trashManager: CoreDataTrashManager {
        CoreDataTrashManager(
            context: dataManager.viewContext,
            photoService: photoService
        )
    }
    
    // Create a SettingsViewModel instance.
    @StateObject private var settingsViewModel = SettingsViewModel(
        settingsStore: UserDefaultsSettingsStore(),
        trashManager: CoreDataTrashManager(
            context: CoreDataManager.shared.viewContext,
            photoService: PhotoLibraryService()
        ),
        notificationService: NotificationService()
    )
    
    // Determine if onboarding is needed
    private var needsOnboarding: Bool {
        !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
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
            .environmentObject(settingsViewModel) // Inject SettingsViewModel
            .environmentObject(analyticsService) // Inject CoreDataAnalyticsService
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
