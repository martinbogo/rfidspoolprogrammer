//
//  ACE_RFID_iOSTests.swift
//  ACE RFID iOS Tests
//
//  Comprehensive unit tests for data models and business logic
//

import XCTest
import SwiftUI
@testable import ACE_RFID_iOS

final class ACE_RFID_iOSTests: XCTestCase {
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        // Reset any shared state before each test
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
}

// MARK: - FilamentType Tests

extension ACE_RFID_iOSTests {
    
    func testFilamentTypeRawValues() {
        XCTAssertEqual(FilamentType.pla.rawValue, "PLA")
        XCTAssertEqual(FilamentType.abs.rawValue, "ABS")
        XCTAssertEqual(FilamentType.petg.rawValue, "PETG")
        XCTAssertEqual(FilamentType.tpu.rawValue, "TPU")
    }
    
    func testFilamentTypeAllCasesCount() {
        // Ensure we have all 13 filament types
        XCTAssertEqual(FilamentType.allCases.count, 13)
    }
    
    func testFilamentTypeCodable() throws {
        let type = FilamentType.petg
        let encoded = try JSONEncoder().encode(type)
        let decoded = try JSONDecoder().decode(FilamentType.self, from: encoded)
        XCTAssertEqual(type, decoded)
    }
}

// MARK: - SpoolSize Tests

extension ACE_RFID_iOSTests {
    
    func testSpoolSizeRawValues() {
        XCTAssertEqual(SpoolSize.kg500g.rawValue, "500g")
        XCTAssertEqual(SpoolSize.kg1.rawValue, "1kg")
        XCTAssertEqual(SpoolSize.kg2.rawValue, "2kg")
    }
    
    func testSpoolSizeByteConversion() {
        XCTAssertEqual(SpoolSize.kg500g.toByte(), 0x01)
        XCTAssertEqual(SpoolSize.kg1.toByte(), 0x02)
        XCTAssertEqual(SpoolSize.kg2.toByte(), 0x04)
    }
    
    func testSpoolSizeFromByte() {
        XCTAssertEqual(SpoolSize.fromByte(0x01), .kg500g)
        XCTAssertEqual(SpoolSize.fromByte(0x02), .kg1)
        XCTAssertEqual(SpoolSize.fromByte(0x04), .kg2)
        XCTAssertEqual(SpoolSize.fromByte(0xFF), .kg1) // Default fallback
        XCTAssertEqual(SpoolSize.fromByte(0x00), .kg1) // Default fallback
    }
    
    func testSpoolSizeAllCases() {
        XCTAssertEqual(SpoolSize.allCases.count, 3)
    }
}

// MARK: - TemperatureSettings Tests

extension ACE_RFID_iOSTests {
    
    func testTemperatureSettingsDefaults() {
        let temps = TemperatureSettings()
        XCTAssertEqual(temps.nozzleMin, 190)
        XCTAssertEqual(temps.nozzleMax, 230)
        XCTAssertEqual(temps.bedMin, 45)
        XCTAssertEqual(temps.bedMax, 65)
    }
    
    func testTemperatureSettingsCustomValues() {
        let temps = TemperatureSettings(
            nozzleMin: 200,
            nozzleMax: 250,
            bedMin: 50,
            bedMax: 70
        )
        XCTAssertEqual(temps.nozzleMin, 200)
        XCTAssertEqual(temps.nozzleMax, 250)
        XCTAssertEqual(temps.bedMin, 50)
        XCTAssertEqual(temps.bedMax, 70)
    }
    
    func testTemperatureSettingsCodable() throws {
        let temps = TemperatureSettings(nozzleMin: 210, nozzleMax: 240, bedMin: 55, bedMax: 75)
        let encoded = try JSONEncoder().encode(temps)
        let decoded = try JSONDecoder().decode(TemperatureSettings.self, from: encoded)
        
        XCTAssertEqual(temps.nozzleMin, decoded.nozzleMin)
        XCTAssertEqual(temps.nozzleMax, decoded.nozzleMax)
        XCTAssertEqual(temps.bedMin, decoded.bedMin)
        XCTAssertEqual(temps.bedMax, decoded.bedMax)
    }
}

