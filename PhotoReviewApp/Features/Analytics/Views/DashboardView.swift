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
    @State private var animateElements = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                storageCard
                streakCard
                statsGrid
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .opacity(animateElements ? 1 : 0)
            .offset(y: animateElements ? 0 : 20)
        }
        .navigationTitle("Photo Insights")
        .background(Color(.systemGroupedBackground))
        .onAppear {
            withAnimation(.spring(duration: 0.8)) {
                animateElements = true
            }
        }
    }

    private var storageCard: some View {
        MetricCard(
            title: "Storage Saved",
            icon: "externaldrive.badge.plus",
            value: analytics.totalStorageSaved.formatted(.byteCount(style: .file)),
            gradient: LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .scaleEffect(animateElements ? 1 : 0.8)
    }

    private var streakCard: some View {
        MetricCard(
            title: "Current Streak",
            icon: "flame.fill",
            value: "\(analytics.currentStreak) Days",
            gradient: LinearGradient(
                colors: [.orange, .red],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .scaleEffect(animateElements ? 1 : 0.8)
        .animation(.spring().delay(0.1), value: animateElements)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
            MetricBadge(title: "Reviewed", value: "\(analytics.totalReviewed)", icon: "checkmark.circle.fill", color: .green)
            MetricBadge(title: "Deleted", value: "\(analytics.totalDeleted)", icon: "trash.fill", color: .red)
            MetricBadge(title: "Bookmarked", value: "\(analytics.totalBookmarked)", icon: "bookmark.fill", color: .blue)
        }
        .opacity(animateElements ? 1 : 0)
        .animation(.easeIn(duration: 0.4).delay(0.2), value: animateElements)
    }
}
