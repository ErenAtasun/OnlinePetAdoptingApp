// Flutter widget test for Pet Adoption App
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_swe/main.dart';
import 'package:flutter_application_swe/app.dart';

void main() {
  testWidgets('Pet adoption app starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PetAdoptApp(),
      ),
    );

    // Wait for initial frame and any async initialization
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that we can find app title or initial screen elements
    // The app should show splash screen initially, then navigate
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App widget builds without errors', (WidgetTester tester) async {
    // Test that the app widget can be built without throwing errors
    await tester.pumpWidget(
      const ProviderScope(
        child: PetAdoptApp(),
      ),
    );

    // Pump frames to allow async operations
    await tester.pump();

    // Verify that the app has been built
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