// MARK: - FilamentProfile Tests

extension ACE_RFID_iOSTests {
    
    func testFilamentProfileCreation() {
        let profile = FilamentProfile(
            name: "Test PLA",
            brand: "TestBrand",
            type: .pla,
            sku: "TEST-001",
            temperatures: TemperatureSettings(nozzleMin: 200, nozzleMax: 220, bedMin: 50, bedMax: 60),
            isCustom: true
        )
        
        XCTAssertEqual(profile.name, "Test PLA")
        XCTAssertEqual(profile.brand, "TestBrand")
        XCTAssertEqual(profile.type, .pla)
        XCTAssertEqual(profile.sku, "TEST-001")
        XCTAssertEqual(profile.temperatures.nozzleMin, 200)
        XCTAssertTrue(profile.isCustom)
    }
    
    func testFilamentProfileDisplayName() {
        let profile = FilamentProfile(
            name: "Special Edition",
            brand: "Anycubic",
            type: .pla,
            sku: "AC-PLA-001",
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        XCTAssertEqual(profile.displayName, "Anycubic Special Edition (PLA)")
    }
    
    func testFilamentProfileCodable() throws {
        let profile = FilamentProfile(
            name: "Test PETG",
            brand: "TestBrand",
            type: .petg,
            sku: "TB-PETG-100",
            temperatures: TemperatureSettings(nozzleMin: 230, nozzleMax: 250, bedMin: 70, bedMax: 80),
            isCustom: true
        )
        
        let encoded = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(FilamentProfile.self, from: encoded)
        
        XCTAssertEqual(profile.id, decoded.id)
        XCTAssertEqual(profile.name, decoded.name)
        XCTAssertEqual(profile.brand, decoded.brand)
        XCTAssertEqual(profile.type, decoded.type)
        XCTAssertEqual(profile.sku, decoded.sku)
        XCTAssertEqual(profile.isCustom, decoded.isCustom)
    }
}

// MARK: - RFIDTagData Encoding/Decoding Tests

extension ACE_RFID_iOSTests {
    
    func testRFIDTagDataByteEncoding() {
        let profile = FilamentProfile(
            name: "Test",
            brand: "Brand",
            type: .pla,
            sku: "SKU123",
            temperatures: TemperatureSettings(nozzleMin: 200, nozzleMax: 220, bedMin: 50, bedMax: 60),
            isCustom: false
        )
        
        let tagData = RFIDTagData(
            profile: profile,
            color: .red,
            spoolSize: .kg1
        )
        
        let bytes = tagData.toBytes()
        
        // Should be exactly 144 bytes (36 pages * 4 bytes)
        XCTAssertEqual(bytes.count, 144)
        
        // Verify SKU is in first 12 bytes
        let skuBytes = bytes.prefix(12)
        let skuString = String(bytes: skuBytes.filter { $0 != 0 }, encoding: .utf8)
        XCTAssertEqual(skuString, "SKU123")
        
        // Verify brand is in bytes 12-27 (16 bytes)
        let brandBytes = bytes[12..<28]
        let brandString = String(bytes: brandBytes.filter { $0 != 0 }, encoding: .utf8)
        XCTAssertEqual(brandString, "Brand")
        
        // Verify type is in bytes 28-39 (12 bytes)
        let typeBytes = bytes[28..<40]
        let typeString = String(bytes: typeBytes.filter { $0 != 0 }, encoding: .utf8)
        XCTAssertEqual(typeString, "PLA")
    }
    
