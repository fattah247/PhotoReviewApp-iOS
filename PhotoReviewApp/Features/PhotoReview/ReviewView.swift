//
//  PhotoReviewView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//
import SwiftUI
import Photos
import CoreData
import OSLog

struct ReviewView: View {
    @StateObject var viewModel: ReviewViewModel
    private let haptic: any HapticServiceProtocol
    @Namespace private var cardNamespace
    
    init(photoService: any PhotoLibraryServiceProtocol,
         haptic: any HapticServiceProtocol,
         analytics: any AnalyticsServiceProtocol) {
        _viewModel = StateObject(wrappedValue: ReviewViewModel(
            photoService: photoService,
            haptic: haptic,
            analytics: analytics
        ))
        self.haptic = haptic
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            contentSwitch
                .transition(.opacity.combined(with: .scale(0.9)))
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
                .environmentObject(viewModel)
        }
        .task { await viewModel.loadInitialPhotos() }
    }
    
    @ViewBuilder
    private var contentSwitch: some View {
        switch viewModel.state {
        case .idle:
            loadingPlaceholder
        case .loading:
            loadingView
        case .loaded(let photos):
            contentView(photos: photos)
        case .error(let error):
            errorView(error: error)
        }
    }
    
    private func contentView(photos: [Photo]) -> some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(photos) { photo in
                    PhotoCardView(photo: photo, viewModel: viewModel)
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.9)
                        .matchedGeometryEffect(id: photo.id, in: cardNamespace)
                        .transition(.asymmetric(
                            insertion: .offset(y: 50).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                        .zIndex(Double(photos.count - (photos.firstIndex(of: photo) ?? 0)))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                .scaleEffect(1.5)
            
            Text("Curating Your Memories")
                .font(.title3)
                .foregroundColor(.secondary)
                .transition(.opacity)
        }
    }
    
    private var loadingPlaceholder: some View {
        VStack(spacing: 20) {
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 300, height: 500)
                    .padding(.vertical, 10)
                    .shimmering()
            }
        }
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Couldn't Load Photos")
                .font(.title2.bold())
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                Task { await viewModel.loadInitialPhotos() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
        
    func cardStack(photos: [Photo]) -> some View {
        ZStack {
            ForEach(photos) { photo in
                PhotoCardView(photo: photo, viewModel: viewModel)
                    .matchedGeometryEffect(id: photo.id, in: cardNamespace)
                    .transition(.asymmetric(
                        insertion: .offset(x: 0, y: 50).combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                    .zIndex(photo.id == photos.first?.id ? 1 : 0)
            }
        }
    }
        
    var settingsButton: some View {
        Button {
            haptic.impact(.medium)
            viewModel.showSettings.toggle()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.title2)
                .padding()
                .background(.thickMaterial)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

extension View {
    func shimmering() -> some View {
        self.modifier(ShimmerEffect())
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask(content)
                .offset(x: phase * 200)
                .animation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false),
                    value: phase
                )
                .onAppear { phase = 1 }
            )
    }
}
