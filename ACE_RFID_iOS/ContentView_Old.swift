//
//  ContentView.swift
//  ACE RFID iOS
//
//  Main user interface for RFID programming
//

import SwiftUI

struct ContentView: View {
    @StateObject private var filamentDB = FilamentDatabase()
    @StateObject private var nfcManager = NFCManager()
    
    @State private var selectedProfile: FilamentProfile?
    @State private var selectedColor: Color = .blue
    @State private var selectedSpoolSize: SpoolSize = .kg1
    @State private var autoRead = false
    
    @State private var showingColorPicker = false
    @State private var showingAddFilament = false
    @State private var showingEditFilament = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            Form {
                // Tag Info Section
                Section("NFC Tag Information") {
                    if !nfcManager.tagUID.isEmpty {
                        LabeledContent("Tag UID", value: nfcManager.tagUID)
                        LabeledContent("Tag Type", value: nfcManager.tagType)
                    } else {
                        Text("No tag detected")
                            .foregroundColor(.secondary)
                    }
                    
                    if !nfcManager.statusMessage.isEmpty {
                        Text(nfcManager.statusMessage)
                            .font(.caption)
                            .foregroundColor(nfcManager.statusMessage.contains("success") ? .green : .orange)
                    }
                }
                
                // Filament Selection
                Section("Filament Profile") {
                    Picker("Material", selection: $selectedProfile) {
                        Text("Select Material").tag(nil as FilamentProfile?)
                        ForEach(filamentDB.profiles) { profile in
                            Text(profile.displayName).tag(profile as FilamentProfile?)
                        }
                    }
                    
                    if let profile = selectedProfile {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Brand", value: profile.brand)
                            InfoRow(label: "Type", value: profile.type.rawValue)
                            if !profile.sku.isEmpty {
                                InfoRow(label: "SKU", value: profile.sku)
                            }
                            
                            Divider()
                            
                            Text("Temperature Settings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            InfoRow(label: "Extruder", 
                                   value: "\(profile.temperatures.extruderMin)°C - \(profile.temperatures.extruderMax)°C")
                            InfoRow(label: "Bed", 
                                   value: "\(profile.temperatures.bedMin)°C - \(profile.temperatures.bedMax)°C")
                        }
                        .font(.caption)
                        .padding(.vertical, 4)
                        
                        if profile.isCustom {
                            HStack {
                                Button(action: {
                                    showingEditFilament = true
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .buttonStyle(.bordered)
                                
                                Button(role: .destructive, action: {
                                    filamentDB.deleteProfile(profile)
                                    selectedProfile = nil
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    
                    Button(action: {
                        showingAddFilament = true
                    }) {
                        Label("Add Custom Filament", systemImage: "plus.circle")
                    }
                }
                
                // Color and Spool Settings
                Section("Spool Settings") {
                    Button(action: {
                        showingColorPicker = true
                    }) {
                        HStack {
                            Text("Color")
                            Spacer()
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedColor)
                                .frame(width: 60, height: 30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Picker("Spool Size", selection: $selectedSpoolSize) {
                        ForEach(SpoolSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                }
                
                // Actions
                Section("Actions") {
                    Toggle("Auto-read on tag detection", isOn: $autoRead)
                    
                    Button(action: {
                        nfcManager.startReadSession()
                    }) {
                        Label("Read Tag", systemImage: "arrow.down.doc")
                    }
                    .disabled(nfcManager.isScanning)
                    .onChange(of: nfcManager.lastReadBytes) { newBytes in
                        if let bytes = newBytes, let tagData = RFIDTagData.fromBytes(bytes, database: filamentDB) {
                            // Update UI with read data
                            selectedProfile = tagData.profile
                            selectedColor = tagData.color
                            selectedSpoolSize = tagData.spoolSize
                            nfcManager.lastReadData = tagData
                        }
                    }
                    
                    Button(action: {
                        nfcManager.checkTagLockStatus()
                    }) {
                        Label("Check Lock Status", systemImage: "lock.shield")
                    }
                    .disabled(nfcManager.isScanning)
                    
                    Button(action: {
                        guard let profile = selectedProfile else {
                            nfcManager.statusMessage = "Please select a filament profile"
                            return
                        }
                        
                        let tagData = RFIDTagData(
                            profile: profile,
                            color: selectedColor,
                            spoolSize: selectedSpoolSize
                        )
                        nfcManager.startWriteSession(data: tagData)
                    }) {
                        Label("Write Tag", systemImage: "arrow.up.doc")
                    }
                    .disabled(selectedProfile == nil || nfcManager.isScanning)
                    
                    Button(role: .destructive, action: {
                        nfcManager.startFormatSession()
                    }) {
                        Label("Format Tag", systemImage: "trash")
                    }
                    .disabled(nfcManager.isScanning)
                }
                
                // Lock Status Display
                if !nfcManager.tagLockStatus.isEmpty {
                    Section("Lock Status") {
                        Text(nfcManager.tagLockStatus)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                }
                
                // Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About ACE RFID iOS")
                            .font(.headline)
                        
                        Text("This app programs NTAG213/215/216 RFID tags for Anycubic 3D printer filament spools.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Based on the ACE-RFID project by DnG-Crafts")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("ACE RFID")
            .navigationBarTitleDisplayMode(horizontalSizeClass == .regular ? .large : .inline)
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: $selectedColor)
            }
            .sheet(isPresented: $showingAddFilament) {
                AddFilamentView(database: filamentDB)
            }
            .sheet(isPresented: $showingEditFilament) {
                if let profile = selectedProfile {
                    EditFilamentView(database: filamentDB, profile: profile)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// MARK: - Add Filament View

struct AddFilamentView: View {
    @ObservedObject var database: FilamentDatabase
    @Environment(\.dismiss) var dismiss
    
    @State private var brand = ""
    @State private var selectedBrand = "Anycubic"
    @State private var useCustomBrand = false
    @State private var type: FilamentType = .pla
    @State private var sku = ""
    @State private var extruderMin = 200
    @State private var extruderMax = 220
    @State private var bedMin = 50
    @State private var bedMax = 60
    
    var body: some View {
        NavigationView {
            Form {
                Section("Filament Information") {
                    Toggle("Custom Brand", isOn: $useCustomBrand)
                    
                    if useCustomBrand {
                        TextField("Brand Name", text: $brand)
                    } else {
                        Picker("Brand", selection: $selectedBrand) {
                            ForEach(filamentBrands, id: \.self) { brand in
                                Text(brand).tag(brand)
                            }
                        }
                    }
                    
                    Picker("Type", selection: $type) {
                        ForEach(FilamentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("SKU / Serial", text: $sku)
                }
                
                Section("Temperature Settings") {
                    Stepper("Extruder Min: \(extruderMin)°C", value: $extruderMin, in: 150...300, step: 5)
                    Stepper("Extruder Max: \(extruderMax)°C", value: $extruderMax, in: 150...300, step: 5)
                    Stepper("Bed Min: \(bedMin)°C", value: $bedMin, in: 0...120, step: 5)
                    Stepper("Bed Max: \(bedMax)°C", value: $bedMax, in: 0...120, step: 5)
                    
                    Button("Load Defaults for \(type.rawValue)") {
                        let temps = TemperatureSettings.defaultTemperatures(for: type)
                        extruderMin = temps.extruderMin
                        extruderMax = temps.extruderMax
                        bedMin = temps.bedMin
                        bedMax = temps.bedMax
                    }
                }
            }
            .navigationTitle("Add Filament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let finalBrand = useCustomBrand ? brand : selectedBrand
                        let profile = FilamentProfile(
                            name: "\(finalBrand) \(type.rawValue) \(sku)",
                            brand: finalBrand,
                            type: type,
                            sku: sku,
                            temperatures: TemperatureSettings(
                                extruderMin: extruderMin,
                                extruderMax: extruderMax,
                                bedMin: bedMin,
                                bedMax: bedMax
                            ),
                            isCustom: true
                        )
                        database.addProfile(profile)
                        dismiss()
                    }
                    .bold()
                    .disabled(useCustomBrand && brand.isEmpty)
                }
            }
            .onAppear {
                let temps = TemperatureSettings.defaultTemperatures(for: type)
                extruderMin = temps.extruderMin
                extruderMax = temps.extruderMax
                bedMin = temps.bedMin
                bedMax = temps.bedMax
            }
        }
    }
}

// MARK: - Edit Filament View

struct EditFilamentView: View {
    @ObservedObject var database: FilamentDatabase
    let profile: FilamentProfile
    @Environment(\.dismiss) var dismiss
    
    @State private var brand = ""
    @State private var type: FilamentType = .pla
    @State private var sku = ""
    @State private var extruderMin = 200
    @State private var extruderMax = 220
    @State private var bedMin = 50
    @State private var bedMax = 60
    
    var body: some View {
        NavigationView {
            Form {
                Section("Filament Information") {
                    TextField("Brand Name", text: $brand)
                    
                    Picker("Type", selection: $type) {
                        ForEach(FilamentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("SKU / Serial", text: $sku)
                }
                
                Section("Temperature Settings") {
                    Stepper("Extruder Min: \(extruderMin)°C", value: $extruderMin, in: 150...300, step: 5)
                    Stepper("Extruder Max: \(extruderMax)°C", value: $extruderMax, in: 150...300, step: 5)
                    Stepper("Bed Min: \(bedMin)°C", value: $bedMin, in: 0...120, step: 5)
                    Stepper("Bed Max: \(bedMax)°C", value: $bedMax, in: 0...120, step: 5)
                }
            }
            .navigationTitle("Edit Filament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedProfile = profile
                        updatedProfile.brand = brand
                        updatedProfile.type = type
                        updatedProfile.sku = sku
                        updatedProfile.name = "\(brand) \(type.rawValue) \(sku)"
                        updatedProfile.temperatures = TemperatureSettings(
                            extruderMin: extruderMin,
                            extruderMax: extruderMax,
                            bedMin: bedMin,
                            bedMax: bedMax
                        )
                        database.updateProfile(updatedProfile)
                        dismiss()
                    }
                    .bold()
                    .disabled(brand.isEmpty)
                }
            }
            .onAppear {
                brand = profile.brand
                type = profile.type
                sku = profile.sku
                extruderMin = profile.temperatures.extruderMin
                extruderMax = profile.temperatures.extruderMax
                bedMin = profile.temperatures.bedMin
                bedMax = profile.temperatures.bedMax
            }
        }
    }
}

#Preview {
    ContentView()
}
