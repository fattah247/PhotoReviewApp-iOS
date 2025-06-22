//
//  MainTabView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 04/02/25.
//
import SwiftUI
import Foundation
import Photos
import CoreData
import OSLog

struct MainTabView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var analytics: CoreDataAnalyticsService
    @EnvironmentObject var hapticService: HapticService
    @EnvironmentObject var photoService: PhotoLibraryService
    @EnvironmentObject var bookmarkManager: CoreDataBookmarkManager
    @EnvironmentObject var trashManager: CoreDataTrashManager
    
    @EnvironmentObject var settings: SettingsViewModel
    
    var body: some View {
        TabView(selection: $appState.activeTab) {
            ReviewView(
                photoService: photoService,
                haptic: hapticService,
                analytics: analytics,
                bookmarkManager: bookmarkManager,
                trashManager: trashManager,
                settings: settings
            )
            .tabItem { Label("Review", systemImage: "photo") }
            .tag(AppStateManager.AppTab.review)
            
            DashboardView()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(AppStateManager.AppTab.stats)
            
            BookmarksView()
                .tabItem { Label("Bookmarks", systemImage: "bookmark") }
                .tag(AppStateManager.AppTab.bookmarks)
            
            TrashView()
                .tabItem { Label("Trash", systemImage: "trash") }
                .tag(AppStateManager.AppTab.trash)
            
            SettingsView()
                .environmentObject(settings) // Pass settings viewModel to the SettingsView
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(AppStateManager.AppTab.settings)
        }
        .onOpenURL { url in
            appState.handleDeepLink(url)
        }
        .onChange(of: appState.deepLinkTarget) { oldValue, newValue in
            handleDeepLinkTarget(newValue)
        }
        
    }
    
    private func handleDeepLinkTarget(_ target: AppStateManager.DeepLinkTarget?) {
        guard let target else { return }
        
        switch target {
        case .review(let id):
            if let asset = fetchAsset(for: id) {
                presentPhotoDetail(asset)
            }
        case .trash(let id):
            if let asset = fetchAsset(for: id) {
                presentTrashDetail(asset)
            }
        case .stats(let id):
            if let asset = fetchAsset(for: id) {
                presentStatsDetail(asset)
            }
        case .bookmarks(let id):
            if let asset = fetchAsset(for: id) {
                presentBookmarksDetail(asset)
            }
        case .settings(let id):
            if let asset = fetchAsset(for: id) {
                presentSettingsDetail(asset)
            }
        }
    }
    
    private func fetchAsset(for identifier: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        return result.firstObject
    }
    
    private func presentPhotoDetail(_ asset: PHAsset) {
        let detailView = PhotoDetailView(asset: asset)
            .environmentObject(photoService)
            .environmentObject(bookmarkManager)
        
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.modalPresentationStyle = .fullScreen
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else {
            Logger.logError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get root view controller"]))
            return
        }
        
        rootVC.present(hostingController, animated: true) {
            Logger.logError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get root view controller"]))
        }
    }
    
    private func presentTrashDetail(_ asset: PHAsset) {
        let trashDetailView = TrashDetailView(asset: asset)
            .environmentObject(trashManager)
            .environmentObject(photoService)
        
        let hostingController = UIHostingController(rootView: trashDetailView)
        hostingController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else {
            Logger.logError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get root view controller"]))
            return
        }
        
        rootVC.present(hostingController, animated: true) {
            AppLogger.general.debug("Trash detail view presented")
        }
    }
    
    private func presentStatsDetail(_ asset: PHAsset) {
        let detailView = DashboardView()
        
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.modalPresentationStyle = .fullScreen
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else {
            Logger.logError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get root view controller"]))
            return
        }
        
        rootVC.present(hostingController, animated: true) {
            AppLogger.general.debug("Photo detail view presented")
        }
    }
    
    private func presentBookmarksDetail(_ asset: PHAsset) {
        let detailView = BookmarksView()
            .environmentObject(photoService)
            .environmentObject(bookmarkManager)
        
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.modalPresentationStyle = .fullScreen
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else {
            Logger.logError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get root view controller"]))
            return
        }
        
        rootVC.present(hostingController, animated: true) {
            AppLogger.general.debug("Photo detail view presented")
        }
    }
    
    private func presentSettingsDetail(_ asset: PHAsset) {
        let detailView = PhotoDetailView(asset: asset)
            .environmentObject(photoService)
            .environmentObject(bookmarkManager)
        
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.modalPresentationStyle = .fullScreen
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else {
            Logger.logError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get root view controller"]))
            return
        }
        
        rootVC.present(hostingController, animated: true) {
            AppLogger.general.debug("Photo detail view presented")
        }
    }
    
    
    struct TrashDetailView: View {
        let asset: PHAsset
        @EnvironmentObject var trashManager: CoreDataTrashManager
        @EnvironmentObject var photoService: PhotoLibraryService
        @Environment(\.dismiss) var dismiss
        @State private var image: UIImage?
        @State private var showDeleteConfirmation = false
        
        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
                VStack(spacing: 20) {
                    Button(action: restoreAsset) {
                        Label("Restore", systemImage: "arrow.uturn.backward.circle.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Permanently", systemImage: "trash.circle.fill")
                            .padding()
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                    .confirmationDialog("Confirm Deletion", isPresented: $showDeleteConfirmation) {
                        Button("Delete Forever", role: .destructive) {
                            deleteAssetPermanently()
                        }
                    }
                }
                .padding()
            }
            .task { await loadImage() }
            .navigationTitle("Trash Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
        
        private func loadImage() async {
            image = await photoService.loadImage(
                for: asset,
                size: CGSize(width: 2000, height: 2000)
            )
        }
        
        private func restoreAsset() {
            trashManager.restoreFromTrash(assetIdentifier: asset.localIdentifier)
            dismiss()
        }
        
        private func deleteAssetPermanently() {
            Task {
                do {
                    try await photoService.deleteAssets([asset])
                    trashManager.emptyTrash()
                    dismiss()
                } catch {
                    Logger.logError(error)
                }
            }
        }
    }
}


extension Logger {
    static func logError(_ error: Error) {
        AppLogger.general.error("Error: \(error.localizedDescription, privacy: .public)")
    }
}
