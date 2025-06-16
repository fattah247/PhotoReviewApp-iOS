//
//  WeekdaySelectionView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 16/06/25.
//

import SwiftUI

struct WeekdaySelectionView: View {
    @Binding var selection: [Weekday]
    
    let columns = [GridItem(.adaptive(minimum: 44, maximum: 60), spacing: 12)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Weekday.allCases) { day in
                Text(day.shortName)
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
                    .frame(width: 44, height: 44)
                    .background(
                        selection.contains(day)
                        ? AnyView(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.indigo, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyView(Color(.tertiarySystemFill))
                    )
                    .foregroundColor(selection.contains(day) ? .white : .primary)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
                    )
                    .contentShape(Circle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if let idx = selection.firstIndex(of: day) {
                                selection.remove(at: idx)
                            } else {
                                selection.append(day)
                            }
                        }
                    }
            }
        }
        .padding(.vertical, 4)
    }
}
