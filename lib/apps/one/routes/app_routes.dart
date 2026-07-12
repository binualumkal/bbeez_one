import 'package:flutter/material.dart';

import 'package:bbeez_one/apps/one/screens/locked_screen.dart';
import 'package:bbeez_one/apps/one/screens/login_screen.dart';
import 'package:bbeez_one/apps/one/screens/main_screen.dart';

Map<String, WidgetBuilder> buildOneRoutes() {
  return {
    '/main': (_) => const MainScreen(),
    '/login': (_) => const LoginScreen(),
    '/locked': (_) => const LockedScreen(),
  };
}
