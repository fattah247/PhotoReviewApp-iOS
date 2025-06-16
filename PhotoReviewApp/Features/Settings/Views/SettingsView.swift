import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @EnvironmentObject var haptic: HapticService
    @State private var showTrashConfirmation = false
    @State private var showSaveConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    notificationsSection
                    reviewPreferencesSection
                    repetitionSection
                    deletionSection
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        performSave()
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundColor(settings.hasUnsavedChanges ? .white : .secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                settings.hasUnsavedChanges
                                    ? Color.indigo
                                    : Color(.quaternarySystemFill)
                            )
                            .clipShape(Capsule())
                    }
                    .disabled(!settings.hasUnsavedChanges)
                    .buttonStyle(.plain)
                }
            }
        }
        .tint(.indigo)
        .overlay(saveConfirmationOverlay, alignment: .bottom)
        .alert("Empty Trash?", isPresented: $showTrashConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                settings.emptyTrash()
            }
        } message: {
            Text("This will permanently delete all items in the trash. This action cannot be undone.")
        }
    }
    
    // MARK: - Sections
    private var notificationsSection: some View {
        SectionCard(
            title: "Reminders",
            icon: "bell.badge.fill",
            color: .indigo
        ) {
            VStack(spacing: 0) {
                Toggle(isOn: $settings.isNotificationsEnabled) {
                    SettingRow(
                        icon: "bell",
                        title: "Enable Reminders",
                        iconColor: .indigo
                    )
                }
                .toggleStyle(SwitchToggleStyle(tint: .indigo))
                .padding(.vertical, 12)
                
                if settings.isNotificationsEnabled {
                    Divider()
                    
                    SettingRow(
                        icon: "clock",
                        title: "Reminder Time",
                        iconColor: .indigo
                    ) {
                        DatePicker(
                            "",
                            selection: $settings.notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                    .padding(.vertical, 12)
                }
            }
        }
    }
    
    private var reviewPreferencesSection: some View {
        SectionCard(
            title: "Review Preferences",
            icon: "photo.on.rectangle.angled",
            color: .teal
        ) {
            VStack(spacing: 0) {
                SettingRow(
                    icon: "photo.stack",
                    title: "Photos per Session",
                    iconColor: .teal
                ) {
                    IncrementDecrementStepper(
                        value: $settings.photoLimit,
                        range: 5...50,
                        step: 5,
                        onIncrement: { haptic.impact(.light) },
                        onDecrement: { haptic.impact(.light) }
                    )
                }
                .padding(.vertical, 12)
                
                Divider()
                
                SettingRow(
                    icon: "arrow.up.arrow.down",
                    title: "Sorting Method",
                    iconColor: .teal
                ) {
                    Picker("", selection: $settings.sortOption) {
                        ForEach(PhotoSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue.capitalized).tag(option)
                        }
                    }
                    .pickerStyle(.automatic)
                    .onChange(of: settings.sortOption) { haptic.impact(.medium) }
                }
                .padding(.vertical, 12)
            }
        }
    }
    
    private var repetitionSection: some View {
        SectionCard(
            title: "Repetition Schedule",
            icon: "repeat",
            color: .orange
        ) {
            VStack(spacing: 0) {
                SettingRow(
                    icon: "calendar",
                    title: "Repeat Schedule",
                    iconColor: .orange
                ) {
                    Picker("", selection: $settings.repeatInterval) {
                        ForEach(RepeatInterval.allCases, id: \.self) { interval in
                            Text(interval.rawValue.capitalized).tag(interval)
                        }
                    }
                    .pickerStyle(.automatic)
                    .onChange(of: settings.repeatInterval) { haptic.impact(.medium) }
                }
                .padding(.vertical, 12)
                
                
                
                Group {
                    switch settings.repeatInterval {
                    case .weekly:
                        Divider()
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Selected Days")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            WeekdaySelectionView(selection: $settings.selectedWeeklyDays)
                        }
                        .padding(.vertical, 12)
                        
                    case .monthly:
                        Divider()
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Day of Month")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            MonthDaySelectionView(selection: $settings.selectedMonthlyDay)
                        }
                        .padding(.vertical, 12)
                        
                    default:
                        EmptyView()
                    }
                }
                .transition(.opacity)
            }
        }
    }

    private var deletionSection: some View {
        SectionCard(
            title: "Deletion Settings",
            icon: "trash.fill",
            color: .red
        ) {
            VStack(spacing: 0) {
                SettingRow(
                    icon: "exclamationmark.shield",
                    title: "Notice PopUp",
                    iconColor: .red
                ) {
                    Toggle("", isOn: $settings.showDeletionConfirmation)
                        .toggleStyle(SwitchToggleStyle(tint: .red))
                        .onChange(of: settings.showDeletionConfirmation) { haptic.impact(.light) }
                }
                .padding(.vertical, 12)
                
                Divider()
                
                Button(role: .destructive) {
                    haptic.impact(.heavy)
                    showTrashConfirmation = true
                } label: {
                    SettingRow(
                        icon: "trash",
                        title: "Empty Trash Now",
                        iconColor: .red
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 12)
            }
        }
    }
    
    // MARK: - Enhanced Save Confirmation
    private var saveConfirmationOverlay: some View {
        Group {
            if showSaveConfirmation {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    Text("Settings Saved")
                        .font(.subheadline.weight(.medium))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    ZStack {
                        Capsule()
                            .fill(.regularMaterial)
                        Capsule()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    }
                )
                .compositingGroup()
                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                .padding(.bottom, 24)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    )
                )
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSaveConfirmation)
    }
    
    // MARK: - Actions
    private func performSave() {
        haptic.notify(.success)
        settings.saveSettings()
        showSaveConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSaveConfirmation = false
        }
    }
}

// MARK: - UI Components
struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(color)
                    .frame(width: 24, alignment: .center)
                
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            
            content()
                .padding(16)
                .background(Color(.tertiarySystemGroupedBackground))
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }
}

struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let iconColor: Color
    var trailingContent: () -> Content
    
    init(icon: String, title: String, iconColor: Color, @ViewBuilder trailingContent: @escaping () -> Content = { EmptyView() }) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundColor(iconColor)
                .frame(width: 24, alignment: .center)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            trailingContent()
        }
        .contentShape(Rectangle())
    }
}

struct IncrementDecrementStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                if value > range.lowerBound {
                    value = max(value - step, range.lowerBound)
                    onDecrement()
                }
            } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .padding(8)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Circle())
            }
            .disabled(value <= range.lowerBound)
            .opacity(value <= range.lowerBound ? 0.5 : 1)
            
            Text("\(value)")
                .font(.body.monospacedDigit().weight(.medium))
                .frame(minWidth: 36)
            
            Button {
                if value < range.upperBound {
                    value = min(value + step, range.upperBound)
                    onIncrement()
                }
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

