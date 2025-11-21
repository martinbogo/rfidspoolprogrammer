//
//  FilamentModel.swift
//  ACE RFID iOS
//
//  Data models for filament management
//

import Foundation
import SwiftUI

// MARK: - Debug Helper
private func debugLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}

// MARK: - Filament Material Types
enum FilamentType: String, CaseIterable, Codable {
    case pla = "PLA"
    case plaMatte = "PLA Matte"
    case plaPlus = "PLA Plus"  // Changed: Match Anycubic's actual tag format (with space)
    case plaSilk = "PLA Silk"
    case abs = "ABS"
    case petg = "PETG"
    case tpu = "TPU"
    case nylon = "Nylon"
    case asa = "ASA"
    case pc = "PC"
    case pva = "PVA"
    case hips = "HIPS"
}

// MARK: - Filament Brands
let filamentBrands = [
    "Anycubic", "eSUN", "Hatchbox", "Overture", "Sunlu",
    "Prusament", "Polymaker", "3DXTech", "ColorFabb", "MatterHackers",
    "Inland", "Atomic", "Push Plastic", "PolyLite", "Other"
]

// MARK: - Spool Sizes
enum SpoolSize: String, CaseIterable, Codable {
    case kg0_25 = "0.25 KG"
    case kg0_5 = "0.5 KG"
    case kg0_75 = "0.75 KG"
    case kg1 = "1 KG"
    case kg2 = "2 KG"
    case kg3 = "3 KG"
    case kg5 = "5 KG"
    
    var lengthInMeters: Int {
        switch self {
        case .kg0_25: return 82
        case .kg0_5: return 165
        case .kg0_75: return 247
        case .kg1: return 330
        case .kg2: return 660
        case .kg3: return 990
        case .kg5: return 1650
        }
    }
}

// MARK: - Temperature Settings
struct TemperatureSettings: Codable, Hashable {
    var extruderMin: Int
    var extruderMax: Int
    var bedMin: Int
    var bedMax: Int
    
    static func defaultTemperatures(for type: FilamentType) -> TemperatureSettings {
        switch type {
        case .pla, .plaMatte, .plaSilk:
            return TemperatureSettings(extruderMin: 200, extruderMax: 220, bedMin: 50, bedMax: 60)
        case .plaPlus:
            return TemperatureSettings(extruderMin: 205, extruderMax: 225, bedMin: 50, bedMax: 70)
        case .abs:
            return TemperatureSettings(extruderMin: 230, extruderMax: 250, bedMin: 80, bedMax: 100)
        case .petg:
            return TemperatureSettings(extruderMin: 220, extruderMax: 250, bedMin: 70, bedMax: 80)
        case .tpu:
            return TemperatureSettings(extruderMin: 210, extruderMax: 230, bedMin: 40, bedMax: 60)
        case .nylon:
            return TemperatureSettings(extruderMin: 240, extruderMax: 260, bedMin: 70, bedMax: 90)
        case .asa:
            return TemperatureSettings(extruderMin: 240, extruderMax: 260, bedMin: 90, bedMax: 110)
        case .pc:
            return TemperatureSettings(extruderMin: 260, extruderMax: 280, bedMin: 90, bedMax: 110)
        case .pva:
            return TemperatureSettings(extruderMin: 180, extruderMax: 200, bedMin: 45, bedMax: 60)
        case .hips:
            return TemperatureSettings(extruderMin: 230, extruderMax: 245, bedMin: 90, bedMax: 110)
        }
    }
}

