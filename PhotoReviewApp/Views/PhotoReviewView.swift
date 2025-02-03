//
//  PhotoReviewView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//
import SwiftUI
import Photos
import UIKit

struct PhotoReviewView: View {
    @EnvironmentObject var viewModel: PhotoReviewViewModel
    @GestureState private var dragOffset = CGSize.zero
    @State private var feedbackDirection: SwipeDirection?
    @State private var showSuccessOverlay = false
    @State private var overlayMessage = ""
    @State private var originalPhotoCount = 0
    
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)

    // Computed properties for feedback
    private var feedbackColor: Color {
        switch feedbackDirection {
        case .left: return .red.opacity(0.4)
        case .right: return .green.opacity(0.4)
        default: return .clear
        }
    }
    
    private var rotationAmount: Double {
        Double(dragOffset.width / 30)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            if viewModel.dailyPhotos.isEmpty {
                emptyStateView
            } else {
                mainContentView
            }
            
            if showSuccessOverlay {
                SuccessOverlay(message: overlayMessage)
                    .transition(.opacity)
            }
        }
        .onAppear {
//            originalPhotoCount = viewModel.dailyPhotos.count
        }
        .onChange(of: viewModel.dailyPhotos) {
            if viewModel.dailyPhotos.isEmpty {
                viewModel.generateNewPhotos()
                originalPhotoCount = viewModel.dailyPhotos.count
            }
        }
    }

    private var mainContentView: some View {
        VStack(spacing: 20) {
            photoView
            photoCounter
            actionButtons
        }
        .padding()
    }

    private var photoView: some View {
        ZStack {
            if viewModel.currentIndex < viewModel.dailyPhotos.count {
                PhotoAssetView(asset: viewModel.dailyPhotos[viewModel.currentIndex])
                    .id(viewModel.currentIndex)
                    .frame(width: 300, height: 400)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(feedbackColor, lineWidth: 4)
                    )
                    .overlay(actionIndicator)
                    .offset(x: dragOffset.width, y: 0)
                    .rotationEffect(.degrees(rotationAmount))
                    .gesture(dragGesture)
                    .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7), value: dragOffset)
            }
        }
        .frame(height: 400)
    }

    private var actionIndicator: some View {
        Group {
            if let direction = feedbackDirection {
                Image(systemName: direction == .left ? "trash" : "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(direction == .left ? .red : .green)
                    .padding(20)
                    .background(Circle().fill(Color(.systemBackground)))
                    .shadow(radius: 5)
                    .transition(.scale)
            }
        }
    }

    private var photoCounter: some View {
        VStack(spacing: 4) {
            Text("\(viewModel.currentIndex + 1) of \(10)")
                .font(.system(size: 16, weight: .semibold))
                .monospacedDigit()
            
//            Text("Remaining: \(viewModel.dailyPhotos.count)")
//                .font(.caption)
//                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 30) {
            actionButton(
                icon: "trash",
                color: .red,
                action: { handleAction(.left) }
            )
            
            actionButton(
                icon: "checkmark",
                color: .green,
                action: { handleAction(.right) }
            )
        }
    }

    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color.gradient)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PressEffectButtonStyle())
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 60))
                .symbolEffect(.bounce.up, options: .repeat(3), value: viewModel.dailyPhotos.isEmpty)
                .foregroundColor(.secondary)
            
            Text("No Photos to Review")
                .font(.title2.weight(.medium))
                .foregroundColor(.secondary)
            
            Button(action: viewModel.generateNewPhotos) {
                Label("Generate Daily Photos", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .background(Color.blue.gradient)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(PressEffectButtonStyle())
        }
        .padding()
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
                updateFeedback(for: value.translation.width)
            }
            .onEnded { value in
                handleDragEnd(value.translation.width)
            }
    }

    private func updateFeedback(for width: CGFloat) {
        if width < -50 {
            if feedbackDirection != .left {
                impactMed.impactOccurred()
            }
            feedbackDirection = .left
        } else if width > 50 {
            if feedbackDirection != .right {
                impactMed.impactOccurred()
            }
            feedbackDirection = .right
        } else {
            feedbackDirection = nil
        }
    }

    private func handleDragEnd(_ width: CGFloat) {
        if width < -120 {
            handleAction(.left)
        } else if width > 120 {
            handleAction(.right)
        } else {
            withAnimation(.spring()) {
                feedbackDirection = nil
            }
        }
    }

    private func handleAction(_ direction: SwipeDirection) {
        impactHeavy.impactOccurred()
        
        let currentIndex = viewModel.currentIndex
        let totalCount = originalPhotoCount
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            feedbackDirection = direction
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showSuccessOverlay(message: direction == .left ? "Deleted" : "Kept")
            if direction == .left {
                Task {
                    await viewModel.deleteCurrentPhoto()
                    if viewModel.dailyPhotos.isEmpty {
                        originalPhotoCount = viewModel.dailyPhotos.count
                    }
                }
            } else {
                viewModel.keepCurrentPhoto()
            }
            feedbackDirection = nil
            
            withAnimation(.easeInOut) {
                if viewModel.currentIndex < originalPhotoCount {
                    viewModel.currentIndex = min(currentIndex + 1, originalPhotoCount - 1)
                }
            }
        }
    }

    private func showSuccessOverlay(message: String) {
        overlayMessage = message
        withAnimation {
            showSuccessOverlay = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showSuccessOverlay = false
            }
        }
    }
}

// MARK: - Supporting Components
struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SuccessOverlay: View {
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding()
            .transition(.scale.combined(with: .opacity))
        }
        .frame(maxWidth: .infinity)
    }
}

struct PhotoAssetView: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil
    @State private var creationDate: Date? = nil
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity.combined(with: .scale(0.95)))
                
                if let creationDate = creationDate {
                    Text(creationDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12, weight: .medium))
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .padding(8)
                }
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: .blue)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
            }
        }
        .task {
            await loadImage()
            creationDate = asset.creationDate
        }
    }

    private func loadImage() async {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 800, height: 800),
                contentMode: .aspectFill,
                options: options
            ) { result, _ in
                if let result = result {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            image = result
                        }
                    }
                }
                continuation.resume()
            }
        }
    }
}

enum SwipeDirection {
    case left, right
}
