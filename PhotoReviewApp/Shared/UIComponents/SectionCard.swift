//
//  SectionCard.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 17/06/25.
//

import SwiftUI

/// A styled “card” container for a settings section—with a header bar and content area.
struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content

    init(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(color)
                    .frame(width: 24, alignment: .center)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))

            // Content
            content()
                .padding(16)
                .background(Color(.tertiarySystemGroupedBackground))
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }
}
