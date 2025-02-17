//
//  BookmarksView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//
import SwiftUI
import Photos
import CoreData
import OSLog

struct BookmarksView: View {
    @EnvironmentObject var bookmarkManager: CoreDataBookmarkManager
    @EnvironmentObject var photoService: PhotoLibraryService
    @EnvironmentObject var haptic: HapticService
    @State private var selectedPhoto: PHAsset?
    
    var body: some View {
        NavigationStack {
            Group {
                if bookmarkManager.bookmarkedAssets.isEmpty {
                    EmptyBookmarksView()
                } else {
                    bookmarkGrid
                }
            }
            .navigationTitle("Bookmarks")
            .sheet(item: $selectedPhoto) { asset in
                PhotoDetailView(asset: asset)
            }
        }
    }
    
    private var bookmarkGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                ForEach(bookmarkManager.bookmarkedAssets) { asset in
                    BookmarkItemView(asset: asset)
                        .onTapGesture { selectedPhoto = asset }
                }
            }
            .padding()
        }
    }
}

struct BookmarkItemView: View {
    let asset: PHAsset
    @EnvironmentObject var bookmarkManager: CoreDataBookmarkManager
    @EnvironmentObject var photoService: PhotoLibraryService
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ProgressView()
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.tertiary, lineWidth: 1)
            )
            
            Button {
                bookmarkManager.toggleBookmark(assetIdentifier: asset.localIdentifier)
            } label: {
                Image(systemName: "bookmark.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .yellow)
                    .font(.title2)
                    .padding(4)
            }
        }
        .task { await loadImage() }
    }
    
    private func loadImage() async {
        image = await photoService.loadImage(
            for: asset,
            size: CGSize(width: 200, height: 200)
        )
    }
}

extension PHAsset: @retroactive Identifiable {
    public var id: String {
        localIdentifier
    }
}
