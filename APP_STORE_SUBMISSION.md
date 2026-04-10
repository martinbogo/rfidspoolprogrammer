# App Store Submission Guide - Version 1.2.0

## Current Version Info
- **Marketing Version:** 1.2.0
- **Build Number:** 3
- **Bundle ID:** com.martinbogo.spoolprogrammer
- **App Name:** Spool Programmer (Display: ACE Spool RFID Programmer)
- **Deployment Target:** iOS 18.0
- **Swift Version:** 5.0

## ✅ Pre-Submission Checklist

### 1. Code & Build Status
- ✅ All files committed to git
- ✅ No compilation errors
- ✅ BUILD SUCCEEDED
- ✅ 5 commits ready to push to origin/main

### 2. Version Numbers
- ✅ Version 1.1.0 (MINOR bump for new features)
- ✅ Build 2 (incremented from previous)

### 3. Features in This Release
- ✅ Fixed NFC scanning failures on iOS 26
- ✅ Broadened tag polling (ISO 14443 + ISO 15693)
- ✅ Added NDEF entitlement for full NFC access
- ✅ Improved session recovery (restartPolling on failure)
- ✅ Better error messages and timeout guidance
- ✅ Replaced deprecated NavigationView with NavigationStack
- ✅ Deployment target raised to iOS 18.0

## 🚀 Step-by-Step Submission Process

### Step 1: Push to GitHub
```bash
cd /Users/martin/Development/rfidspoolprogrammer
git push origin main
```

### Step 2: Archive the App in Xcode

1. **Open Xcode:**
   ```bash
   open ACE_RFID_iOS.xcodeproj
   ```

2. **Select "Any iOS Device (arm64)" as target:**
   - At the top of Xcode, click the device selector
   - Choose "Any iOS Device (arm64)" NOT a simulator

3. **Create Archive:**
   - Menu: **Product → Archive**
   - Wait for build to complete (may take 2-5 minutes)
   - Archive window will open automatically

### Step 3: Validate the Archive

In the Organizer window (after archive completes):

1. **Select your archive** (should show version 1.2.0, build 3)

2. **Click "Validate App"**
   - Choose your Apple ID/Team
   - Select "Automatically manage signing"
   - Click "Validate"
   - Wait for validation (checks for issues)
   - ✅ Should say "Validation Successful"

3. **If validation fails:**
   - Read error messages carefully
   - Common issues:
     - Missing signing certificate
     - Provisioning profile issues
     - Missing required icons
     - Info.plist issues

### Step 4: Distribute to App Store Connect

1. **Click "Distribute App"**
   
2. **Choose Distribution Method:**
   - Select: **"App Store Connect"**
   - Click "Next"

3. **Upload Options:**
   - Select: **"Upload"**
   - Click "Next"

4. **App Store Connect Distribution Options:**
   - ✅ Include bitcode for iOS content: NO (deprecated)
   - ✅ Upload your app's symbols: YES
   - ✅ Manage Version and Build Number: Automatic
   - Click "Next"

5. **Signing:**
   - Select: **"Automatically manage signing"**
   - Click "Next"

6. **Review Info:**
   - Verify everything looks correct
   - Click "Upload"

7. **Wait for Upload:**
   - Progress bar will show upload status
   - Takes 2-10 minutes depending on internet speed
   - ✅ "Upload Successful" when done

### Step 5: Wait for Processing

1. **Go to App Store Connect:**
   - Visit: https://appstoreconnect.apple.com
   - Sign in with your Apple ID

2. **Navigate to Your App:**
   - Click "My Apps"
   - Select "Spool Programmer"

3. **Check Build Status:**
   - Click "TestFlight" tab or "App Store" tab
   - Look for build 2
   - Status will show: "Processing" (10-30 minutes)
   - Email notification when processing complete

### Step 6: Create App Store Version (if needed)

**If this is a new version:**

1. **In App Store Connect → App Store tab:**
   - Click the "+" button next to "iOS App"
   - Enter version: **1.2.0**

2. **Fill Required Fields:**

   **What's New in This Version:**
   ```
   Version 1.2.0 - iOS 26 Compatibility Update

   Bug Fixes:
   • Fixed NFC tag scanning failures on iOS 26
   • Improved tag detection reliability with broader protocol support
   • Better session recovery when connection is interrupted

   Improvements:
   • Added ISO 15693 protocol support for wider tag compatibility
   • Clearer error messages when tags cannot be read
   • Helpful positioning tips when scans time out
   • Updated UI framework for modern iOS

   Requirements:
   • Now requires iOS 18.0 or later
   ```

   **Promotional Text (Optional):**
   ```
   Updated for iOS 26! Version 1.2.0 fixes NFC scanning issues and improves tag detection reliability for programming 3D printer filament spool RFID tags.
   ```

3. **Select Your Build:**
   - Under "Build" section, click the "+" button
   - Select build 3
   - Click "Done"

4. **Review Other Sections:**
   - App Information
   - Pricing and Availability
   - App Privacy (update if needed)
   - Age Rating

### Step 7: Submit for Review

