# ACE RFID iOS Unit Tests

Comprehensive unit tests for the ACE RFID iOS app.

## Setup Instructions

Since the test target needs to be properly configured in Xcode, follow these steps:

### 1. Add Test Target to Xcode Project

1. Open `ACE_RFID_iOS.xcodeproj` in Xcode
2. Click on the project in the Project Navigator (top-level item)
3. At the bottom of the target list, click the `+` button
4. Select **"Unit Testing Bundle"** under iOS
5. Name it: `ACE_RFID_iOSTests`
6. Set the "Target to be Tested" to: `ACE_RFID_iOS`
7. Click **Finish**

### 2. Add Test File to Target

1. In the Project Navigator, locate `ACE_RFID_iOSTests/ACE_RFID_iOSTests.swift`
2. If it's not already included, click the file
3. In the File Inspector (right panel), check the box next to `ACE_RFID_iOSTests` under "Target Membership"

### 3. Configure Test Target Settings

1. Select the `ACE_RFID_iOSTests` target
2. Go to the **Build Settings** tab
3. Search for "Module" and ensure:
   - **Defines Module** = YES (for main target)
   - **Enable Testing Search Paths** = YES (for test target)

### 4. Run Tests

- **Run all tests**: `Cmd + U`
- **Run single test**: Click the diamond icon next to any test function
- **View test results**: `Cmd + 9` (Test Navigator)

## Test Coverage

### ✅ Data Models
- **FilamentType**: Enum values, codable, all cases
- **SpoolSize**: Raw values, byte conversion, round-trip
- **TemperatureSettings**: Defaults, custom values, codable
- **FilamentProfile**: Creation, display name, codable

### ✅ RFID Encoding/Decoding
- **Byte Encoding**: 144-byte format, SKU/brand/type encoding
- **Color Encoding**: ABGR format, RGB conversion
- **Temperature Encoding**: Little-endian 16-bit values
- **Spool Size Encoding**: Byte value mapping
- **Round-Trip Tests**: Encode → Decode → Verify

### ✅ FilamentDatabase
- **Initialization**: Default profiles (18 total)
- **Default Profiles**: 5 Anycubic + 13 Generic
- **CRUD Operations**: Add, remove, find profiles
- **Filtering**: By type, brand, SKU

### ✅ Color Conversion
- **UIColor Conversion**: SwiftUI Color ↔ UIColor
- **ABGR Format**: Alpha-Blue-Green-Red byte order
- **RGB Components**: Extraction and encoding

### ✅ Edge Cases
- **Boundary Values**: Extreme temperatures, empty strings
- **Invalid Data**: Too short, empty, malformed bytes
- **String Padding**: Short strings, long strings (truncation)
- **All Enum Cases**: Every FilamentType and SpoolSize

### ✅ Performance Tests
- **Encoding Performance**: 1000 iterations
- **Decoding Performance**: 1000 iterations

## Test Statistics

- **Total Tests**: 40+ test methods
- **Coverage Areas**: 8 major categories
- **Edge Cases**: 10+ boundary condition tests
- **Performance Tests**: 2 benchmarking tests

## Running Tests from Command Line

```bash
# Run all tests
xcodebuild test -scheme ACE_RFID_iOS -destination 'platform=iOS Simulator,name=iPhone 15'

# Run with coverage
xcodebuild test -scheme ACE_RFID_iOS -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES

# Run specific test class
xcodebuild test -scheme ACE_RFID_iOS -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ACE_RFID_iOSTests/ACE_RFID_iOSTests
```

## What's NOT Tested (By Design)

- ❌ **NFC Operations**: Requires physical tags, session management is complex
- ❌ **UI Components**: Better tested manually or with UI tests
- ❌ **CoreNFC Interactions**: Would require mocking the entire NFC framework
- ❌ **User Preferences**: UserDefaults persistence (could be added if needed)

## Notes

- All tests are deterministic and don't require external dependencies
- Tests run in isolation with no shared state
- Performance tests establish baseline metrics
- Edge case tests ensure robustness against malformed data
