// ============================================================
// ParkingService - Business logic for fetching parking data
// Separated from UI to make it testable
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

class ParkingService {
  final String firebaseUrl;
  final http.Client client;

  ParkingService({
    required this.firebaseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  // Fetches parking data and returns set of occupied slot numbers
  Future<Set<int>> fetchOccupiedSlots() async {
    final response = await client.get(
      Uri.parse('$firebaseUrl/parking.json'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch: ${response.statusCode}');
    }

    return parseParkingData(response.body);
  }

  // Parses JSON string into set of occupied slot numbers
  // Made public (no underscore) so we can test it directly
  Set<int> parseParkingData(String jsonString) {
    final data = jsonDecode(jsonString);
    if (data == null) return {};

    final Set<int> occupied = {};
    final map = data as Map<String, dynamic>;

    map.forEach((key, value) {
      final numberStr = key.replaceAll(RegExp(r'[^0-9]'), '');
      final spotNumber = int.tryParse(numberStr);
      if (spotNumber == null) return;

      final isOccupied = value == 1 || value == true || value == '1';
      if (isOccupied) {
        occupied.add(spotNumber);
      }
    });

    return occupied;
  }
}
