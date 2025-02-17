//
//  ReviewView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//
import SwiftUI
import Photos
import CoreData
import OSLog

struct TrashView: View {
    @EnvironmentObject var trashManager: CoreDataTrashManager
    @EnvironmentObject var photoService: PhotoLibraryService
    @EnvironmentObject var haptic: HapticService
    @State private var confirmationShow = false
    
    var body: some View {
        NavigationStack {
            Group {
                if trashManager.trashedAssets.isEmpty {
                    EmptyTrashView()
                } else {
                    trashGrid
                }
            }
            .navigationTitle("Trash")
            .toolbar {
                if !trashManager.trashedAssets.isEmpty {
                    Button(role: .destructive) {
                        haptic.impact(.heavy)
                        confirmationShow = true
                    } label: {
                        Label("Empty Trash", systemImage: "trash")
                    }
                }
            }
            .confirmationDialog("Empty Trash", isPresented: $confirmationShow) {
                Button("Delete All", role: .destructive) {
                    emptyTrash()
                }
            }
        }
    }
    
    private var trashGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                ForEach(trashManager.trashedAssets) { asset in
                    TrashItemView(asset: asset)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .offset(x: 0, y: 100).combined(with: .opacity)
                        ))
                }
            }
            .padding()
        }
    }
    
    private func emptyTrash() {
        withAnimation(.spring()) {
            trashManager.emptyTrash()
            haptic.notify(.warning)
        }
    }
}

struct TrashItemView: View {
    let asset: PHAsset
    @EnvironmentObject var trashManager: CoreDataTrashManager
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
                withAnimation {
                    trashManager.restoreFromTrash(assetIdentifier: asset.localIdentifier)
                }
            } label: {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .blue)
                    .font(.title2)
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
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
