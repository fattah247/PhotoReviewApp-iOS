//
//  SettingsView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @State private var showingDatePicker = false
    @State private var selectedMonth = Date()
    @State private var showSavedConfirmation = false
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    notificationsSection
                    repeatIntervalSection
                    scheduleDetailsSection
                    saveButton
                }
                .zIndex(0) // Ensure form stays behind overlay
                
                // Save confirmation overlay
                if showSavedConfirmation {
                    ConfirmationOverlay()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .zIndex(1) // Bring overlay to front
                        .animation(.easeInOut(duration: 0.3), value: showSavedConfirmation)
                }
            }
            .navigationTitle("Notification Settings")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var notificationsSection: some View {
        Section(header: Label("Notifications", systemImage: "bell.fill")) {
            Toggle("Enable Notifications", isOn: $settingsVM.isNotificationsEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .onReceive(settingsVM.$isNotificationsEnabled) { enabled in
                    if enabled {
                        settingsVM.requestNotificationPermission()
                    }
                }
            
            if settingsVM.isNotificationsEnabled {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    DatePicker("Time", selection: $settingsVM.notificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                }
            }
        }
        .headerProminence(.increased)
    }
    
    private var repeatIntervalSection: some View {
        Section(header: Label("Repeat Schedule", systemImage: "repeat")) {
            Picker("Repeat", selection: $settingsVM.repeatInterval) {
                ForEach(RepeatInterval.allCases) { interval in
                    Label(interval.rawValue.capitalized, systemImage: interval.iconName)
                        .tag(interval)
                }
            }
            .pickerStyle(.segmented)
            
            Text(repeatIntervalDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
    
    private var scheduleDetailsSection: some View {
        Group {
            if settingsVM.isNotificationsEnabled {
                switch settingsVM.repeatInterval {
                case .daily:
                    EmptyView()
                    
                case .weekly:
                    weeklySelectionSection
                    
                case .monthly:
                    monthlySelectionSection
                }
            }
        }
    }
    
    private var weeklySelectionSection: some View {
         Section(header: Text("Select Days of Week")) {
             LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                 ForEach(Weekday.allCases) { day in
                     WeekdaySelectionButton(
                         day: day,
                         isSelected: settingsVM.selectedWeeklyDays.contains(day)
                     ) {
                         withAnimation(.spring()) {
                             if settingsVM.selectedWeeklyDays.contains(day) {
                                 settingsVM.selectedWeeklyDays.removeAll { $0 == day }
                             } else {
                                 settingsVM.selectedWeeklyDays.append(day)
                             }
                         }
                     }
                 }
             }
             .padding(.vertical, 8)
         }
     }
    
    private var monthlySelectionSection: some View {
        Section(header: Text("Select Days of Month")) {
            Button(action: { showingDatePicker.toggle() }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("Select Specific Dates")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                monthlyDatePicker
            }
            
            if !settingsVM.selectedMonthlyDays.isEmpty {
                selectedDatesPreview
            }
        }
    }
    
    private var monthlyDatePicker: some View {
        NavigationView {
            VStack {
                CalendarView(interval: Calendar.current.dateInterval(of: .year, for: Date())!) { date in
                    DateSelectionCell(
                        date: date,
                        selectedDays: $settingsVM.selectedMonthlyDays,
                        notificationTime: $settingsVM.notificationTime
                    )
                }
                .padding()
                
                Button("Clear Selection") {
                    settingsVM.selectedMonthlyDays.removeAll()
                }
                .padding()
            }
            .navigationTitle("Select Dates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showingDatePicker = false }
                }
            }
        }
    }
    
    private var selectedDatesPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(settingsVM.selectedMonthlyDays.sorted(), id: \.self) { day in
                    Text("\(day)")
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var saveButton: some View {
        Section {
            Button(action: {
                settingsVM.saveSettings()
                
                // Trigger overlay with animation
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSavedConfirmation = true
                }
                
                // Auto-hide after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSavedConfirmation = false
                    }
                }
            }) {
                HStack {
                    Spacer()
                    Label("Save Settings", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canSaveSettings)
            .listRowBackground(Color.clear)
        }
    }
    
    private struct ConfirmationOverlay: View {
        var body: some View {
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("Settings Saved Successfully!")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding()
                .transition(.scale) // Add scale transition
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var canSaveSettings: Bool {
        guard settingsVM.isNotificationsEnabled else { return true }
        
        switch settingsVM.repeatInterval {
        case .daily:
            return true
        case .weekly:
            return !settingsVM.selectedWeeklyDays.isEmpty
        case .monthly:
            return !settingsVM.selectedMonthlyDays.isEmpty
        }
    }
    
    private var repeatIntervalDescription: String {
        switch settingsVM.repeatInterval {
        case .daily:
            return "Notifications will repeat every day at the selected time"
        case .weekly:
            return "Notifications will repeat weekly on selected days"
        case .monthly:
            return "Notifications will repeat monthly on selected dates"
        }
    }
    
    // MARK: - Subviews
    struct WeekdaySelectionButton: View {
        let day: Weekday
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack {
                    Text(day.displayName.prefix(3))
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(
                            isSelected ? Color.blue : Color.gray.opacity(0.1)
                        )
                        .foregroundColor(isSelected ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .contentShape(Rectangle())
                }
            }
            .buttonStyle(.plain)
        }
    }
}




struct DateSelectionCell: View {
    let date: Date
    @Binding var selectedDays: [Int]
    @Binding var notificationTime: Date
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    private var isSameMonth: Bool {
        Calendar.current.isDate(date, equalTo: notificationTime, toGranularity: .month)
    }
    
    private var isSelected: Bool {
        selectedDays.contains(dayNumber)
    }
    
    var body: some View {
        Text("\(dayNumber)")
            .frame(width: 40, height: 40)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundColor(isSelected ? .white : isSameMonth ? .primary : .secondary)
            .clipShape(Circle())
            .onTapGesture {
                if isSameMonth {
                    withAnimation {
                        if selectedDays.contains(dayNumber) {
                            selectedDays.removeAll { $0 == dayNumber }
                        } else {
                            selectedDays.append(dayNumber)
                        }
                    }
                }
            }
            .opacity(isSameMonth ? 1 : 0.5)
    }
}

// MARK: - RepeatInterval Extension
extension RepeatInterval {
    var iconName: String {
        switch self {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar.circle.fill"
        case .monthly: return "moon.fill"
        }
    }
}

