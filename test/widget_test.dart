// ============================================================
// Widget Tests
// Tests the UI components without running the full app
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/main.dart';

void main() {
  group('GymTimingScreen UI', () {
    // ========== TEST 1: Title is displayed ==========
    testWidgets('shows "Gym Timing" title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GymTimingScreen()),
      );

      expect(find.text('Gym Timing'), findsOneWidget);
    });

    // ========== TEST 2: "Open now" text appears ==========
    testWidgets('shows "Open now" label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GymTimingScreen()),
      );

      expect(find.text('Open now'), findsOneWidget);
    });

    // ========== TEST 3: All 7 days are listed ==========
    testWidgets('displays all 7 days of the week', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GymTimingScreen()),
      );

      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('Thursday'), findsOneWidget);
      expect(find.text('Friday'), findsOneWidget);
      expect(find.text('Saturday'), findsOneWidget);
    });

    // ========== TEST 4: Friday has special hours ==========
    testWidgets('shows special hours for Friday', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GymTimingScreen()),
      );

      expect(find.text('12-4 AM, 1 PM-12 AM'), findsOneWidget);
    });

    // ========== TEST 5: Other days are "Open 24 hours" ==========
    testWidgets('shows "Open 24 hours" multiple times',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GymTimingScreen()),
      );

      // 6 days are open 24h (all except Friday)
      expect(find.text('Open 24 hours'), findsNWidgets(6));
    });

    // ========== TEST 6: Has back button ==========
    testWidgets('has a back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GymTimingScreen()),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('CarPainter', () {
    // ========== TEST 7: shouldRepaint logic ==========
    test('repaints when isOccupied changes', () {
      final painter1 = CarPainter(isOccupied: true, faceRight: true);
      final painter2 = CarPainter(isOccupied: false, faceRight: true);
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('repaints when faceRight changes', () {
      final painter1 = CarPainter(isOccupied: true, faceRight: true);
      final painter2 = CarPainter(isOccupied: true, faceRight: false);
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('does NOT repaint when nothing changes', () {
      final painter1 = CarPainter(isOccupied: true, faceRight: true);
      final painter2 = CarPainter(isOccupied: true, faceRight: true);
      expect(painter1.shouldRepaint(painter2), isFalse);
    });
  });
}
