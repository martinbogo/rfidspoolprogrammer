//
//  SettingsView.swift
//  Spool Programmer
//
//  App settings and preferences screen
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // General Settings
                Section {
                    Picker("Default Spool Size", selection: $settings.defaultSpoolSize) {
                        ForEach([SpoolSize.kg025, .kg05, .kg075, .kg1, .kg2, .kg3, .kg5], id: \.self) { size in
                            Text(size.displayName).tag(size)
                        }
                    }
                    
                    Picker("Temperature Unit", selection: $settings.temperatureUnit) {
                        ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                } header: {
                    Text("General")
                } footer: {
                    Text("Default spool size will be pre-selected when resetting or starting fresh.")
                }
                
                // NFC Settings
                Section {
                    Toggle("Auto-Verify After Write", isOn: $settings.autoVerifyEnabled)
                    Toggle("Haptic Feedback", isOn: $settings.hapticFeedbackEnabled)
                } header: {
                    Text("NFC Operations")
                } footer: {
                    Text("Auto-verify reads the tag after writing to ensure data was written correctly. Haptic feedback provides tactile confirmation of operations.")
                }
                
                // Advanced Settings
                Section {
                    Toggle("Show Debug Information", isOn: $settings.showDebugInfo)
                } header: {
                    Text("Advanced")
                } footer: {
                    Text("Debug information shows detailed technical data during NFC operations.")
                }
                
                // Reset Section
                Section {
                    Button(role: .destructive) {
                        settings.resetToDefaults()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Settings to Defaults")
                        }
                    }
                } footer: {
                    Text("This will reset all settings to their default values.")
                }
                
                // App Info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(settings: AppSettings.shared)
}
