//
//  MetricCardView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 07/02/25.
//
// Create MetricCard.swift
import SwiftUI

// MetricComponents.swift
struct MetricCard: View {
    let title: String
    let icon: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: icon)
                .font(.headline)
            Text(value)
                .font(.title3.weight(.bold))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct MetricBadge: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(8)
    }
}

// EmptyStateViews.swift
struct EmptyBookmarksView: View {
    var body: some View {
        ContentUnavailableView(
            "No Bookmarks",
            systemImage: "bookmark.slash",
            description: Text("Photos you bookmark will appear here")
        )
    }
}

struct EmptyTrashView: View {
    var body: some View {
        ContentUnavailableView(
            "Trash Empty",
            systemImage: "trash.slash",
            description: Text("Deleted photos will appear here for 30 days")
        )
    }
}
