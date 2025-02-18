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
    let gradient: LinearGradient
    
    var body: some View {
        HStack(alignment: .top){
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))

                Text(value)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
            .cornerRadius(12)
            
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 24))
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white.opacity(0.8), gradient)
                .padding(12)
        }
        .padding(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(gradient)
                .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4) // Apply opacity to black color for shadow
        )
        .padding(.horizontal)
        

    }
}

struct MetricBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .padding(10)
                .background(Circle().fill(color.opacity(0.15)))

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemFill), lineWidth: 0.5)
        )
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