1. **Add/Update Required Items:**
   - App Preview (video - optional but recommended)
   - Screenshots (required - at least 3 for 6.7" display)
   - App Icon (should already be in assets)

   **Screenshots (6.7" iPhone - 1290x2796):**

   One screenshot is pre-generated in `screenshots/01_main_screen.png`.
   To capture additional screenshots in the Simulator:

   a. Run the app on iPhone 15 Pro Max simulator
   b. Navigate to the screen you want (Settings, About, Color Picker, etc.)
   c. Press Cmd+S in the Simulator to save a screenshot
   d. Screenshots land in ~/Desktop by default

   Recommended set (3-5 screenshots):
   - Main screen (provided: `screenshots/01_main_screen.png`)
   - Filament profile selected with color picker
   - Settings screen
   - About screen
   - Tag details view (if available from a previous read)

2. **App Review Information:**
   - Contact Name
   - Contact Phone
   - Contact Email
   - **Demo Account:** If NFC testing needed, explain in notes

3. **Notes for Review:**
   ```
   This app requires a physical iPhone with NFC capability and 
   NTAG213/215/216 NFC tags to test fully. The app reads and 
   writes filament spool information to NFC tags for 3D printing.

   Version 1.2.0 fixes NFC scanning failures reported on iOS 26.
   Changes include broader NFC protocol polling and improved 
   session recovery. No new permissions or features beyond NFC.

   Key features to test:
   • Main screen UI layout and navigation
   • Settings screen - customization options  
   • About screen - app information
   • NFC operations require physical tags (expected to fail on simulator)
   ```

4. **Click "Add for Review"**

5. **Click "Submit to App Review"**

### Step 8: Wait for Review

- **Review Time:** Usually 24-48 hours
- **Status Updates:**
  - "Waiting for Review" → Your app is in queue
  - "In Review" → Apple is testing
  - "Pending Developer Release" → Approved! Ready to publish
  - "Ready for Sale" → Live on App Store

## 📱 TestFlight (Optional but Recommended)

**Before submitting to App Store, test with TestFlight:**

1. **In App Store Connect → TestFlight tab:**
   - Build 3 should appear after processing
   - Click on build 3

2. **Add Internal Testers:**
   - Click "Internal Testing"
   - Add yourself and other App Store Connect users
   - They'll get email with TestFlight link

3. **Add External Testers (Optional):**
   - Create a test group
   - Add beta testers by email
   - Requires beta app review (1-2 days)

4. **Test Thoroughly:**
   - Install via TestFlight on physical device
   - Verify NFC scanning works on iOS 26
   - Test tag read/write with NTAG213/215/216
   - Check Settings persistence
   - Verify haptic feedback toggle
   - Verify auto-verify toggle

5. **Fix Any Issues:**
   - If bugs found, fix them
   - Increment build number to 4
   - Archive and upload again
   - TestFlight testers get automatic update

## 🎯 Quick Command Reference

```bash
# Push commits to GitHub
git push origin main

# Open Xcode project
open ACE_RFID_iOS.xcodeproj

# Build for release (in Xcode)
Product → Archive

# Check version
grep -E "(MARKETING_VERSION|CURRENT_PROJECT_VERSION)" ACE_RFID_iOS.xcodeproj/project.pbxproj
```

## ⚠️ Common Issues & Solutions

### Issue: "No signing identity found"
**Solution:** 
- Xcode → Settings → Accounts
- Select your Apple ID
- Download Manual Profiles
- Ensure you have an Apple Developer Program membership ($99/year)

### Issue: "Missing required icon"
**Solution:**
- Check Assets.xcassets/AppIcon.appiconset
- Ensure all required sizes present
- Currently have: AppIcon-1024.png ✅

### Issue: "Invalid bundle"
**Solution:**
- Check Info.plist for required keys
- Verify CFBundleVersion is integer
- Ensure all required permissions present

### Issue: "Export compliance missing"
**Solution:**
- In App Store Connect, answer encryption questions
- Your app likely doesn't use encryption (answer "No")

## 📊 Version History

- **1.0.1 (build 1):** Initial release with core NFC functionality
- **1.1.0 (build 2):** Added Settings Screen and Tag Details Display

## 🔄 After Approval

1. **Release to App Store:**
   - Can release immediately or schedule
   - Choose "Manually release this version"
   - Click "Release this Version" when ready

2. **Monitor:**
   - Check App Analytics in App Store Connect
   - Monitor crash reports
   - Read user reviews

3. **Plan Next Update:**
   - Version 1.1.1 for bug fixes
   - Version 1.2.0 for VoiceOver labels + temperature warnings
   - Version 2.0.0 for major redesign (Widget support?)

## ✅ Current Status

- [x] Code complete
- [x] Version set to 1.1.0 (build 2)
- [x] All commits in git
- [ ] Pushed to GitHub (run: `git push origin main`)
- [ ] Archived in Xcode
- [ ] Uploaded to App Store Connect
- [ ] Submitted for review

**Next Command:** `git push origin main`
**Then:** Open Xcode and archive!

Good luck! 🚀
