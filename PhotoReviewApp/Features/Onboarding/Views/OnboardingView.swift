//
//  OnboardingView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 04/02/25.
//
import SwiftUI
import Photos
import CoreData
import OSLog

struct OnboardingView: View {
    @EnvironmentObject var photoService: PhotoLibraryService
    @EnvironmentObject var notificationService: NotificationService
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                permissionsPage.tag(0)
                notificationsPage.tag(1)
                completionPage.tag(2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
    
    private var permissionsPage: some View {
        VStack(spacing: 30) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
            
            Text("Photo Access Needed")
                .font(.largeTitle.weight(.bold))
            
            Text("To review your photos, we need access to your photo library. Your photos will never leave your device.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Grant Access") {
                Task {
                    let status = await photoService.requestAuthorization()
                    switch status {
                    case .authorized:
                        print("Access authorized.")
                    case .limited:
                        print("Access limited.")
                    case .denied, .restricted:
                        print("Access denied or restricted.")
                    case .notDetermined:
                        print("Status not determined.")
                    @unknown default:
                        print("Unknown status.")
                    }
                }
            }

            .contentShape(Rectangle())  // Ensure the entire button area is tappable
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var notificationsPage: some View {
        VStack(spacing: 30) {
            Image(systemName: "bell.badge")
                .font(.system(size: 60))
            
            Text("Daily Reminders")
                .font(.largeTitle.weight(.bold))
            
            Text("Enable notifications to get daily reminders to review your photos. You can customize this later in settings.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Enable Notifications") {
                Task {
                    let granted = await notificationService.requestAuthorization()
                    print("Notification authorization granted:", granted)
                }
            }
            .contentShape(Rectangle())
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    
    private var completionPage: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("You're All Set!")
                .font(.largeTitle.weight(.bold))
            
            Text("Start reviewing your photos or customize your preferences in settings.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            NavigationLink {
                MainTabView()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .contentShape(Rectangle())
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