    func testRFIDTagDataColorEncoding() {
        let profile = FilamentProfile(
            name: "Test",
            brand: "Brand",
            type: .pla,
            sku: "SKU",
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        let redData = RFIDTagData(profile: profile, color: .red, spoolSize: .kg1)
        let blueData = RFIDTagData(profile: profile, color: .blue, spoolSize: .kg1)
        
        let redBytes = redData.toBytes()
        let blueBytes = blueData.toBytes()
        
        // Color is at bytes 40-43 (ABGR format)
        let redColorBytes = Array(redBytes[40..<44])
        let blueColorBytes = Array(blueBytes[40..<44])
        
        // Colors should be different
        XCTAssertNotEqual(redColorBytes, blueColorBytes)
        
        // Alpha should be 0xFF (byte 0)
        XCTAssertEqual(redColorBytes[0], 0xFF)
        XCTAssertEqual(blueColorBytes[0], 0xFF)
    }
    
    func testRFIDTagDataTemperatureEncoding() {
        let profile = FilamentProfile(
            name: "Test",
            brand: "Brand",
            type: .pla,
            sku: "SKU",
            temperatures: TemperatureSettings(nozzleMin: 210, nozzleMax: 230, bedMin: 55, bedMax: 65),
            isCustom: false
        )
        
        let tagData = RFIDTagData(profile: profile, color: .white, spoolSize: .kg1)
        let bytes = tagData.toBytes()
        
        // Temperatures start at byte 44
        XCTAssertEqual(Int(bytes[44]) | (Int(bytes[45]) << 8), 210) // nozzleMin
        XCTAssertEqual(Int(bytes[46]) | (Int(bytes[47]) << 8), 230) // nozzleMax
        XCTAssertEqual(Int(bytes[48]) | (Int(bytes[49]) << 8), 55)  // bedMin
        XCTAssertEqual(Int(bytes[50]) | (Int(bytes[51]) << 8), 65)  // bedMax
    }
    
    func testRFIDTagDataSpoolSizeEncoding() {
        let profile = FilamentProfile(
            name: "Test",
            brand: "Brand",
            type: .pla,
            sku: "SKU",
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        let data500g = RFIDTagData(profile: profile, color: .white, spoolSize: .kg500g)
        let data1kg = RFIDTagData(profile: profile, color: .white, spoolSize: .kg1)
        let data2kg = RFIDTagData(profile: profile, color: .white, spoolSize: .kg2)
        
        let bytes500g = data500g.toBytes()
        let bytes1kg = data1kg.toBytes()
        let bytes2kg = data2kg.toBytes()
        
        // Spool size is at byte 52
        XCTAssertEqual(bytes500g[52], 0x01)
        XCTAssertEqual(bytes1kg[52], 0x02)
        XCTAssertEqual(bytes2kg[52], 0x04)
    }
    
    func testRFIDTagDataRoundTrip() {
        let originalProfile = FilamentProfile(
            name: "RoundTrip Test",
            brand: "TestBrand",
            type: .petg,
            sku: "RT-001",
            temperatures: TemperatureSettings(nozzleMin: 235, nozzleMax: 255, bedMin: 75, bedMax: 85),
            isCustom: false
        )
        
        let originalData = RFIDTagData(
            profile: originalProfile,
            color: Color(red: 0.8, green: 0.2, blue: 0.3),
            spoolSize: .kg2
        )
        
        let bytes = originalData.toBytes()
        XCTAssertEqual(bytes.count, 144)
        
        // Decode back
        let database = FilamentDatabase()
        guard let decodedData = RFIDTagData.fromBytes(bytes, database: database) else {
            XCTFail("Failed to decode bytes")
            return
        }
        
        // Verify profile data
        XCTAssertEqual(decodedData.profile.sku, "RT-001")
        XCTAssertEqual(decodedData.profile.brand, "TestBrand")
        XCTAssertEqual(decodedData.profile.type, .petg)
        XCTAssertEqual(decodedData.profile.temperatures.nozzleMin, 235)
        XCTAssertEqual(decodedData.profile.temperatures.nozzleMax, 255)
        XCTAssertEqual(decodedData.profile.temperatures.bedMin, 75)
        XCTAssertEqual(decodedData.profile.temperatures.bedMax, 85)
        
        // Verify spool size
        XCTAssertEqual(decodedData.spoolSize, .kg2)
    }
    
    func testRFIDTagDataDecodingInvalidData() {
        let database = FilamentDatabase()
        
        // Test with too short data
        let shortData = [UInt8](repeating: 0, count: 50)
        XCTAssertNil(RFIDTagData.fromBytes(shortData, database: database))
        
        // Test with empty data
        let emptyData = [UInt8]()
        XCTAssertNil(RFIDTagData.fromBytes(emptyData, database: database))
    }
    
    func testRFIDTagDataDecodingWithPadding() {
        let database = FilamentDatabase()
        
        // Create a minimal valid data structure
        var bytes = [UInt8](repeating: 0, count: 144)
        
        // Set SKU with padding
        let sku = "TEST"
        for (i, char) in sku.utf8.enumerated() {
            bytes[i] = char
        }
        
        // Set brand with padding
        let brand = "Brand"
        for (i, char) in brand.utf8.enumerated() {
            bytes[12 + i] = char
        }
        
        // Set type with padding
        let type = "PLA"
        for (i, char) in type.utf8.enumerated() {
            bytes[28 + i] = char
        }
        
        // Set color (white: ABGR = FF FF FF FF)
        bytes[40] = 0xFF // A
        bytes[41] = 0xFF // B
        bytes[42] = 0xFF // G
        bytes[43] = 0xFF // R
        
        // Set temperatures (little-endian)
        bytes[44] = 200 & 0xFF // nozzleMin low byte
        bytes[45] = (200 >> 8) & 0xFF // nozzleMin high byte
        bytes[46] = 220 & 0xFF
        bytes[47] = (220 >> 8) & 0xFF
        bytes[48] = 50 & 0xFF
        bytes[49] = (50 >> 8) & 0xFF
        bytes[50] = 60 & 0xFF
        bytes[51] = (60 >> 8) & 0xFF
        
        // Set spool size
        bytes[52] = 0x02 // 1kg
        
        let decoded = RFIDTagData.fromBytes(bytes, database: database)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.profile.sku, "TEST")
        XCTAssertEqual(decoded?.profile.brand, "Brand")
        XCTAssertEqual(decoded?.profile.type, .pla)
        XCTAssertEqual(decoded?.spoolSize, .kg1)
    }
}

// MARK: - FilamentDatabase Tests

extension ACE_RFID_iOSTests {
    
