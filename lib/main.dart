import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bbeez_one/apps/one/app.dart';
import 'package:bbeez_one/platform/core/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  configureOneNavigationBuilders();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BBeezOneApp());
}
