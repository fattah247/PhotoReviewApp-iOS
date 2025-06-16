//
//  PhotoCardView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//
import SwiftUI
import Photos
import CoreData
import OSLog

struct PhotoCardView: View {
    let photo: Photo
    let viewModel: ReviewViewModel
    @GestureState private var dragOffset = CGSize.zero
    @EnvironmentObject var haptic: HapticService
    
    @State private var overlayOpacity: Double = 0
    @State private var swipeIndicatorOffset: CGFloat = 0
    private let maxSwipeIndicatorOffset: CGFloat = 60

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                imageContent(for: geometry.size)
                    .overlay(swipeFeedbackOverlay)
                
                metadataOverlay
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))  // Ensures background adapts to both light and dark mode
                    .shadow(color: shadowColor, radius: 20, x: 0, y: 5) // Dynamic shadow based on color scheme
            )
            .offset(dragOffset)
            .rotationEffect(.degrees(Double(dragOffset.width / 30)))
            .scaleEffect(1 - abs(dragOffset.width) / 1000)
            .gesture(dragGesture(geometry: geometry))
            .animation(.interactiveSpring(), value: dragOffset)
        }
        .padding(.vertical, 20)
    }
    
    private func imageContent(for size: CGSize) -> some View {
        ZStack {
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Color.secondary
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var swipeFeedbackOverlay: some View {
        ZStack {
            if dragOffset.width > 0 {
                Color.green.opacity(0.3)
            } else if dragOffset.width < 0 {
                Color.red.opacity(0.3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(swipeIndicator)
        .opacity(overlayOpacity)
    }
    
    private var swipeIndicator: some View {
        HStack {
            if dragOffset.width < -50 {
                Image(systemName: "trash")
                    .font(.title)
                    .foregroundColor(.red)
                    .offset(x: swipeIndicatorOffset)
                    .transition(.scale)
            }
            
            Spacer()
            
            if dragOffset.width > 50 {
                Image(systemName: "bookmark.fill")
                    .font(.title)
                    .foregroundColor(.green)
                    .offset(x: -swipeIndicatorOffset)
                    .transition(.scale)
            }
        }
        .padding(30)
    }
    
    private func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
                handleDragProgress(value.translation.width)
                withAnimation {
                    overlayOpacity = min(abs(value.translation.width) / CGFloat(200), CGFloat(0.7))
                    swipeIndicatorOffset = min(abs(value.translation.width), maxSwipeIndicatorOffset)
                }
            }
            .onEnded { value in
                handleDragEnded(value.translation, width: geometry.size.width)
                withAnimation(.spring()) {
                    overlayOpacity = 0
                    swipeIndicatorOffset = 0
                }
            }
    }

    private var metadataOverlay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(photo.creationDate?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown Date")
                        .font(.caption2)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "photo")
                        .font(.caption2)
                    Text(photo.fileSize.formatted(.byteCount(style: .file)))
                        .font(.caption2)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.horizontal, .bottom], 16)
    }

    private func handleDragProgress(_ translationWidth: CGFloat) {
        _ = abs(translationWidth) / UIScreen.main.bounds.width
        haptic.prepare()
    }
    
    private func handleDragEnded(_ translation: CGSize, width: CGFloat) {
        let decisionThreshold = width * 0.3
        let direction: SwipeDirection = translation.width > 0 ? .right : .left
        
        if abs(translation.width) > decisionThreshold {
            viewModel.handleSwipe(direction, for: photo)
        }
    }
    
    // Dynamic shadow color for light and dark modes
    private var shadowColor: Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return Color.black.opacity(0.6) // Darker shadow for Dark Mode
        } else {
            return Color.black.opacity(0.2) // Softer shadow for Light Mode
        }
    }
}

