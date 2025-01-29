//
//  SettingsView.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 28/01/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Photo Review Time")) {
                    // Hour Picker
                    HStack {
                        Text("Hour")
                        Spacer()
                        Picker("Hour", selection: $settingsVM.reviewHour) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    // Minute Picker
                    HStack {
                        Text("Minute")
                        Spacer()
                        Picker("Minute", selection: $settingsVM.reviewMinute) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    Button("Schedule Notification") {
                        settingsVM.scheduleNotification()
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}