    func testFilamentDatabaseInitialization() {
        let database = FilamentDatabase()
        
        // Should have 18 default profiles (5 Anycubic + 13 Generic)
        XCTAssertEqual(database.profiles.count, 18)
    }
    
    func testFilamentDatabaseDefaultProfiles() {
        let database = FilamentDatabase()
        
        // Check for Anycubic profiles
        let anycubicProfiles = database.profiles.filter { $0.brand == "Anycubic" }
        XCTAssertEqual(anycubicProfiles.count, 5)
        
        // Check for Generic profiles
        let genericProfiles = database.profiles.filter { $0.brand == "Generic" }
        XCTAssertEqual(genericProfiles.count, 13)
        
        // Verify all 13 filament types are covered in generic profiles
        let genericTypes = Set(genericProfiles.map { $0.type })
        XCTAssertEqual(genericTypes.count, 13)
    }
    
    func testFilamentDatabaseAddProfile() {
        let database = FilamentDatabase()
        let initialCount = database.profiles.count
        
        let newProfile = FilamentProfile(
            name: "Custom Test",
            brand: "TestBrand",
            type: .abs,
            sku: "TEST-ABS",
            temperatures: TemperatureSettings(),
            isCustom: true
        )
        
        database.profiles.append(newProfile)
        XCTAssertEqual(database.profiles.count, initialCount + 1)
        
        // Verify the profile was added
        XCTAssertTrue(database.profiles.contains(where: { $0.id == newProfile.id }))
    }
    
    func testFilamentDatabaseRemoveProfile() {
        let database = FilamentDatabase()
        
        let customProfile = FilamentProfile(
            name: "To Remove",
            brand: "TestBrand",
            type: .pla,
            sku: "REMOVE-ME",
            temperatures: TemperatureSettings(),
            isCustom: true
        )
        
        database.profiles.append(customProfile)
        let countAfterAdd = database.profiles.count
        
        database.profiles.removeAll(where: { $0.id == customProfile.id })
        XCTAssertEqual(database.profiles.count, countAfterAdd - 1)
        XCTAssertFalse(database.profiles.contains(where: { $0.id == customProfile.id }))
    }
    
