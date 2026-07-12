import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bbeez_one/platform/services/notification_service.dart';

class VersionService {
  static Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return ''; // Fallback
    }
  }

  static Future<void> checkForUpdates() async {
    try {
      final newVersion = NewVersionPlus();

      // Forcing check even in debug for testing (though normally it's for production)
      final status = await newVersion.getVersionStatus();

      debugPrint(
          'Update Check: Local: ${status?.localVersion}, Store: ${status?.storeVersion}, CanUpdate: ${status?.canUpdate}');

      if (status != null && status.canUpdate) {
        await NotificationService.showUpdateNotification(status.storeVersion);
      }
    } catch (e) {
      debugPrint('Store update check failed: $e');
    }
  }

  static Future<void> openStore() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;

    final url = Platform.isAndroid
        ? Uri.parse(
            'https://play.google.com/store/apps/details?id=$packageName')
        : Uri.parse('https://apps.apple.com/app/id6778449815'); // Apple App ID

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
