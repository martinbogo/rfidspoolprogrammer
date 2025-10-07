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
            List {
                                // General Settings
                Section(header: Text("General"), 
                        footer: Text("Default spool size will be pre-selected when resetting or starting fresh.")) {
                    Picker("Default Spool Size", selection: $settings.defaultSpoolSize) {
                        ForEach(SpoolSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    
                    Picker("Temperature Unit", selection: $settings.temperatureUnit) {
                        ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                }
                
                // NFC Settings
                Section(header: Text("NFC Operations"),
                        footer: Text("Auto-verify reads the tag after writing to ensure data was written correctly. Haptic feedback provides tactile confirmation of operations.")) {
                    Toggle("Auto-Verify After Write", isOn: $settings.autoVerifyEnabled)
                    Toggle("Haptic Feedback", isOn: $settings.hapticFeedbackEnabled)
                }
                
                // Advanced Settings
                Section(header: Text("Advanced"),
                        footer: Text("Debug information shows detailed technical data during NFC operations.")) {
                    Toggle("Show Debug Information", isOn: $settings.showDebugInfo)
                }
                
                // Reset Section
                Section(footer: Text("This will reset all settings to their default values.")) {
                    Button(role: .destructive) {
                        settings.resetToDefaults()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Settings to Defaults")
                        }
                    }
                }
                
                // App Info
                Section(header: Text("About")) {
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