    func testFilamentDatabaseFindProfileBySKU() {
        let database = FilamentDatabase()
        
        let foundProfile = database.profiles.first(where: { $0.sku == "AC-PLA-BLACK-1KG" })
        XCTAssertNotNil(foundProfile)
        XCTAssertEqual(foundProfile?.brand, "Anycubic")
        XCTAssertEqual(foundProfile?.type, .pla)
    }
    
    func testFilamentDatabaseFilterByType() {
        let database = FilamentDatabase()
        
        let plaProfiles = database.profiles.filter { $0.type == .pla || $0.type == .plaPlus || $0.type == .plaMatte || $0.type == .plaSilk }
        XCTAssertGreaterThan(plaProfiles.count, 0)
        
        let petgProfiles = database.profiles.filter { $0.type == .petg }
        XCTAssertGreaterThan(petgProfiles.count, 0)
    }
}

// MARK: - Color Conversion Tests

extension ACE_RFID_iOSTests {
    
    func testColorToUIColorConversion() {
        let red = Color.red
        let uiColor = UIColor(red)
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        XCTAssertGreaterThan(r, 0.9) // Red should be close to 1.0
        XCTAssertLessThan(g, 0.1)    // Green should be close to 0
        XCTAssertLessThan(b, 0.1)    // Blue should be close to 0
    }
    
    func testColorABGRFormat() {
        // Test that color encoding uses ABGR format correctly
        let profile = FilamentProfile(
            name: "Test",
            brand: "Brand",
            type: .pla,
            sku: "SKU",
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        // Pure red: R=1.0, G=0, B=0
        let redData = RFIDTagData(profile: profile, color: .red, spoolSize: .kg1)
        let redBytes = redData.toBytes()
        
        // In ABGR format: [A=FF, B=00, G=00, R=FF]
        XCTAssertEqual(redBytes[40], 0xFF) // Alpha
        XCTAssertLessThan(redBytes[41], 10) // Blue (should be ~0)
        XCTAssertLessThan(redBytes[42], 10) // Green (should be ~0)
        XCTAssertGreaterThan(redBytes[43], 240) // Red (should be ~255)
    }
}

// MARK: - String Encoding Tests

extension ACE_RFID_iOSTests {
    
