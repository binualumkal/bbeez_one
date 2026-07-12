// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bbeez_one/apps/one/app.dart';
import 'package:bbeez_one/platform/core/service_locator.dart';

void main() {
  testWidgets('App bootstraps smoke test', (WidgetTester tester) async {
    setupServiceLocator();
    await tester.pumpWidget(const BBeezOneApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