// MARK: - Filament Profile
struct FilamentProfile: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var brand: String
    var type: FilamentType
    var sku: String
    var temperatures: TemperatureSettings
    var isCustom: Bool
    
    var displayName: String {
        "\(brand) \(type.rawValue) \(sku)".trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Filament Database Manager
class FilamentDatabase: ObservableObject {
    @Published var profiles: [FilamentProfile] = []
    
    init() {
        loadDefaultProfiles()
        loadCustomProfiles()
    }
    
    private func loadDefaultProfiles() {
        // Default profiles matching the Android app
        let defaultProfiles = [
            FilamentProfile(name: "Anycubic PLA", brand: "Anycubic", type: .pla, 
                          sku: "AHPLA-001", 
                          temperatures: .defaultTemperatures(for: .pla), 
                          isCustom: false),
            FilamentProfile(name: "Anycubic PLA Plus", brand: "Anycubic", type: .plaPlus, 
                          sku: "AHPLLB-103", 
                          temperatures: .defaultTemperatures(for: .plaPlus), 
                          isCustom: false),
            FilamentProfile(name: "Anycubic ABS", brand: "Anycubic", type: .abs, 
                          sku: "AHABS-001", 
                          temperatures: .defaultTemperatures(for: .abs), 
                          isCustom: false),
            FilamentProfile(name: "Anycubic PETG", brand: "Anycubic", type: .petg, 
                          sku: "AHPETG-001", 
                          temperatures: .defaultTemperatures(for: .petg), 
                          isCustom: false),
            FilamentProfile(name: "Anycubic TPU", brand: "Anycubic", type: .tpu, 
                          sku: "AHTPU-001", 
                          temperatures: .defaultTemperatures(for: .tpu), 
                          isCustom: false),
            
            // Generic profiles for all filament types
            FilamentProfile(name: "Generic PLA", brand: "Generic", type: .pla, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .pla), 
                          isCustom: false),
            FilamentProfile(name: "Generic PLA Matte", brand: "Generic", type: .plaMatte, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .plaMatte), 
                          isCustom: false),
            FilamentProfile(name: "Generic PLA Plus", brand: "Generic", type: .plaPlus, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .plaPlus), 
                          isCustom: false),
            FilamentProfile(name: "Generic PLA Silk", brand: "Generic", type: .plaSilk, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .plaSilk), 
                          isCustom: false),
            FilamentProfile(name: "Generic ABS", brand: "Generic", type: .abs, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .abs), 
                          isCustom: false),
            FilamentProfile(name: "Generic PETG", brand: "Generic", type: .petg, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .petg), 
                          isCustom: false),
            FilamentProfile(name: "Generic TPU", brand: "Generic", type: .tpu, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .tpu), 
                          isCustom: false),
            FilamentProfile(name: "Generic Nylon", brand: "Generic", type: .nylon, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .nylon), 
                          isCustom: false),
            FilamentProfile(name: "Generic ASA", brand: "Generic", type: .asa, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .asa), 
                          isCustom: false),
            FilamentProfile(name: "Generic PC", brand: "Generic", type: .pc, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .pc), 
                          isCustom: false),
            FilamentProfile(name: "Generic PVA", brand: "Generic", type: .pva, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .pva), 
                          isCustom: false),
            FilamentProfile(name: "Generic HIPS", brand: "Generic", type: .hips, 
                          sku: "", 
                          temperatures: .defaultTemperatures(for: .hips), 
                          isCustom: false),
        ]
        
        profiles.append(contentsOf: defaultProfiles)
    }
    
    private func loadCustomProfiles() {
        if let data = UserDefaults.standard.data(forKey: "customFilamentProfiles"),
           let customProfiles = try? JSONDecoder().decode([FilamentProfile].self, from: data) {
            profiles.append(contentsOf: customProfiles)
        }
    }
    
    func saveCustomProfiles() {
        let customProfiles = profiles.filter { $0.isCustom }
        if let data = try? JSONEncoder().encode(customProfiles) {
            UserDefaults.standard.set(data, forKey: "customFilamentProfiles")
        }
    }
    
    func addProfile(_ profile: FilamentProfile) {
        var newProfile = profile
        newProfile.isCustom = true
        profiles.append(newProfile)
        saveCustomProfiles()
    }
    
    func updateProfile(_ profile: FilamentProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            saveCustomProfiles()
        }
    }
    
    func deleteProfile(_ profile: FilamentProfile) {
        profiles.removeAll { $0.id == profile.id }
        saveCustomProfiles()
    }
}

// MARK: - RFID Tag Data Structure
struct RFIDTagData {
    var profile: FilamentProfile
    var color: Color
    var spoolSize: SpoolSize
    
