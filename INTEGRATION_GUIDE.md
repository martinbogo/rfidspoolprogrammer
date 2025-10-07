# Integration Guide for New Features

## Step 1: Add Files to Xcode Project

1. Open `ACE_RFID_iOS.xcodeproj` in Xcode
2. Right-click on `ACE_RFID_iOS` folder in Project Navigator
3. Select "Add Files to ACE_RFID_iOS..."
4. Select these 4 files:
   - `SettingsModel.swift`
   - `SettingsView.swift`
   - `TagDetailsModel.swift`
   - `TagDetailsView.swift`
5. Make sure "Copy items if needed" is checked
6. Click "Add"

## Step 2: Update ContentView.swift

Add these at the top with other @State variables:

```swift
@StateObject private var settings = AppSettings.shared
@State private var showingSettings = false
@State private var showingTagDetails = false
@State private var currentTagDetails: TagDetails?
```

Add Settings button to toolbar (after the Reset button):

```swift
ToolbarItem(placement: .navigationBarTrailing) {
    Button {
        showingSettings = true
    } label: {
        Image(systemName: "gearshape")
    }
    .accessibilityLabel("Settings")
}
```

Add sheets after the existing ones:

```swift
.sheet(isPresented: $showingSettings) {
    SettingsView(settings: settings)
}
.sheet(isPresented: $showingTagDetails) {
    if let details = currentTagDetails {
        TagDetailsView(details: details)
    }
}
```

Update resetToDefaults() to use settings:

```swift
private func resetToDefaults() {
    withAnimation(.spring(response: 0.3)) {
        selectedProfile = nil
        selectedColor = .blue
        selectedSpoolSize = settings.defaultSpoolSize  // Use setting
        nfcManager.tagUID = ""
        nfcManager.tagType = ""
        nfcManager.lastReadData = nil
        nfcManager.lastReadBytes = nil
        nfcManager.tagLockStatus = ""
        nfcManager.statusMessage = ""
    }
}
```

When tag is read successfully, show details:

```swift
.onChange(of: nfcManager.lastReadBytes) { newBytes in
    if let bytes = newBytes, let tagData = RFIDTagData.fromBytes(bytes, database: filamentDB) {
        withAnimation(.spring(response: 0.3)) {
            selectedProfile = tagData.profile
            selectedColor = tagData.color
            selectedSpoolSize = tagData.spoolSize
            nfcManager.lastReadData = tagData
        }
        
        // Create and show tag details
        if !nfcManager.tagUID.isEmpty {
            currentTagDetails = TagDetails(
                uid: nfcManager.tagUID,
                tagType: nfcManager.tagType,
                memoryUsed: bytes.count,
                memoryTotal: 504, // Adjust based on tag type
                readDate: Date(),
                hasData: true,
                dataType: tagData.profile.displayName
            )
            showingTagDetails = true
        }
    }
}
```

## Step 3: Add VoiceOver Labels

Add `.accessibilityLabel()` to all interactive elements. Examples:

```swift
// For buttons in ActionButtonsCard
Button("Write to Tag") {
    // ...
}
.accessibilityLabel("Write filament data to tag")
.accessibilityHint("Hold iPhone near NFC tag to write")

// For color picker button
Button {
    showingColorPicker = true
} label: {
    // ...
}
.accessibilityLabel("Select filament color")
.accessibilityValue("Currently \(colorDescription(selectedColor))")

// For spool size picker
Picker("Size", selection: $selectedSpoolSize) {
    // ...
}
.accessibilityLabel("Spool size")
.accessibilityValue(selectedSpoolSize.displayName)
```

## Step 4: Update NFCManager.swift

Add at top of class:

```swift
@Published var tagDetails: TagDetails?
```

In `playSuccessHaptic()`, `playErrorHaptic()`, `playDetectionHaptic()`:

```swift
func playSuccessHaptic() {
    guard AppSettings.shared.hapticFeedbackEnabled else { return }
    // ... existing code
}
```

In `performWrite`, check auto-verify setting:

```swift
if success {
    DispatchQueue.main.async {
        self.statusMessage = "✅ Write complete"
        if AppSettings.shared.autoVerifyEnabled {
            self.statusMessage += " - Starting verification..."
        }
        self.playSuccessHaptic()
    }
    
    if AppSettings.shared.autoVerifyEnabled {
        // ... existing verify code
    } else {
        session.alertMessage = "✅ Write complete!"
        session.invalidate()
    }
}
```

## Step 5: Temperature Warnings

Create a helper function in FilamentModel.swift or ContentView:

```swift
func temperatureWarning(for profile: FilamentProfile) -> String? {
    let extruderMid = (profile.temperatures.extruderMin + profile.temperatures.extruderMax) / 2
    let bedMid = (profile.temperatures.bedMin + profile.temperatures.bedMax) / 2
    
    switch profile.type {
    case .pla, .plaPlus:
        if extruderMid > 230 {
            return "⚠️ High temperature for PLA"
        }
    case .abs:
        if extruderMid < 220 || extruderMid > 260 {
            return "⚠️ Unusual temperature for ABS"
        }
    case .petg:
        if extruderMid < 220 || extruderMid > 260 {
            return "⚠️ Unusual temperature for PETG"
        }
    default:
        break
    }
    return nil
}
```

Display warning in SpoolConfigCard:

```swift
if let profile = selectedProfile, let warning = temperatureWarning(for: profile) {
    Label(warning, systemImage: "exclamationmark.triangle.fill")
        .font(.caption)
        .foregroundColor(.orange)
        .padding(.top, 4)
}
```

## Step 6: Build and Test

1. Build the project (Cmd+B)
2. Fix any compilation errors
3. Run on device or simulator
4. Test:
   - Settings screen opens and saves preferences
   - Tag details appear after reading
   - Temperature warnings show for unusual temps
   - VoiceOver reads all labels correctly
   - Haptic feedback respects settings

## Step 7: Widget (Future - Separate Implementation)

Widgets require:
- New Widget Extension target in Xcode
- App Groups for shared data
- WidgetKit implementation
- Timeline provider
- Deep linking

This is a separate, larger task that should be done in a future update.

## Common Issues

**Files not building:**
- Make sure they're added to target membership
- Check File Inspector → Target Membership → ACE_RFID_iOS

**Settings not persisting:**
- Check UserDefaults keys are unique
- Test on device (simulator can have issues)

**VoiceOver not working:**
- Enable VoiceOver: Settings → Accessibility → VoiceOver
- Test with triple-click home/side button shortcut

**Haptics not working:**
- Must test on physical device
- Simulator doesn't support haptics
