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
    @State private var showTrashConfirmation = false
    @State private var showSaveConfirmation = false
    
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
                        .foregroundStyle(.blue)
                        .scaleEffect(1.2)
                }
            }
            .confirmationDialog("Empty Trash", isPresented: $showTrashConfirmation) {
                Button("Empty Trash", role: .destructive) {
                    haptic.impact(.heavy)
                    settings.emptyTrash()
                }
            }
        }
        .overlay {
            if showSaveConfirmation {
                SaveConfirmationView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private var notificationsSection: some View {
        Section {
            Toggle("Enable Reminders", isOn: $settings.isNotificationsEnabled)
                .toggleStyle(.customSwitch(tint: .blue))
                .settingsRow(icon: "bell.badge", color: .blue)
            
            if settings.isNotificationsEnabled {
                DatePicker("Daily Time", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.graphical)
                    .settingsRow(icon: "clock", color: .blue)
                
                NavigationLink {
                    RepeatIntervalView(selection: $settings.repeatInterval)
                } label: {
                    HStack {
                        Image(systemName: "repeat")
                            .settingsIcon(color: .blue)
                        Text("Repeat Schedule")
                        Spacer()
                        Text(settings.repeatInterval.rawValue.capitalized)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            SectionHeaderView(title: "Reminders", icon: "bell.badge.fill", color: .blue)
        } footer: {
            Text("Daily reminders help maintain your review routine")
                .font(.caption)
        }
    }
    
    private var photoSettingsSection: some View {
        Section {
            Stepper(value: $settings.photoLimit, in: 5...50, step: 5) {
                HStack {
                    Image(systemName: "photo.stack")
                        .settingsIcon(color: .green)
                    Text("Photos per Session")
                    Spacer()
                    Text("\(settings.photoLimit)")
                        .foregroundColor(.secondary)
                }
            }
            
            Picker("Sorting Method", selection: $settings.sortOption) {
                ForEach(PhotoSortOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                }
            }
            .pickerStyle(.navigationLink)
            .settingsRow(icon: "arrow.up.arrow.down", color: .green)
        } header: {
            SectionHeaderView(title: "Review Preferences", icon: "photo.fill.on.rectangle.fill", color: .green)
        }
    }
    
    private var deletionSection: some View {
        Section {
            Toggle("Show Confirmation", isOn: $settings.showDeletionConfirmation)
                .toggleStyle(.customSwitch(tint: .red))
                .settingsRow(icon: "exclamationmark.triangle", color: .red)
            
            Button(role: .destructive) {
                haptic.impact(.medium)
                showTrashConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .settingsIcon(color: .red)
                    Text("Empty Trash Now")
                }
            }
        } header: {
            SectionHeaderView(title: "Deletion Settings", icon: "trash.fill", color: .red)
        }
    }
    
    private var saveButton: some View {
        Section {
            Button {
                withAnimation {
                    haptic.notify(.success)
                    settings.saveSettings()
                    showSaveConfirmation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showSaveConfirmation = false
                    }
                }
            } label: {
                Label("Save Changes", systemImage: "checkmark.circle.fill")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .listRowBackground(Color.clear)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Custom Components
private struct SectionHeaderView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .imageScale(.medium)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
    }
}

private struct SaveConfirmationView: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Settings Saved")
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .padding(.bottom)
    }
}

struct CustomSwitchToggleStyle: ToggleStyle {
    let tint: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 50, height: 32)
                .foregroundColor(configuration.isOn ? tint : Color(.systemFill))
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .animation(.spring(), value: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

extension View {
    func settingsRow(icon: String, color: Color) -> some View {
        self.modifier(SettingsRowModifier(icon: icon, color: color))
    }
    
    func settingsIcon(color: Color) -> some View {
        self
            .symbolVariant(.fill)
            .foregroundColor(color)
            .frame(width: 28)
    }
}

struct SettingsRowModifier: ViewModifier {
    let icon: String
    let color: Color
    
    func body(content: Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .settingsIcon(color: color)
            content
        }
    }
}

extension ToggleStyle where Self == CustomSwitchToggleStyle {
    static func customSwitch(tint: Color) -> CustomSwitchToggleStyle {
        CustomSwitchToggleStyle(tint: tint)
    }
}
