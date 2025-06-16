//
//  SettingsRowModifier.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 16/06/25.
//

import SwiftUI

extension View {
    func settingsRow() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
    }
}
