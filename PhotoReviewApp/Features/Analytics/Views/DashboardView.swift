//
//  DashboardView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 03/02/25.
//
import Photos
import CoreData
import SwiftUI
import OSLog

struct DashboardView: View {
    @EnvironmentObject var analytics: CoreDataAnalyticsService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                storageCard
                streakCard
                statsGrid
            }
            .padding()
        }
        .navigationTitle("Statistics")
    }
    
    private var storageCard: some View {
        MetricCard(title: "Storage Saved", icon: "externaldrive", value: analytics.totalStorageSaved.formatted(.byteCount(style: .file)))
    }
    
    private var streakCard: some View {
        MetricCard(title: "Current Streak", icon: "flame", value: "\(analytics.currentStreak) Days")
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            MetricBadge(title: "Reviewed", value: "\(analytics.totalReviewed)", icon: "checkmark.circle")
            MetricBadge(title: "Deleted", value: "\(analytics.totalDeleted)", icon: "trash")
            MetricBadge(title: "Bookmarked", value: "\(analytics.totalBookmarked)", icon: "bookmark")
        }
    }
}
