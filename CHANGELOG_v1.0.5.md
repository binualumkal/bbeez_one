# BBeez One v1.0.5 (Build 9) - iOS Backup Compatibility & Dynamic Versioning

## Major Changes

### 🍎 iOS Backup & Restore Improvements
- **File Type Recognition**: Added Uniform Type Identifiers (UTI) for `.bbz` files in `Info.plist`. This allows iOS to recognize BBeez backup files correctly.
- **File Picker Fix**: Optimized `BackupService` to use `FileType.any` on iOS, ensuring backup files are selectable and not greyed out.
- **File Sharing Enabled**: Enabled `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace`. Users can now manage their backup files directly through the iOS "Files" app (On My iPhone > BBeez One).

### 🔄 Dynamic App Versioning
- **Centralized Versioning**: Created `VersionService.getAppVersion()` to dynamically fetch the version from `pubspec.yaml`.
- **UI Synchronization**: Updated About, Support, and FAQ pages to automatically display the current app version. No more manual version updates required in UI code.

### 📋 Code Updates

#### Services (lib/services/)
- **backup_service.dart**: Modified `restoreDatabase` to handle platform-specific file picking logic.
- **version_service.dart**: Added `getAppVersion()` helper using `package_info_plus`.

#### Pages (lib/pages/)
- **about_page.dart**: Updated to use dynamic versioning.
- **support_page.dart**: Updated to use dynamic versioning.
- **faq_page.dart**: Updated to use dynamic versioning.

#### iOS Configuration (ios/Runner/)
- **Info.plist**: 
  - Added `CFBundleDocumentTypes` for `.bbz` files.
  - Added `UTExportedTypeDeclarations` for `com.bbeez.bbz`.
  - Set `UIFileSharingEnabled` to `true`.
  - Set `LSSupportsOpeningDocumentsInPlace` to `true`.

### ✅ Testing & Verification
- [x] `.bbz` files are now visible in iOS File Picker.
- [x] App version 1.0.5+9 correctly displays in Settings > About.
- [x] iOS Files app correctly shows the BBeez One folder.
- [x] Restore functionality verified with newly recognized file types.

### 🚀 Deployment Instructions
1. **Build for iOS/Android**:
   - `flutter build ipa`
   - `flutter build appbundle`
2. **Release Notes**:
   ```
   Version 1.0.5:
   - Fixed issue where backup files were not detectable on iPhone
   - Enabled iOS File Sharing (access backups via Files app)
   - Improved version display consistency across the app
   - General performance improvements
   ```

---

**Build Details:**
- Build Number: 9
- App Version: 1.0.5
- Status: 🟢 READY FOR RELEASE
