//
//  ReviewStatsWidget.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 04/02/25.
//
import WidgetKit
import SwiftUI
import CoreData
import Photos
import OSLog

struct ReviewStatsWidget: Widget {
    let kind: String = Constants.Widget.kind
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StatsTimelineProvider()
        ) { (entry: StatsEntry) in
            StatsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Review Stats")
        .description("Track your photo review progress")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StatsWidgetView: View {
    var entry: StatsEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .symbolRenderingMode(.multicolor)
                Text("Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(entry.streak)")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
            }
            
            Divider()
            
            HStack {
                Image(systemName: "opticaldisc.fill")
                    .symbolRenderingMode(.multicolor)
                Text("Saved")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.saved.formatted(.byteCount(style: .file)))
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
//            HStack {
//                Spacer()
//                Image(systemName: "photo.on.rectangle.angled")
//                    .symbolRenderingMode(.multicolor)
//                    .frame(width: 24, height: 24)
//                Text("PhotoReview")
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
        }
        .padding()
    }
}

struct StatsTimelineProvider: TimelineProvider {
    typealias Entry = StatsEntry
    
    func placeholder(in context: Context) -> StatsEntry {
        StatsEntry(date: Date(), streak: 0, saved: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StatsEntry) -> Void) {
        let entry = StatsEntry(date: Date(), streak: 7, saved: 1024 * 1024 * 500)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsEntry>) -> Void) {
        let entry = StatsEntry(date: Date(), streak: 7, saved: 1024 * 1024 * 500)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct StatsEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let saved: Int64
}


//struct StatsTimelineProvider: TimelineProvider {
//    typealias Entry = StatsEntry
//
//    private let context = CoreDataManager.shared.viewContext
//
//    func placeholder(in context: Context) -> StatsEntry {
//        StatsEntry(date: Date(), streak: 7, saved: 1024 * 1024 * 500)
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (StatsEntry) -> Void) {
//        let entry = StatsEntry(date: Date(), streak: 7, saved: 1024 * 1024 * 500)
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsEntry>) -> Void) {
//        let entry = StatsEntry(date: Date(), streak: 7, saved: 1024 * 1024 * 500)
//        let timeline = Timeline(entries: [entry], policy: .never)
//        completion(timeline)
//    }
//
//    private func fetchLatestAnalytics() -> AnalyticsEntity {
//        let request: NSFetchRequest<AnalyticsEntity> = AnalyticsEntity.fetchRequest()
//        do {
//            return try context.fetch(request).first ?? AnalyticsEntity(context: context)
//        } catch {
//            Logger.log("Error fetching analytics for widget: \(error)", log: .coreData)
//            return AnalyticsEntity(context: context)
//        }
//    }
//}
