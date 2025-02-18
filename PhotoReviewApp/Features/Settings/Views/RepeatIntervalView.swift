//
//  RepeatIntervalView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 18/02/25.
//
import SwiftUI

struct RepeatIntervalView: View {
    @Binding var selection: RepeatInterval
    
    var body: some View {
        Form {
            ForEach(RepeatInterval.allCases, id: \.self) { interval in
                HStack {
                    Text(interval.rawValue.capitalized)
                    Spacer()
                    if selection == interval {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selection = interval
                }
            }
        }
        .navigationTitle("Repeat Schedule")
    }
}
