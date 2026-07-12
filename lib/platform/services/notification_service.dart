import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:bbeez_one/platform/core/service_locator.dart';
import 'package:bbeez_one/platform/repositories/record_repository.dart';
import 'navigation_service.dart';
import 'version_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationClick(details.payload);
      },
    );

    // Check if the app was launched by a notification
    final details = await notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      _handleNotificationClick(details.notificationResponse?.payload);
    }

    // Request permissions for Android 13+
    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void _handleNotificationClick(String? payload) async {
    if (payload == null) return;

    if (payload == 'update') {
      VersionService.openStore();
      return;
    }

    if (payload.startsWith('record:')) {
      final idStr = payload.split(':').last;
      final id = int.tryParse(idStr);
      if (id != null) {
        final record = await locate<RecordRepository>().getById(id);
        if (record != null && NavigationService.recordPageBuilder != null) {
          NavigationService.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => NavigationService.recordPageBuilder!(record),
            ),
          );
        }
      }
    }
  }

  static Future<void> showBackupReminder() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'backup_channel',
        'Backup Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await notifications.show(
      id: 1,
      title: 'Backup Reminder',
      body: 'Please backup your records.',
      notificationDetails: details,
    );
  }

  static Future<void> showUpdateNotification(String newVersion) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'update_channel',
        'App Updates',
        channelDescription: 'Notifications for new app versions',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await notifications.show(
      id: 2,
      title: 'New Update Available',
      body: 'Version $newVersion is now available in the store. Tap to update!',
      notificationDetails: details,
      payload: 'update',
    );
  }

  static Future<void> scheduleRecordExpiry(
      int id, String recordName, DateTime expiryDate) async {
    var scheduledDate = expiryDate.subtract(const Duration(days: 15));

    if (scheduledDate.isBefore(DateTime.now())) {
      // If 15 days prior is already in the past, but it hasn't expired yet,
      // notify 1 minute from now.
      if (expiryDate.isAfter(DateTime.now())) {
        scheduledDate = DateTime.now().add(const Duration(minutes: 1));
      } else {
        // Already expired, no need to schedule a future notification
        return;
      }
    }

    await notifications.zonedSchedule(
      id: id,
      title: 'Record Expiring Soon',
      body: 'Your record "$recordName" will expire in 15 days.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      payload: 'record:$id',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel',
          'Record Expiry',
          importance: Importance.max,
          priority: Priority.high,
          // Auto-dismiss after 15 days (at the actual expiry date)
          timeoutAfter: const Duration(days: 15).inMilliseconds,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await notifications.cancel(id: id);
  }
}
