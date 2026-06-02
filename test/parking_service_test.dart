// ============================================================
// Unit Tests for ParkingService
// Tests the data parsing and fetching logic
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:parking_app/parking_service.dart';

void main() {
  group('ParkingService.parseParkingData', () {
    late ParkingService service;

    setUp(() {
      service = ParkingService(firebaseUrl: 'https://test.example.com');
    });

    // ========== TEST 1: Empty data ==========
    test('returns empty set when data is null', () {
      final result = service.parseParkingData('null');
      expect(result, isEmpty);
    });

    // ========== TEST 2: All available ==========
    test('returns empty set when all slots are 0', () {
      final json = '{"slot1": 0, "slot2": 0, "slot3": 0}';
      final result = service.parseParkingData(json);
      expect(result, isEmpty);
    });

    // ========== TEST 3: Some occupied ==========
    test('identifies occupied slots correctly', () {
      final json = '{"slot1": 1, "slot2": 0, "slot5": 1, "slot10": 1}';
      final result = service.parseParkingData(json);
      expect(result, equals({1, 5, 10}));
    });

    // ========== TEST 4: All occupied ==========
    test('handles all slots being occupied', () {
      final json = '{"slot1": 1, "slot2": 1, "slot3": 1}';
      final result = service.parseParkingData(json);
      expect(result, equals({1, 2, 3}));
    });

    // ========== TEST 5: Boolean values ==========
    test('treats true as occupied', () {
      final json = '{"slot1": true, "slot2": false}';
      final result = service.parseParkingData(json);
      expect(result, equals({1}));
    });

    // ========== TEST 6: String values ==========
    test('treats "1" string as occupied', () {
      final json = '{"slot1": "1", "slot2": "0"}';
      final result = service.parseParkingData(json);
      expect(result, equals({1}));
    });

    // ========== TEST 7: Invalid keys ignored ==========
    test('ignores keys without numbers', () {
      final json = '{"slotX": 1, "slot5": 1, "other": 1}';
      final result = service.parseParkingData(json);
      expect(result, equals({5}));
    });

    // ========== TEST 8: All 16 slots ==========
    test('handles full parking lot data (16 slots)', () {
      final json = '''
      {
        "slot1": 0, "slot2": 1, "slot3": 0, "slot4": 1,
        "slot5": 1, "slot6": 0, "slot7": 0, "slot8": 1,
        "slot9": 0, "slot10": 1, "slot11": 0, "slot12": 1,
        "slot13": 0, "slot14": 0, "slot15": 1, "slot16": 0
      }
      ''';
      final result = service.parseParkingData(json);
      expect(result, equals({2, 4, 5, 8, 10, 12, 15}));
      expect(result.length, 7);
    });
  });

  group('ParkingService.fetchOccupiedSlots', () {
    // ========== TEST 9: Successful fetch ==========
    test('fetches and parses data successfully', () async {
      // Create a mock HTTP client that returns fake data
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"slot1": 1, "slot7": 1, "slot12": 1}',
          200,
        );
      });

      final service = ParkingService(
        firebaseUrl: 'https://test.example.com',
        client: mockClient,
      );

      final result = await service.fetchOccupiedSlots();
      expect(result, equals({1, 7, 12}));
    });

    // ========== TEST 10: Server error ==========
    test('throws exception on server error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = ParkingService(
        firebaseUrl: 'https://test.example.com',
        client: mockClient,
      );

      expect(
        () => service.fetchOccupiedSlots(),
        throwsException,
      );
    });

    // ========== TEST 11: Correct URL used ==========
    test('calls the correct Firebase URL', () async {
      String? capturedUrl;
      final mockClient = MockClient((request) async {
        capturedUrl = request.url.toString();
        return http.Response('{}', 200);
      });

      final service = ParkingService(
        firebaseUrl: 'https://myproject.firebaseio.com',
        client: mockClient,
      );

      await service.fetchOccupiedSlots();
      expect(capturedUrl, 'https://myproject.firebaseio.com/parking.json');
    });
  });
}
