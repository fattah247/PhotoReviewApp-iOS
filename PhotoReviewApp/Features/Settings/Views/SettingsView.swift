import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @EnvironmentObject var haptic: HapticService
    @Environment(\.colorScheme) var colorScheme
    @State private var showTrashConfirmation = false
    @State private var showSaveConfirmation = false

    var body: some View {
        NavigationStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            notificationsSection
                            reviewPreferencesSection
                            repetitionSection
                            deletionSection
                            
                            // Add bottom spacer to ensure content isn't covered
                            Color.clear.frame(height: 60)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        // Add the overlay directly to the VStack
                        .overlay(
                            saveConfirmationOverlay
                                .padding(.bottom, 24),
                            alignment: .bottom
                        )
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
                .alert("Confirm Deletion", isPresented: $showTrashConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        settings.emptyTrash()
                    }
                } message: {
                    Text("Are you sure you want to permanently delete all items in the trash?")
                }
    }
    // MARK: - Sections

    private var notificationsSection: some View {
        SectionCard(
            title: LocalizedStrings.notificationsSection,
            icon: "bell.badge.fill",
            color: .indigo
        ) {
            VStack(spacing: 0) {
                Toggle(isOn: $settings.isNotificationsEnabled) {
                    SettingRow(icon: "bell",
                               title: LocalizedStrings.notificationsSection,
                               iconColor: .indigo)
                }
                .toggleStyle(SwitchToggleStyle(tint: .indigo))
                .padding(.vertical, 12)
                .dynamicTypeSize(.medium ... .accessibility2)

                if settings.isNotificationsEnabled {
                    Divider()
                    SettingRow(icon: "clock",
                               title: LocalizedStrings.notificationBody,
                               iconColor: .indigo) {
                        DatePicker(
                            "",
                            selection: $settings.notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                    .padding(.vertical, 12)
                    .dynamicTypeSize(.medium ... .accessibility2)
                } else {
                    Divider()
                    Text("— \(LocalizedStrings.notificationBody)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 12)
                        .dynamicTypeSize(.medium ... .accessibility2)
                }
            }
        }
    }

    private var reviewPreferencesSection: some View {
        SectionCard(
            title: LocalizedStrings.settingsTitle,
            icon: "photo.on.rectangle.angled",
            color: .teal
        ) {
            VStack(spacing: 0) {
                SettingRow(icon: "photo.stack",
                           title: "Photos per Session",
                           iconColor: .teal) {
                    IncrementDecrementStepper(
                        value: $settings.photoLimit,
                        range: 5...50,
                        step: 5,
                        onIncrement: { haptic.impact(.light) },
                        onDecrement: { haptic.impact(.light) }
                    )
                }
                .padding(.vertical, 12)
                .dynamicTypeSize(.medium ... .accessibility2)

                Divider()

                SettingRow(icon: "arrow.up.arrow.down",
                           title: "Sorting Method",
                           iconColor: .teal) {
                    Picker("", selection: $settings.sortOption) {
                        ForEach(PhotoSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue.capitalized).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: settings.sortOption) { haptic.impact(.medium) }
                }
                .padding(.vertical, 12)
                .dynamicTypeSize(.medium ... .accessibility2)
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
                SettingRow(icon: "calendar",
                           title: "Repeat Schedule",
                           iconColor: .orange) {
                    Picker("", selection: $settings.repeatInterval) {
                        ForEach(RepeatInterval.allCases, id: \.self) { interval in
                            Text(interval.rawValue.capitalized).tag(interval)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: settings.repeatInterval) { haptic.impact(.medium) }
                }
                .padding(.vertical, 12)
                .dynamicTypeSize(.medium ... .accessibility2)

                switch settings.repeatInterval {
                case .weekly:
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()
                        Text("Selected Days")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .dynamicTypeSize(.medium ... .accessibility2)
                        WeekdaySelectionView(selection: $settings.selectedWeeklyDays)
                    }
                    .padding(.vertical, 12)

                case .monthly:
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()
                        Text("Day of Month")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .dynamicTypeSize(.medium ... .accessibility2)
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

    private var deletionSection: some View {
        SectionCard(
            title: "Deletion Settings",
            icon: "trash.fill",
            color: .red
        ) {
            VStack(spacing: 0) {
                SettingRow(icon: "exclamationmark.shield",
                           title: "Notice PopUp",
                           iconColor: .red) {
                    Toggle("", isOn: $settings.showDeletionConfirmation)
                        .toggleStyle(SwitchToggleStyle(tint: .red))
                        .onChange(of: settings.showDeletionConfirmation) { haptic.impact(.light) }
                }
                .padding(.vertical, 12)
                .dynamicTypeSize(.medium ... .accessibility2)

                Divider()

                Button(role: .destructive) {
                    haptic.impact(.heavy)
                    showTrashConfirmation = true
                } label: {
                    SettingRow(icon: "trash",
                               title: "Empty Trash Now",
                               iconColor: .red)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 12)
                .accessibilityLabel("Empty Trash Now")
            }
        }
    }

    // MARK: – Overlays

    private var saveConfirmationOverlay: some View {
            Group {
                if showSaveConfirmation {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                        Text("Settings Saved")
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        Capsule()
                            .fill(.regularMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                            )
                    )
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 8, y: 2)
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSaveConfirmation)
        }

    // MARK: – Actions

    private func performSave() {
        haptic.notify(.success)
        settings.saveSettings()
        showSaveConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSaveConfirmation = false
        }
    }
}
