import 'package:flutter/material.dart';

import 'package:bbeez_one/apps/one/screens/add_record_page.dart';
import 'package:bbeez_one/apps/one/routes/app_routes.dart';
import 'package:bbeez_one/apps/one/screens/splash_screen.dart';
import 'package:bbeez_one/platform/security/security_service.dart';
import 'package:bbeez_one/platform/services/app_lock_service.dart';
import 'package:bbeez_one/platform/services/navigation_service.dart';
import 'package:bbeez_one/platform/themes/app_theme.dart';
import 'package:bbeez_one/platform/widgets/privacy_overlay.dart';

class BBeezOneApp extends StatefulWidget {
  const BBeezOneApp({super.key});

  @override
  State<BBeezOneApp> createState() => _BBeezOneAppState();
}

class _BBeezOneAppState extends State<BBeezOneApp>
    with WidgetsBindingObserver {
  bool _showPrivacyOverlay = false;
  bool _hasResumedAtLeastOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _hasResumedAtLeastOnce = true;
      setState(() {
        _showPrivacyOverlay = false;
      });
      return;
    }

    if (!_hasResumedAtLeastOnce) return;

    if (!SecurityService.privacyEnabled.value) {
      if (_showPrivacyOverlay) {
        setState(() {
          _showPrivacyOverlay = false;
        });
      }
      return;
    }

    setState(() {
      _showPrivacyOverlay = (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'BBeez One',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: SecurityService.privacyEnabled,
          builder: (context, enabled, _) {
            return Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (_) {
                    AppLockService.instance.resetTimer();
                    return false;
                  },
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: (_) => AppLockService.instance.resetTimer(),
                    onPointerMove: (_) => AppLockService.instance.resetTimer(),
                    child: child!,
                  ),
                ),
                if (enabled && _showPrivacyOverlay) const PrivacyOverlay(),
              ],
            );
          },
        );
      },
      home: const SplashScreen(),
      routes: buildOneRoutes(),
    );
  }
}

void configureOneNavigationBuilders() {
  NavigationService.recordPageBuilder = (record) => AddRecordPage(
        domainName: record.domainName,
        institutionName: record.institutionName,
        recordTypeName: record.recordTypeName,
        existingRecord: record,
      );
}
