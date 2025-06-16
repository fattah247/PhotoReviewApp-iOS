//
//  MonthDaySelectionView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 16/06/25.
//

import SwiftUI

struct MonthDaySelectionView: View {
    @Binding var selection: Int
    @Environment(\.horizontalSizeClass) var hSize
    
    private let columns = Array(repeating: GridItem(.flexible(minimum: 30, maximum: 44), spacing: 8), count: 7)
    
    var body: some View {
        Group {
            if hSize == .compact {
                HStack {
                    Text("Day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    IncrementDecrementStepper(
                        value: $selection,
                        range: 1...31,
                        step: 1,
                        onIncrement: {},
                        onDecrement: {}
                    )
                }
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)")
                            .font(.subheadline.weight(.medium))
                            .monospacedDigit()
                            .frame(minWidth: 36, minHeight: 36)
                            .background(
                                selection == day
                                ? AnyView(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.indigo, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                : AnyView(Color(.tertiarySystemFill))
                            )
                            .foregroundColor(selection == day ? .white : .primary)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
                            )
                            .contentShape(Circle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selection = day
                                }
                            }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