    // Convert to byte array for writing to NTAG
    func toBytes() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: 144)
        
        // Page 4: Magic bytes
        bytes[0] = 0x7B  // 123 in decimal
        bytes[1] = 0x00
        bytes[2] = 0x65  // 101 in decimal
        bytes[3] = 0x00
        
        // Pages 5-9: SKU (20 bytes)
        let skuBytes = profile.sku.padding(toLength: 20, withPad: "\0", startingAt: 0).data(using: .utf8)!
        bytes.replaceSubrange(4..<24, with: skuBytes)
        
        // Pages 10-14: Brand (20 bytes)
        let brandBytes = profile.brand.padding(toLength: 20, withPad: "\0", startingAt: 0).data(using: .utf8)!
        bytes.replaceSubrange(24..<44, with: brandBytes)
        
        // Pages 15-19: Type (20 bytes)
        let typeBytes = profile.type.rawValue.padding(toLength: 20, withPad: "\0", startingAt: 0).data(using: .utf8)!
        bytes.replaceSubrange(44..<64, with: typeBytes)
        
        // Page 20: Color (ABGR format)
        let colorComponents = UIColor(color).cgColor.components ?? [0, 0, 0, 1]
        let alpha = UInt8(colorComponents[3] * 255)
        let red = UInt8(colorComponents[0] * 255)
        let green = UInt8(colorComponents[1] * 255)
        let blue = UInt8(colorComponents[2] * 255)
        
        // Handle black color workaround (Anycubic treats 0,0,0 as transparent)
        var finalRed = red, finalGreen = green, finalBlue = blue
        if red == 0 && green == 0 && blue == 0 {
            finalRed = 1
            finalGreen = 1
            finalBlue = 1
        }
        
        bytes[64] = alpha
        bytes[65] = finalBlue  // Note: BGR order
        bytes[66] = finalGreen
        bytes[67] = finalRed
        
        // Page 24: Extruder temperature
        let extMinBytes = withUnsafeBytes(of: UInt16(profile.temperatures.extruderMin).littleEndian) { Array($0) }
        let extMaxBytes = withUnsafeBytes(of: UInt16(profile.temperatures.extruderMax).littleEndian) { Array($0) }
        bytes[80] = extMinBytes[0]
        bytes[81] = extMinBytes[1]
        bytes[82] = extMaxBytes[0]
        bytes[83] = extMaxBytes[1]
        
        // Page 29: Bed temperature
        let bedMinBytes = withUnsafeBytes(of: UInt16(profile.temperatures.bedMin).littleEndian) { Array($0) }
        let bedMaxBytes = withUnsafeBytes(of: UInt16(profile.temperatures.bedMax).littleEndian) { Array($0) }
        bytes[100] = bedMinBytes[0]
        bytes[101] = bedMinBytes[1]
        bytes[102] = bedMaxBytes[0]
        bytes[103] = bedMaxBytes[1]
        
        // Page 30: Filament parameters
        let diameter: UInt16 = 175  // 1.75mm
        let length = UInt16(spoolSize.lengthInMeters)
        let diameterBytes = withUnsafeBytes(of: diameter.littleEndian) { Array($0) }
        let lengthBytes = withUnsafeBytes(of: length.littleEndian) { Array($0) }
        bytes[104] = diameterBytes[0]
        bytes[105] = diameterBytes[1]
        bytes[106] = lengthBytes[0]
        bytes[107] = lengthBytes[1]
        
        // Page 31: Unknown constant
        bytes[108] = 0xE8
        bytes[109] = 0x03
        bytes[110] = 0x00
        bytes[111] = 0x00
        
        return bytes
    }
    
    // Parse from byte array read from NTAG
    static func fromBytes(_ bytes: [UInt8], database: FilamentDatabase) -> RFIDTagData? {
        guard bytes.count >= 112 else { return nil }
        guard bytes[0] != 0x00 else { return nil }  // Empty tag
        
        // Helper to clean strings - remove null bytes and trim
        func cleanString(_ data: Data) -> String {
            String(data: data, encoding: .utf8)?
                .replacingOccurrences(of: "\0", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        
        // Parse type
        let typeData = Data(bytes[44..<64])
        let typeString = cleanString(typeData)
        let filamentType = FilamentType.allCases.first { $0.rawValue == typeString } ?? .pla
        
        // Parse brand
        let brandData = Data(bytes[24..<44])
        let brand = cleanString(brandData)
        
        // Parse SKU
        let skuData = Data(bytes[4..<24])
        let sku = cleanString(skuData)
        
        // Parse color (ABGR format)
        let alpha = CGFloat(bytes[64]) / 255.0
        let blue = CGFloat(bytes[65]) / 255.0
        let green = CGFloat(bytes[66]) / 255.0
        let red = CGFloat(bytes[67]) / 255.0
        
        // Handle black color workaround
        var finalRed = red, finalGreen = green, finalBlue = blue
        if red < 0.01 && green < 0.01 && blue < 0.01 {
            finalRed = 0
            finalGreen = 0
            finalBlue = 0
        }
        
        let color = Color(red: finalRed, green: finalGreen, blue: finalBlue, opacity: alpha)
        
        // Parse temperatures
        let extMin = Int(UInt16(bytes[80]) | (UInt16(bytes[81]) << 8))
        let extMax = Int(UInt16(bytes[82]) | (UInt16(bytes[83]) << 8))
        let bedMin = Int(UInt16(bytes[100]) | (UInt16(bytes[101]) << 8))
        let bedMax = Int(UInt16(bytes[102]) | (UInt16(bytes[103]) << 8))
        
        let temps = TemperatureSettings(extruderMin: extMin, extruderMax: extMax, 
                                       bedMin: bedMin, bedMax: bedMax)
        
        // Parse length
        let length = Int(UInt16(bytes[106]) | (UInt16(bytes[107]) << 8))
        let spoolSize = SpoolSize.allCases.first { $0.lengthInMeters == length } ?? .kg1
        
        // Find or create profile
        let profileName = "\(brand) \(filamentType.rawValue) \(sku)".trimmingCharacters(in: .whitespaces)
        
        // Try to find existing profile by matching key properties
        var profile = database.profiles.first { 
            $0.brand == brand && $0.type == filamentType && $0.sku == sku
        }
        
        if profile == nil {
            // Create new profile and add to database
            // Mark as custom so user can delete it if needed
            let newProfile = FilamentProfile(
                name: profileName, 
                brand: brand, 
                type: filamentType, 
                sku: sku, 
                temperatures: temps, 
                isCustom: true  // Changed: Allow deletion of profiles read from tags
            )
            database.addProfile(newProfile)  // Changed: Use addProfile to persist to UserDefaults
            profile = database.profiles.last  // Get the newly added profile
            debugLog("📌 Created new custom profile from tag: \(profileName)")
        } else {
            // Update temperatures from tag
            profile?.temperatures = temps
            debugLog("📌 Found existing profile: \(profileName)")
        }
        
        guard let finalProfile = profile else { return nil }
        
        return RFIDTagData(profile: finalProfile, color: color, spoolSize: spoolSize)
    }
}
