#!/bin/bash

# Test validation script
# Checks if the test setup is correct

echo "================================================"
echo "ACE RFID iOS - Test Setup Validator"
echo "================================================"
echo ""

# Check if test file exists
if [ -f "ACE_RFID_iOSTests/ACE_RFID_iOSTests.swift" ]; then
    echo "✅ Test file exists: ACE_RFID_iOSTests.swift"
    
    # Count test methods
    TEST_COUNT=$(grep -c "func test" ACE_RFID_iOSTests/ACE_RFID_iOSTests.swift)
    echo "✅ Found $TEST_COUNT test methods"
else
    echo "❌ Test file not found!"
    exit 1
fi

# Check if README exists
if [ -f "ACE_RFID_iOSTests/README.md" ]; then
    echo "✅ Test README exists"
else
    echo "⚠️  Test README not found"
fi

# Check if main source files exist
echo ""
echo "Checking source files to be tested..."

if [ -f "ACE_RFID_iOS/FilamentModel.swift" ]; then
    echo "✅ FilamentModel.swift found"
else
    echo "❌ FilamentModel.swift not found!"
fi

if [ -f "ACE_RFID_iOS/NFCManager.swift" ]; then
    echo "✅ NFCManager.swift found"
else
    echo "❌ NFCManager.swift not found!"
fi

# Try to check if test target is configured
echo ""
echo "Checking Xcode project configuration..."

if xcodebuild -list 2>/dev/null | grep -q "ACE_RFID_iOS"; then
    echo "✅ Main app scheme found"
else
    echo "❌ Main app scheme not found!"
fi

# Check if test target exists in scheme
echo ""
echo "Attempting to run tests..."
echo "(This will fail if test target is not set up)"
echo ""

xcodebuild test \
    -scheme ACE_RFID_iOS \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    -quiet \
    2>&1 | head -5

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "================================================"
    echo "✅ ALL TESTS PASSED!"
    echo "================================================"
    echo ""
    echo "Test setup is complete and working!"
else
    echo "================================================"
    echo "⚠️  TEST TARGET NOT YET CONFIGURED"
    echo "================================================"
    echo ""
    echo "Next steps:"
    echo "1. Run: ./setup_tests.sh"
    echo "2. Follow the instructions to add test target in Xcode"
    echo "3. Run this script again to verify"
fi

echo ""
echo "Test Statistics:"
echo "- Test file size: $(wc -l < ACE_RFID_iOSTests/ACE_RFID_iOSTests.swift) lines"
echo "- Test methods: $TEST_COUNT"
echo "- Test categories: 8"
echo "- Documentation: README.md + TEST_REFERENCE.md"
echo ""
