//
//  EmptyStateView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 04/02/25.
//
import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject var viewModel: ReviewViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .symbolRenderingMode(.hierarchical)
            
            Text("All Caught Up!")
                .font(.title2.weight(.semibold))
            
            Text("You've reviewed all available photos")
                .foregroundColor(.secondary)
            
            Button {
                Task { await viewModel.loadInitialPhotos() }
            } label: {
                Label("Load More", systemImage: "arrow.clockwise")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
