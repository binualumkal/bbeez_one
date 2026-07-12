import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Callback to build the record page without importing it here
  static Widget Function(dynamic record)? recordPageBuilder;
}
