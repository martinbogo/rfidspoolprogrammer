# Unit Test Quick Reference

## Test File Structure

```
ACE_RFID_iOSTests.swift
├── FilamentType Tests (3 tests)
│   ├── Raw values validation
│   ├── Case count verification  
│   └── Codable encoding/decoding
│
├── SpoolSize Tests (4 tests)
│   ├── Raw values validation
│   ├── Byte conversion (toByte)
│   ├── Byte parsing (fromByte)
│   └── All cases count
│
├── TemperatureSettings Tests (3 tests)
│   ├── Default values
│   ├── Custom values
│   └── Codable encoding/decoding
│
├── FilamentProfile Tests (4 tests)
│   ├── Profile creation
│   ├── Display name formatting
│   ├── Codable encoding/decoding
│   └── Property validation
│
├── RFIDTagData Encoding/Decoding (10 tests)
│   ├── 144-byte format validation
│   ├── SKU encoding (bytes 0-11)
│   ├── Brand encoding (bytes 12-27)
│   ├── Type encoding (bytes 28-39)
│   ├── Color encoding (bytes 40-43, ABGR)
│   ├── Temperature encoding (bytes 44-51)
│   ├── Spool size encoding (byte 52)
│   ├── Full round-trip test
│   ├── Invalid data handling
│   └── Padding verification
│
├── FilamentDatabase Tests (6 tests)
│   ├── Initialization (18 profiles)
│   ├── Default profiles validation
│   ├── Add profile operation
│   ├── Remove profile operation
│   ├── Find profile by SKU
│   └── Filter by type
│
├── Color Conversion Tests (2 tests)
│   ├── Color to UIColor conversion
│   └── ABGR format validation
│
├── String Encoding Tests (1 test)
│   └── Padding and truncation
│
├── Edge Cases & Boundaries (6 tests)
│   ├── Temperature boundaries (0-500°C)
│   ├── Empty string handling
│   ├── All spool sizes round-trip
│   ├── All filament types round-trip
│   ├── Invalid byte arrays
│   └── Malformed data
│
└── Performance Tests (2 tests)
    ├── Encoding performance (1000 iterations)
    └── Decoding performance (1000 iterations)
```

## Key Test Scenarios

### ✅ Byte Layout Verification (144 bytes total)

```
Bytes 0-11:   SKU (12 bytes, UTF-8, null-padded)
Bytes 12-27:  Brand (16 bytes, UTF-8, null-padded)
Bytes 28-39:  Type (12 bytes, UTF-8, null-padded)
Bytes 40-43:  Color (4 bytes, ABGR format)
              [0] = Alpha (0xFF)
              [1] = Blue
              [2] = Green
              [3] = Red
Bytes 44-45:  Nozzle Min Temp (16-bit little-endian)
Bytes 46-47:  Nozzle Max Temp (16-bit little-endian)
Bytes 48-49:  Bed Min Temp (16-bit little-endian)
Bytes 50-51:  Bed Max Temp (16-bit little-endian)
Byte  52:     Spool Size (0x01=500g, 0x02=1kg, 0x04=2kg)
Bytes 53-143: Reserved/Padding (91 bytes)
```

### ✅ Data Integrity Tests

- **Encoding → Decoding**: Data survives round-trip
- **String Handling**: Truncation, padding, empty strings
- **Numeric Bounds**: Min/max temperatures, enum values
- **Color Accuracy**: RGB ↔ ABGR conversion

### ✅ Database Operations

- **18 Default Profiles**: 5 Anycubic + 13 Generic
- **Profile Management**: Add, remove, find, filter
- **SKU Matching**: Find profile by unique identifier

## Running Specific Test Groups

```swift
// Run only FilamentType tests
xcodebuild test -only-testing:ACE_RFID_iOSTests/ACE_RFID_iOSTests/testFilamentTypeRawValues
xcodebuild test -only-testing:ACE_RFID_iOSTests/ACE_RFID_iOSTests/testFilamentTypeAllCasesCount
xcodebuild test -only-testing:ACE_RFID_iOSTests/ACE_RFID_iOSTests/testFilamentTypeCodable

// Run only encoding/decoding tests
xcodebuild test -only-testing:ACE_RFID_iOSTests/ACE_RFID_iOSTests/testRFIDTagDataByteEncoding
xcodebuild test -only-testing:ACE_RFID_iOSTests/ACE_RFID_iOSTests/testRFIDTagDataRoundTrip

// Run performance tests
xcodebuild test -only-testing:ACE_RFID_iOSTests/ACE_RFID_iOSTests/testEncodingPerformance
xcodebuild test -only-testing:ACE_RFID_iOSTests/ACE_RFID_iOSTests/testDecodingPerformance
```

## Expected Test Results

✅ **All tests should pass** on first run
✅ **No external dependencies** required
✅ **Deterministic results** - tests don't rely on randomness
✅ **Fast execution** - entire suite runs in < 5 seconds

## Code Coverage Goals

Target coverage for tested components:
- **FilamentModel.swift**: 80%+ coverage
- **RFIDTagData encoding/decoding**: 95%+ coverage
- **FilamentDatabase**: 70%+ coverage
- **Enum types**: 100% coverage

## Test Maintenance

When adding new features:
1. **New FilamentType**: Add to `testAllFilamentTypesRoundTrip`
2. **New SpoolSize**: Add to `testAllSpoolSizesRoundTrip`
3. **Byte format changes**: Update layout documentation
4. **New profile fields**: Add encoding/decoding tests

## Debugging Failed Tests

If tests fail:
1. Check Xcode console for assertion messages
2. Review test name for what's being validated
3. Use breakpoints in test methods
4. Verify FilamentModel.swift hasn't changed byte layout
5. Check that all 18 default profiles are still present
