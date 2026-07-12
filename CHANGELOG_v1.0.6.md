# BBeez One v1.0.6 (Build 10) - Smart Web Links & Quick Actions

## Major Changes

### 🔗 Smart Web Link Detection
- **Dynamic "Open" Button**: Added a dedicated `Icons.open_in_new` button that automatically appears in the record list and add/edit pages when a web link is detected in any field.
- **Robust Detection**: Improved URL recognition logic to support both standard (http/https) and short-form web addresses.
- **Auto-Formatting**: Ensures links are opened safely using secure protocols (`https://`) even if the user didn't type them.

### 📋 Enhanced Record Management
- **Quick Copy in Edit Mode**: Added a "Copy" icon directly next to field values in the `Add/Edit Record` page. This allows users to copy data without having to exit the edit screen.
- **Improved UI Layout**: Moved action buttons (Copy & Open Link) to a dedicated row on the right side of input fields for better visibility and easier access.
- **Real-time Feedback**: Action icons now update instantly as the user types, providing immediate visual confirmation of detected links.

### 🛠 Technical Updates & Fixes
- **Android Intent Queries**: Added `<queries>` to `AndroidManifest.xml` to fix issues with external link launching on Android 11+.
- **iOS Scheme Queries**: Updated `Info.plist` with `LSApplicationQueriesSchemes` for reliable browser launching on iOS.
- **Platform Parity**: Synchronized URL detection and launching logic between the main Record List and the Add/Edit screens.

### ✅ Testing & Verification
- [x] Web links correctly show the "Open" icon in the main record view.
- [x] "Open" icon appears/disappears dynamically while typing in the Add/Edit screen.
- [x] Copy functionality verified on both the record list and edit pages.
- [x] External browser successfully opens for various link formats on both iOS and Android.

### 🚀 Deployment Instructions
1. **Build for iOS/Android**:
   - `flutter build ipa`
   - `flutter build appbundle`
2. **Release Notes**:
   ```
   Version 1.0.6:
   - One-tap access to web links (new "Open Link" icon)
   - Quick "Copy" button added to the Edit screen
   - Improved link detection for faster navigation
   - Backend fixes for reliable browser launching
   ```

---

**Build Details:**
- Build Number: 10
- App Version: 1.0.6
- Status: 🟢 READY FOR RELEASE
