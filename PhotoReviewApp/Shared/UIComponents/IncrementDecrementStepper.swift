//
//  IncrementDecrementStepper.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 17/06/25.
//

import SwiftUI

/// A custom plus/minus stepper with haptic callbacks.
struct IncrementDecrementStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Decrement
            Button {
                guard value > range.lowerBound else { return }
                value = max(value - step, range.lowerBound)
                onDecrement()
            } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .padding(8)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Circle())
            }
            .disabled(value <= range.lowerBound)
            .opacity(value <= range.lowerBound ? 0.5 : 1)

            // Value display
            Text("\(value)")
                .font(.body.monospacedDigit().weight(.medium))
                .frame(minWidth: 36)

            // Increment
            Button {
                guard value < range.upperBound else { return }
                value = min(value + step, range.upperBound)
                onIncrement()
            } label: {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .padding(8)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Circle())
            }
            .disabled(value >= range.upperBound)
            .opacity(value >= range.upperBound ? 0.5 : 1)
        }
        .foregroundColor(.primary)
    }
}
