//
//  CalendarView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//
import SwiftUI
import Foundation

struct CalendarView<Content: View>: View {
    let interval: DateInterval
    @ViewBuilder let content: (Date) -> Content
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(monthsInInterval(), id: \.self) { month in
                    Section(header: headerView(for: month)) {
                        ForEach(daysInMonth(month), id: \.self) { date in
                            content(date)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func headerView(for month: Date) -> some View {
        HStack {
            Text(month, format: .dateTime.month(.wide).year())
                .font(.headline)
                .padding(.vertical)
            Spacer()
        }
    }
    
    private func monthsInInterval() -> [Date] {
        Calendar.current.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    private func daysInMonth(_ month: Date) -> [Date] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: month) else {
            return []
        }
        return Calendar.current.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }
            if date > interval.end {
                stop = true
                return
            }
            dates.append(date)
        }
        
        return dates
    }
}

