import 'package:flutter/material.dart';

import 'services/app_lock_service.dart';
import 'services/security_service.dart';

import 'pages/login_screen.dart';
import 'pages/splash_screen.dart';
import 'pages/main_screen.dart';
import 'pages/locked_screen.dart';
import 'pages/add_record_page.dart';
import 'widgets/privacy_overlay.dart';

import 'theme/app_theme.dart';

import 'package:flutter/services.dart';
import 'services/navigation_service.dart';

void main() {
  // Start app immediately to show Splash Screen as fast as possible
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup navigation builders to avoid circular dependencies
  NavigationService.recordPageBuilder = (record) => AddRecordPage(
    domainName: record.domainName,
    institutionName: record.institutionName,
    recordTypeName: record.recordTypeName,
    existingRecord: record,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BBeezOneApp());
}

class BBeezOneApp extends StatefulWidget {
  const BBeezOneApp({super.key});

  @override
  State<BBeezOneApp> createState() => _BBeezOneAppState();
}

class _BBeezOneAppState extends State<BBeezOneApp> with WidgetsBindingObserver {
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
      _showPrivacyOverlay = (state == AppLifecycleState.inactive || state == AppLifecycleState.paused);
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
          }
        );
      },
      // home is SplashScreen which will handle all initializations
      home: const SplashScreen(),
      routes: {
        '/main': (_) => const MainScreen(),
        '/login': (_) => const LoginScreen(),
        '/locked': (_) => const LockedScreen(),
      },
    );
  }
}
