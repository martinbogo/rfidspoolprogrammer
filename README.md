# ACE RFID iOS

An iOS application for programming RFID tags (NTAG213/215/216) for Anycubic 3D printer filament spools.

## Features

- ✅ **Read/Write RFID Tags**: Read and write filament data to NFC RFID tags
- ✅ **Filament Database**: Pre-loaded with common filament profiles and support for custom materials
- ✅ **Color Picker**: Advanced color picker with gradient selector, RGB sliders, and preset colors
- ✅ **Temperature Settings**: Configure extruder and bed temperatures for each material
- ✅ **Multiple Spool Sizes**: Support for 0.25 KG to 5 KG spools
- ✅ **Auto-Read Mode**: Automatically read tags when detected

## Requirements

- iOS 16.0 or later
- iPhone with NFC capability (iPhone 7 or later)
- NTAG213, NTAG215, or NTAG216 compatible RFID tags

## Based On

This iOS app is based on the [ACE-RFID](https://github.com/DnG-Crafts/ACE-RFID) project by DnG-Crafts, which provides Android and Windows applications for the same purpose.

## Installation

### Using Xcode

1. Open `ACE_RFID_iOS.xcodeproj` in Xcode (technical project name)
   - The app displays as **"Spool Programmer"** to users
2. Connect your iPhone
3. Select your development team in the project settings
4. Build and run on your device (NFC does not work in the simulator)

### Important Setup Steps

1. **Enable NFC Capability**:
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Click "+ Capability" and add "Near Field Communication Tag Reading"

2. **Update Bundle Identifier**:
   - Change the bundle identifier from `com.yourcompany.ACE-RFID-iOS` to your own

3. **Configure Code Signing**:
   - Select your development team in the project settings

## Usage

### Reading a Tag

1. Tap "Read Tag"
2. Hold your iPhone near the RFID tag
3. The app will display the tag's UID and stored information
4. Filament profile, color, and spool size will be automatically loaded

### Writing a Tag

1. Select a filament profile from the "Material" dropdown
2. Choose a color using the color picker
3. Select the spool size
4. Tap "Write Tag"
5. Hold your iPhone near the RFID tag
6. Wait for the success message

### Adding Custom Filaments

1. Tap "Add Custom Filament"
2. Enter the brand, type, SKU, and temperature settings
3. Tap "Add"
4. Your custom filament will appear in the material list

### Formatting a Tag

If a tag fails to write, you can format it:
1. Tap "Format Tag"
2. Hold your iPhone near the RFID tag
3. The tag will be formatted for ACE compatibility

## Tag Format

The app uses the same tag format as the original ACE-RFID project:

- **Pages 4**: Magic bytes (0x7B, 0x00, 0x65, 0x00)
- **Pages 5-9**: SKU (20 bytes)
- **Pages 10-14**: Brand (20 bytes)
- **Pages 15-19**: Material Type (20 bytes)
- **Page 20**: Color (ABGR format, 4 bytes)
- **Page 24**: Extruder temperature (min/max, 4 bytes)
- **Page 29**: Bed temperature (min/max, 4 bytes)
- **Page 30**: Filament parameters (diameter/length, 4 bytes)
- **Page 31**: Unknown constant

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **Core NFC**: Native iOS NFC tag reading/writing
- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive data management

### Key Files

- `ContentView.swift`: Main UI and coordination
- `NFCManager.swift`: NFC tag reading/writing logic
- `FilamentModel.swift`: Data models and database management
- `ColorPickerView.swift`: Advanced color picker interface

### NFC Tag Commands

The app uses standard MIFARE commands:
- **READ (0x30)**: Read 4 pages (16 bytes) at once
- **WRITE (0xA2)**: Write 1 page (4 bytes) at a time

## Known Limitations

- NFC only works on physical devices, not in the simulator
- Writing can be slower than Android due to iOS NFC session restrictions
- Some tags may require formatting before first use

## Troubleshooting

### "NFC is not available"
- Ensure you're running on a physical iPhone 7 or later
- NFC does not work in the simulator

### "Failed to write tag"
- Try formatting the tag first
- Ensure the tag is NTAG213, 215, or 216 compatible
- Hold the iPhone steady near the tag

### "Session error"
- Make sure NFC is enabled in Settings
- Try restarting the app
- Check that the tag is within range

## Contributing

Feel free to submit issues and pull requests to improve the app!

## Support This Project

<div align="center">

### ☕ Enjoying this app?

If you find **Spool Programmer** useful and want to support its development, consider buying me a coffee!

[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support%20Development-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/martinbogo)

**[☕ Buy me a coffee on Ko-fi](https://ko-fi.com/martinbogo?amount=1)**

Your support helps maintain and improve this free, open-source app! ❤️

</div>

---

## License

**MIT License** - See [LICENSE](LICENSE) file for details.

This iOS implementation is licensed under the MIT License, allowing free use,
modification, and distribution with attribution.

### Attribution

This project uses the RFID tag format and protocol documentation from the 
[ACE-RFID project](https://github.com/DnG-Crafts/ACE-RFID) by DnG-Crafts.

- **Tag Format**: Based on ACE-RFID documentation
- **Protocol**: N033 Material box communication protocol
- **iOS Implementation**: Original code written in Swift/SwiftUI (MIT Licensed)

This is an independent iOS port that provides equivalent functionality to the
original Android, Windows, and Arduino implementations.

## Credits

- **Original ACE-RFID Project**: [DnG-Crafts/ACE-RFID](https://github.com/DnG-Crafts/ACE-RFID)
- **Tag Format & Protocol**: DnG-Crafts
- **iOS Implementation**: Martin, October 2025
- **License**: MIT (for iOS implementation)

## Support

For issues related to the tag format or Anycubic printer compatibility, please refer to the original ACE-RFID project documentation.