    func testStringToBytesPadding() {
        // Test that strings are properly padded or truncated
        let shortString = "ABC"
        let longString = "ThisIsAVeryLongStringThatExceedsTheLimit"
        
        // For SKU (12 bytes max)
        let profile1 = FilamentProfile(
            name: "Test",
            brand: "Brand",
            type: .pla,
            sku: shortString,
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        let profile2 = FilamentProfile(
            name: "Test",
            brand: "Brand",
            type: .pla,
            sku: longString,
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        let bytes1 = RFIDTagData(profile: profile1, color: .white, spoolSize: .kg1).toBytes()
        let bytes2 = RFIDTagData(profile: profile2, color: .white, spoolSize: .kg1).toBytes()
        
        // Both should encode to valid 144-byte arrays
        XCTAssertEqual(bytes1.count, 144)
        XCTAssertEqual(bytes2.count, 144)
        
        // Short string should have padding (null bytes)
        let skuBytes1 = bytes1.prefix(12)
        XCTAssertTrue(skuBytes1.contains(0))
        
        // Long string should be truncated to fit
        let skuBytes2 = bytes2.prefix(12)
        let decodedSKU = String(bytes: skuBytes2.filter { $0 != 0 }, encoding: .utf8)
        XCTAssertNotNil(decodedSKU)
        XCTAssertLessThanOrEqual(decodedSKU?.count ?? 0, 12)
    }
}

// MARK: - Edge Cases and Boundary Tests

extension ACE_RFID_iOSTests {
    
    func testTemperatureBoundaries() {
        // Test extreme temperature values
        let extremeTemps = TemperatureSettings(
            nozzleMin: 0,
            nozzleMax: 500,
            bedMin: 0,
            bedMax: 150
        )
        
        let profile = FilamentProfile(
            name: "Extreme",
            brand: "Brand",
            type: .pla,
            sku: "EXTREME",
            temperatures: extremeTemps,
            isCustom: false
        )
        
        let tagData = RFIDTagData(profile: profile, color: .white, spoolSize: .kg1)
        let bytes = tagData.toBytes()
        
        // Verify encoding doesn't corrupt values
        XCTAssertEqual(bytes.count, 144)
        
        // Decode and verify
        let database = FilamentDatabase()
        let decoded = RFIDTagData.fromBytes(bytes, database: database)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.profile.temperatures.nozzleMin, 0)
        XCTAssertEqual(decoded?.profile.temperatures.nozzleMax, 500)
    }
    
    func testEmptyStrings() {
        let profile = FilamentProfile(
            name: "",
            brand: "",
            type: .pla,
            sku: "",
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        let tagData = RFIDTagData(profile: profile, color: .white, spoolSize: .kg1)
        let bytes = tagData.toBytes()
        
        XCTAssertEqual(bytes.count, 144)
        
        // Should still be decodable
        let database = FilamentDatabase()
        let decoded = RFIDTagData.fromBytes(bytes, database: database)
        XCTAssertNotNil(decoded)
    }
    
    func testAllSpoolSizesRoundTrip() {
        let profile = FilamentProfile(
            name: "Test",
            brand: "Brand",
            type: .pla,
            sku: "TEST",
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        let database = FilamentDatabase()
        
        for spoolSize in SpoolSize.allCases {
            let tagData = RFIDTagData(profile: profile, color: .white, spoolSize: spoolSize)
            let bytes = tagData.toBytes()
            let decoded = RFIDTagData.fromBytes(bytes, database: database)
            
            XCTAssertNotNil(decoded, "Failed to decode spool size: \(spoolSize.rawValue)")
            XCTAssertEqual(decoded?.spoolSize, spoolSize, "Spool size mismatch for: \(spoolSize.rawValue)")
        }
    }
    
    func testAllFilamentTypesRoundTrip() {
        let database = FilamentDatabase()
        
        for filamentType in FilamentType.allCases {
            let profile = FilamentProfile(
                name: "Test",
                brand: "Brand",
                type: filamentType,
                sku: "TEST",
                temperatures: TemperatureSettings(),
                isCustom: false
            )
            
            let tagData = RFIDTagData(profile: profile, color: .white, spoolSize: .kg1)
            let bytes = tagData.toBytes()
            let decoded = RFIDTagData.fromBytes(bytes, database: database)
            
            XCTAssertNotNil(decoded, "Failed to decode filament type: \(filamentType.rawValue)")
            XCTAssertEqual(decoded?.profile.type, filamentType, "Filament type mismatch for: \(filamentType.rawValue)")
        }
    }
}

// MARK: - Performance Tests

extension ACE_RFID_iOSTests {
    
    func testEncodingPerformance() {
        let profile = FilamentProfile(
            name: "Performance Test",
            brand: "Brand",
            type: .pla,
            sku: "PERF-001",
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        let tagData = RFIDTagData(profile: profile, color: .blue, spoolSize: .kg1)
        
        measure {
            for _ in 0..<1000 {
                _ = tagData.toBytes()
            }
        }
    }
    
    func testDecodingPerformance() {
        let profile = FilamentProfile(
            name: "Performance Test",
            brand: "Brand",
            type: .pla,
            sku: "PERF-001",
            temperatures: TemperatureSettings(),
            isCustom: false
        )
        
        let tagData = RFIDTagData(profile: profile, color: .blue, spoolSize: .kg1)
        let bytes = tagData.toBytes()
        let database = FilamentDatabase()
        
        measure {
            for _ in 0..<1000 {
                _ = RFIDTagData.fromBytes(bytes, database: database)
            }
        }
    }
}
