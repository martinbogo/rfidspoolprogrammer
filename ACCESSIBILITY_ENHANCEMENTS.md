# Accessibility Enhancement Plan for Spool Programmer

## Current Status
- ❌ No VoiceOver labels
- ❌ No accessibility hints
- ❌ No haptic feedback
- ❌ Limited Dynamic Type support
- ❌ No semantic grouping

## Enhancement Plan

### 1. VoiceOver Labels & Hints

#### TagStatusCard
```swift
.accessibilityElement(children: .combine)
.accessibilityLabel(nfcManager.tagUID.isEmpty ? 
    "NFC Status: No tag detected" : 
    "NFC Status: Tag connected, \(nfcManager.tagType), UID \(nfcManager.tagUID)")
.accessibilityHint("Hold an NTAG213, NTAG215, or NTAG216 tag near your iPhone to read it")
```

#### FilamentSelectionCard - Menu
```swift
.accessibilityLabel("Filament profile: \(selectedProfile?.displayName ?? "None selected")")
.accessibilityHint("Double tap to choose a filament type")
```

#### SpoolConfigCard - Color Picker
```swift
.accessibilityLabel("Selected color: \(colorDescription(selectedColor))")
.accessibilityHint("Double tap to open color picker")
```

#### SpoolConfigCard - Spool Size
```swift
.accessibilityLabel("Spool size: \(selectedSpoolSize.displayName)")
.accessibilityHint("Double tap to change spool size")
```

#### Action Buttons
```swift
// Write Button
.accessibilityLabel("Write to tag")
.accessibilityHint("Writes filament data to the NFC tag")

// Read Button
.accessibilityLabel("Read from tag")
.accessibilityHint("Reads filament data from the NFC tag")

// Status Button
.accessibilityLabel("Check tag status")
.accessibilityHint("Shows tag memory layout and lock status")

// Format Button
.accessibilityLabel("Format tag")
.accessibilityHint("Erases all data from the NFC tag")
```

### 2. ColorPickerView Enhancements

#### Preset Color Buttons
```swift
.accessibilityLabel("\(colorName) color preset")
.accessibilityHint("Double tap to select this color")
.accessibilityAddTraits(isSelected ? .isSelected : [])
```

#### RGB Sliders
```swift
// Red Slider
.accessibilityLabel("Red: \(Int(red * 255))")
.accessibilityValue("\(Int(red * 255)) out of 255")

// Green Slider
.accessibilityLabel("Green: \(Int(green * 255))")
.accessibilityValue("\(Int(green * 255)) out of 255")

// Blue Slider
.accessibilityLabel("Blue: \(Int(blue * 255))")
.accessibilityValue("\(Int(blue * 255)) out of 255")
```

#### Color Preview
```swift
.accessibilityLabel("Color preview")
.accessibilityValue("RGB: \(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255))")
```

### 3. Haptic Feedback

Add to NFCManager.swift:

```swift
import CoreHaptics

class NFCManager: NSObject, ObservableObject {
    // Add haptic engine
    private var hapticEngine: CHHapticEngine?
    
    override init() {
        super.init()
        prepareHaptics()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            debugLog("Failed to start haptic engine: \(error)")
        }
    }
    
    func playSuccessHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            debugLog("Failed to play haptic: \(error)")
        }
    }
    
    func playErrorHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        let events = [
            CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
        ]
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            debugLog("Failed to play haptic: \(error)")
        }
    }
    
    func playDetectionHaptic() {
        // Simple notification feedback for tag detection
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
```

Then call haptics in key places:
- `performWrite()` - success → playSuccessHaptic(), error → playErrorHaptic()
- `performRead()` - success → playSuccessHaptic(), error → playErrorHaptic()
- `performFormat()` - success → playSuccessHaptic(), error → playErrorHaptic()
- Tag detected → playDetectionHaptic()

### 4. Dynamic Type Support

All Text views should use:
```swift
Text("Something")
    .font(.body) // or .headline, .subheadline, etc.
    // This automatically respects Dynamic Type
```

For custom fonts, use:
```swift
Text("Something")
    .font(.system(.body, design: .rounded))
    .minimumScaleFactor(0.8) // Allow some shrinking if needed
```

### 5. Semantic Grouping

Group related elements:
```swift
VStack {
    // Related content
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Combined label for group")
```

### 6. Reduce Motion Support

For animations, respect reduce motion:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Then use:
.animation(reduceMotion ? .none : .spring(), value: someValue)
```

## Implementation Priority

1. **High Priority** (Do first):
   - Action buttons (Write, Read, Status, Format)
   - Haptic feedback for NFC operations
   - Filament profile selection

2. **Medium Priority**:
   - Color picker accessibility
   - Spool size selection
   - Tag status card

3. **Nice to Have**:
   - Reduce motion support
   - Advanced semantic grouping

## Testing

Test with:
1. **VoiceOver enabled**: Settings → Accessibility → VoiceOver
2. **Dynamic Type**: Settings → Accessibility → Display & Text Size → Larger Text
3. **Reduce Motion**: Settings → Accessibility → Motion → Reduce Motion
4. **Haptic feedback**: Use physical device (simulator doesn't support haptics)

## Expected Outcome

- ✅ All interactive elements have clear labels
- ✅ VoiceOver users can navigate entire app
- ✅ Haptic feedback confirms NFC operations
- ✅ Text scales properly with Dynamic Type
- ✅ Reduced motion respected for animations
- ✅ App Store "Supports Accessibility" badge
