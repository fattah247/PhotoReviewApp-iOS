//
//  SettingsView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @EnvironmentObject var haptic: HapticService
    
    var body: some View {
        NavigationStack {
            Form {
                notificationsSection
                photoSettingsSection
                deletionSection
                saveButton
            }
            .navigationTitle("Settings")
            .background(Color(.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(systemName: "gearshape.2.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
    
    private var notificationsSection: some View {
        Section {
            Toggle("Enable Reminders", isOn: $settings.isNotificationsEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            if settings.isNotificationsEnabled {
                DatePicker("Daily Time", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                
                Picker("Repeat Schedule", selection: $settings.repeatInterval) {
                    ForEach(RepeatInterval.allCases, id: \.self) { interval in
                        Text(interval.rawValue.capitalized)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        } header: {
            Text("Reminders")
        } footer: {
            Text("Get daily reminders to review your photos")
        }
    }
    
    private var photoSettingsSection: some View {
        Section {
            Stepper("Photos per Session: \(settings.photoLimit)",
                   value: $settings.photoLimit, in: 5...50, step: 5)
            
            Picker("Sorting Method", selection: $settings.sortOption) {
                ForEach(PhotoSortOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                }
            }
        } header: {
            Text("Review Preferences")
        }
    }
    
    private var deletionSection: some View {
        Section {
            Toggle("Show Confirmation", isOn: $settings.showDeletionConfirmation)
                .toggleStyle(SwitchToggleStyle(tint: .red))
            
            Button(role: .destructive) {
                haptic.impact(.heavy)
                settings.emptyTrash()
            } label: {
                Label("Empty Trash Now", systemImage: "trash")
            }
        }
    }
    
    private var saveButton: some View {
        Section {
            Button {
                haptic.notify(.success)
                settings.saveSettings()
            } label: {
                Text("Save Changes")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .listRowBackground(Color.clear)
        }
    }
}
