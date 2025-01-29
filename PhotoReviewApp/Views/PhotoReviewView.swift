//
//  PhotoReviewView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//
import SwiftUI
import Photos

struct PhotoReviewView: View {
    @EnvironmentObject var viewModel: PhotoReviewViewModel
    
    var body: some View {
        VStack {
            if viewModel.dailyPhotos.isEmpty {
                Text("No daily photos yet")
                    .padding()
                Button("Generate Daily Photos") {
                    viewModel.generateDailyPhotos()
                }
                .padding()
            } else {
                if viewModel.dailyPhotos.isEmpty {
                    VStack {
                        Text("No photos left, generating new photos...")
                            .padding()
                        
                        // Trigger photo generation when the view appears (using .onAppear)
                        EmptyView()
                            .onAppear {
                                viewModel.generateNewPhotos()
                                
                                // Ensure currentIndex is valid after generating new photos
                                if !viewModel.dailyPhotos.isEmpty {
                                    viewModel.currentIndex = 0 // Reset currentIndex to the first photo
                                }
                            }
                    }
                } else {
                    // Ensure the current index is within bounds
                    if viewModel.currentIndex < viewModel.dailyPhotos.count {
                        PhotoAssetView(asset: viewModel.dailyPhotos[viewModel.currentIndex])
                            .id(viewModel.currentIndex)  // Force re-render of the view
                            .frame(width: 300, height: 300)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .gesture(dragGesture)
                    }
                }


                Text("Photo \(viewModel.currentIndex + 1) of \(viewModel.dailyPhotos.count)")
                    .padding()
                
                HStack {
                    Button {
                        viewModel.deleteCurrentPhoto()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                    .padding()
                    
                    Button {
                        viewModel.keepCurrentPhoto()
                    } label: {
                        Label("Keep", systemImage: "checkmark")
                    }
                    .foregroundColor(.green)
                    .padding()
                }
            }
        }
    }
    

    private var dragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                let horizontalAmount = value.translation.width
                if horizontalAmount < -50 {
                    // Swipe left -> Delete
                    viewModel.deleteCurrentPhoto()
                } else if horizontalAmount > 50 {
                    // Swipe right -> Keep
                    viewModel.keepCurrentPhoto()
                }
            }
    }
}

struct PhotoAssetView: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.gray.opacity(0.3)
                    .overlay(ProgressView().padding())
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic

        imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: 600, height: 600),
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            if let result = result {
                DispatchQueue.main.async {
                    image = result
                }
            }
        }
    }
}
