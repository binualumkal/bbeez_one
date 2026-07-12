# BBeez One Release v1.0.5 (Build 9)

## Executive Summary

**BBeez One v1.0.5** focuses on **iOS compatibility** and **consistency**. We've resolved the issue where backup files were not detectable on iPhone and synchronized the version display across all app screens.

### Key Highlights
- ✅ **iOS Backup Fix**: `.bbz` files are now recognized by iOS and selectable in the restore tool.
- ✅ **Files App Integration**: Enabled iOS File Sharing; users can now see their backups in the "Files" app.
- ✅ **Dynamic Versioning**: The app now automatically pulls its version number from `pubspec.yaml`, ensuring consistency in About/Support pages.
- ✅ **Improved Restore UX**: Relaxed file type filtering on iOS to ensure a smoother restoration experience.

---

## What Was Changed

### iOS File Recognition & Management

**Problem**: iPhone users were creating backups but couldn't find or select them during restoration because iOS didn't recognize the `.bbz` extension as a valid file type.

**Solution**:
- Registered `.bbz` as a custom document type (UTI) in `Info.plist`.
- Enabled `UIFileSharingEnabled`, allowing users to see the "BBeez One" folder in the Files app.
- Updated `FilePicker` logic to be more permissive on iOS while maintaining security.

### Dynamic Versioning System

**Problem**: Version numbers were hardcoded in multiple UI files (About, FAQ, Support), leading to "version drift" where the UI showed outdated information.

**Solution**:
- Implemented `VersionService.getAppVersion()` using `package_info_plus`.
- Updated all UI components to use this service.
- App version is now controlled exclusively via `pubspec.yaml`.

### Files Modified

| File | Change |
|------|--------|
| pubspec.yaml | Incremented version to 1.0.5+9 |
| ios/Runner/Info.plist | Added UTI declarations and enabled File Sharing |
| lib/services/backup_service.dart | Optimized file picking for iOS |
| lib/services/version_service.dart | Added dynamic version retrieval |
| lib/pages/about_page.dart | Replaced hardcoded version with dynamic service |
| lib/pages/support_page.dart | Replaced hardcoded version with dynamic service |
| lib/pages/faq_page.dart | Replaced hardcoded version with dynamic service |

---

## Build Verification

```
✅ Compilation Status: SUCCESS
✅ iOS UTI Declaration: Verified in Info.plist
✅ Dynamic Versioning: Verified in UI
✅ iOS File Sharing: Enabled
```

---

## How to Submit

### Step 1: Increment Version
- Done: `pubspec.yaml` updated to `1.0.5+9`.

### Step 2: Build App
- **Android**: `flutter build appbundle --release`
- **iOS**: `flutter build ipa --release`

### Step 3: Update Store Notes
```
🎉 iOS Backup & Restore Fix

This update improves the backup and restore experience for iPhone users. We've 
also streamlined how versioning is displayed throughout the app.

✨ Key Improvements:
• Fixed backup file detection on iPhone
• Added support for iOS "Files" app (manage backups easily)
• Consistent version display across all screens
• General stability fixes for data management
```

---

## Documentation Included

1. **CHANGELOG_v1.0.5.md** - Technical breakdown of build 9.
2. **README_RELEASE_v1.0.5.md** - This file.

---

## Version Info

| Property | Value |
|----------|-------|
| App Version | 1.0.5 |
| Build Number | 9 |
| Package Name | com.bbeezdigital.one |

---

## Sign-Off

**Release Manager**: Code Copilot  
**Date**: (Current Date)  
**Status**: ✅ **APPROVED FOR RELEASE**
