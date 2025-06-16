//
//  NeumorphicButtonStyle.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 16/06/25.
//

import SwiftUI

struct NeumorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Group {
                    if configuration.isPressed {
                        Color(.systemGray5)
                    } else {
                        Color(.systemBackground)
                    }
                }
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: configuration.isPressed ? 1 : 4, x: 2, y: 2)
    }
}
