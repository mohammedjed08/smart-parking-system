// ============================================================
// Integration Tests
// Tests the full app flow on a real device or emulator
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:parking_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app flow', () {
    // ========== TEST 1: App starts and shows main screen ==========
    testWidgets('app launches and shows main screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('jeddah city'), findsOneWidget);
    });

    // ========== TEST 2: Gym Schedule button navigates ==========
    testWidgets('tapping Gym Schedule opens timing screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find and tap the button
      final gymButton = find.text('Gym Schedule');
      expect(gymButton, findsOneWidget);
      await tester.tap(gymButton);
      await tester.pumpAndSettle();

      // Verify we navigated to gym screen
      expect(find.text('Gym Timing'), findsOneWidget);
      expect(find.text('Open now'), findsOneWidget);
    });

    // ========== TEST 3: Back button returns to main ==========
    testWidgets('back button returns to parking screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open gym screen
      await tester.tap(find.text('Gym Schedule'));
      await tester.pumpAndSettle();

      // Press back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Welcome back'), findsOneWidget);
    });

    // ========== TEST 4: Legend is visible ==========
    testWidgets('shows Available and Occupied legend',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Occupied'), findsOneWidget);
    });
  });
}
