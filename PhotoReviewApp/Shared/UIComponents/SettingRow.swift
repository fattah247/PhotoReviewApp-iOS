//
//  SettingRow.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 17/06/25.
//

import SwiftUI

/// A single row in a settings card: icon + title + optional trailing content.
struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let iconColor: Color
    private let trailingContent: Content

    init(
        icon: String,
        title: String,
        iconColor: Color,
        @ViewBuilder trailingContent: () -> Content = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.trailingContent = trailingContent()
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundColor(iconColor)
                .frame(width: 24, alignment: .center)
                .accessibilityHidden(true)

            Text(title)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            trailingContent
        }
        .contentShape(Rectangle())
    }
}
