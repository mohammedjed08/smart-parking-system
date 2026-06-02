// ============================================================
// Smart Parking App
// Reads parking slot status from Firebase and displays them
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Firebase Realtime Database URL
const String firebaseUrl =
    'https://smart-parking-system-bd526-default-rtdb.europe-west1.firebasedatabase.app';

// Entry point of the application
void main() => runApp(const ParkingApp());

// ============================================================
// Main App Widget - ParkingApp
// ============================================================
class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      title: 'Parking App',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const ParkingScreen(), // Main screen
    );
  }
}

// ============================================================
// Main Screen - displays parking slots
// StatefulWidget because data changes (updates from Firebase)
// ============================================================
class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  // Set of occupied slot numbers (updates from Firebase)
  Set<int> occupiedSpots = {};
  
  // Loading indicator while fetching data
  bool isLoading = true;
  
  // Timer that polls Firebase every 2 seconds
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchParkingData(); // Initial fetch when app opens
    
    // Poll Firebase every 2 seconds (simulates real-time)
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchParkingData();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Stop timer when screen closes
    super.dispose();
  }

  // ============================================================
  // Fetch parking data from Firebase via HTTP
  // ============================================================
  Future<void> _fetchParkingData() async {
    try {
      // Send HTTP GET request to Firebase
      final response = await http.get(
        Uri.parse('$firebaseUrl/parking.json'),
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // If data is empty, stop loading and exit
        if (data == null) {
          if (mounted) setState(() => isLoading = false);
          return;
        }

        // Temporary set for new occupied slots
        final Set<int> newOccupied = {};
        final map = data as Map<String, dynamic>;

        // Loop through each slot in Firebase
        map.forEach((key, value) {
          // Extract number from key name (e.g., slot5 -> 5)
          final numberStr = key.replaceAll(RegExp(r'[^0-9]'), '');
          final spotNumber = int.tryParse(numberStr);
          if (spotNumber == null) return;

          // Check if slot is occupied (1 = occupied, 0 = available)
          final isOccupied = value == 1 || value == true || value == '1';
          if (isOccupied) {
            newOccupied.add(spotNumber);
          }
        });

        // Update UI with new data
        if (mounted) {
          setState(() {
            occupiedSpots = newOccupied;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      // Ignore errors and retry after 2 seconds
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ============================================================
  // Build main UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),              // Top header
              const SizedBox(height: 20),
              
              // Parking area - shows loading spinner if data not loaded yet
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildParkingArea(),
              ),
              
              const SizedBox(height: 15),
              _buildLegend(),              // Color legend (Available/Occupied)
              const SizedBox(height: 15),
              _buildGymScheduleButton(context),  // Gym Schedule button
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Header: location icon + Welcome back + jeddah city + Date button
  // ============================================================
  Widget _buildHeader() {
    return Row(
      children: [
        // Circular location icon
        Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Color(0xFF2A2AC0), // Dark blue
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        
        // Text (Welcome back + jeddah city)
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('jeddah city',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        
        // Date button (blue)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2AC0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 16),
              SizedBox(width: 5),
              Text('Date',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Parking area: road + ENTRY label + slots grid
  // ============================================================
  Widget _buildParkingArea() {
    return Row(
      children: [
        _buildRoad(),                    // Black road (ROAD)
        const SizedBox(width: 8),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENTRY label on top
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('ENTRY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    )),
              ),
              
              // Slots grid (two columns)
              Expanded(
                child: Row(
                  children: [
                    // Left column: slots 1 to 8 (cars face right)
                    Expanded(
                      child: _buildColumn(
                        [8, 7, 6, 5, 4, 3, 2, 1],
                        faceRight: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Right column: slots 9 to 16 (cars face left)
                    Expanded(
                      child: _buildColumn(
                        [16, 15, 14, 13, 12, 11, 10, 9],
                        faceRight: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Black road with dashed white line and ROAD text
  // ============================================================
  Widget _buildRoad() {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dashed white lines (14 segments)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      14,
                      (i) =>
                          Container(width: 2, height: 10, color: Colors.white),
                    ),
                  ),
                  // ROAD text rotated 270 degrees
                  RotatedBox(
                    quarterTurns: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.black,
                      child: const Text('ROAD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Build a column of slots (8 slots)
  // ============================================================
  Widget _buildColumn(List<int> spots, {required bool faceRight}) {
    return Column(
      children: spots.map((number) {
        // Check if this slot is occupied
        final isOccupied = occupiedSpots.contains(number);
        return Expanded(
          child: _buildParkingSpot(number, isOccupied, faceRight),
        );
      }).toList(),
    );
  }

  // ============================================================
  // Build a single parking slot (border + number + car)
  // ============================================================
  Widget _buildParkingSpot(int number, bool isOccupied, bool faceRight) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        // Dashed red border around the slot
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Slot number (e.g., 01, 02, ...)
          Text(
            number.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 4),
          
          // Car (drawn with CustomPaint)
          Expanded(
            child: CustomPaint(
              painter: CarPainter(
                isOccupied: isOccupied,
                faceRight: faceRight,
              ),
              child: const SizedBox(height: 40),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Color legend: Available (green) + Occupied (red)
  // ============================================================
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFF34C759), 'Available'),
        const SizedBox(width: 25),
        _legendItem(const Color(0xFFB54B4B), 'Occupied'),
      ],
    );
  }

  // Single legend item (color box + label)
  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  // ============================================================
  // Gym Schedule button (opens gym timing screen)
  // ============================================================
  Widget _buildGymScheduleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        // On press, navigate to GymTimingScreen
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GymTimingScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2AC0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Gym Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Gym Timing Screen - displays gym schedule
// ============================================================
class GymTimingScreen extends StatelessWidget {
  const GymTimingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of days with their times (can be edited here)
    final List<Map<String, String>> schedule = [
      {'day': 'Thursday', 'time': 'Open 24 hours'},
      {'day': 'Friday', 'time': '12-4 AM, 1 PM-12 AM'},
      {'day': 'Saturday', 'time': 'Open 24 hours'},
      {'day': 'Sunday', 'time': 'Open 24 hours'},
      {'day': 'Monday', 'time': 'Open 24 hours'},
      {'day': 'Tuesday', 'time': 'Open 24 hours'},
      {'day': 'Wednesday', 'time': 'Open 24 hours'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      
      // Top app bar with back button
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Go back to previous screen
        ),
        title: const Text(
          'Gym Timing',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Open now" text
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 4),
              child: Text(
                'Open now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            
            // Schedule card (with subtle shadow)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                // Build a row for each day in the list
                children: schedule.map((item) {
                  return _buildScheduleRow(item['day']!, item['time']!);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Single row in the schedule (clock icon + day + time)
  // ============================================================
  Widget _buildScheduleRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Purple clock icon
          const Icon(Icons.access_time, color: Color(0xFF2A2AC0), size: 22),
          const SizedBox(width: 16),
          
          // Day name
          SizedBox(
            width: 100,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          
          // Time
          Expanded(
            child: Text(
              time,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Car Painter - CarPainter
// Uses CustomPaint to draw a realistic car
// ============================================================
class CarPainter extends CustomPainter {
  final bool isOccupied;  // Is the car occupied (red) or available (green)
  final bool faceRight;   // Front direction: true = right, false = left

  CarPainter({required this.isOccupied, required this.faceRight});

  // Colors used in drawing
  static const _greenMain = Color(0xFF34C759);          // Green for available
  static const _redMain = Color(0xFFB54B4B);            // Red for occupied
  static const _redDark = Color(0xFF8B3636);            // Dark red for roof
  static const _glassDark = Color(0xCC1A1A1A);          // Tinted glass
  static const _headlightYellow = Color(0xFFFFE680);    // Yellow headlights
  static const _taillightRed = Color(0xFFFF6B6B);       // Red taillights

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final color = isOccupied ? _redMain : _greenMain;

    // ============================================
    // 1. Draw the car body (outer shape)
    // ============================================
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.14, w * 0.92, h * 0.72),
      Radius.circular(h * 0.25),
    );

    if (isOccupied) {
      // Occupied car: filled with red
      canvas.drawRRect(body, Paint()..color = color);
    } else {
      // Available car: green border only
      canvas.drawRRect(
        body,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // ============================================
    // 2. Draw side mirrors (4 mirrors)
    // ============================================
    final mirrorPaint = Paint()
      ..color = isOccupied ? _redDark : color
      ..style = isOccupied ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final mirrorW = w * 0.06;
    final mirrorH = h * 0.08;

    // Top right mirror
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, h * 0.04, mirrorW, mirrorH),
        const Radius.circular(1.5),
      ),
      mirrorPaint,
    );
    // Top left mirror
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.04, mirrorW, mirrorH),
        const Radius.circular(1.5),
      ),
      mirrorPaint,
    );
    // Bottom right mirror
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, h * 0.88, mirrorW, mirrorH),
        const Radius.circular(1.5),
      ),
      mirrorPaint,
    );
    // Bottom left mirror
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.88, mirrorW, mirrorH),
        const Radius.circular(1.5),
      ),
      mirrorPaint,
    );

    // ============================================
    // 3. Draw car parts based on direction
    // (rear glass + roof + front windshield + lights)
    // ============================================
    if (faceRight) {
      // Car facing right (front is on the right side)
      _drawCarParts(canvas, w, h,
          rearStart: w * 0.16,
          rearEnd: w * 0.36,
          roofStart: w * 0.38,
          roofEnd: w * 0.60,
          frontStart: w * 0.60,
          frontEnd: w * 0.82,
          frontTaper: true,
          color: color);

      _drawLights(canvas, w * 0.92, h, isFront: true);   // Front lights on right
      _drawLights(canvas, w * 0.08, h, isFront: false);  // Rear lights on left
    } else {
      // Car facing left (front is on the left side)
      _drawCarParts(canvas, w, h,
          rearStart: w * 0.64,
          rearEnd: w * 0.84,
          roofStart: w * 0.40,
          roofEnd: w * 0.62,
          frontStart: w * 0.18,
          frontEnd: w * 0.40,
          frontTaper: false,
          color: color);

      _drawLights(canvas, w * 0.08, h, isFront: true);   // Front lights on left
      _drawLights(canvas, w * 0.92, h, isFront: false);  // Rear lights on right
    }
  }

  // ============================================================
  // Draw the 3 parts of the car:
  // Rear glass (rectangle) + Roof (middle) + Front windshield (trapezoid)
  // ============================================================
  void _drawCarParts(
    Canvas canvas,
    double w,
    double h, {
    required double rearStart,
    required double rearEnd,
    required double roofStart,
    required double roofEnd,
    required double frontStart,
    required double frontEnd,
    required bool frontTaper, // true = trapezoid narrowing right
    required Color color,
  }) {
    // Glass paint: tinted for occupied, border only for available
    final glassFill = isOccupied
        ? (Paint()..color = _glassDark)
        : (Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // === Rear glass (simple rectangle) ===
    final rearRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(rearStart, h * 0.24, rearEnd - rearStart, h * 0.52),
      const Radius.circular(2),
    );
    canvas.drawRRect(rearRect, glassFill);

    // === Roof (in the middle) ===
    final roofRect = Rect.fromLTWH(
        roofStart, h * 0.22, roofEnd - roofStart, h * 0.56);
    if (isOccupied) {
      // Dark red roof for occupied
      canvas.drawRect(roofRect, Paint()..color = _redDark);
    } else {
      // Border only for available
      canvas.drawRect(
        roofRect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // === Front windshield (trapezoid showing the front) ===
    final frontPath = Path();
    if (frontTaper) {
      // Narrows to the right (front on right)
      frontPath
        ..moveTo(frontStart, h * 0.22)
        ..lineTo(frontEnd, h * 0.32)
        ..lineTo(frontEnd, h * 0.68)
        ..lineTo(frontStart, h * 0.78)
        ..close();
    } else {
      // Narrows to the left (front on left)
      frontPath
        ..moveTo(frontEnd, h * 0.22)
        ..lineTo(frontStart, h * 0.32)
        ..lineTo(frontStart, h * 0.68)
        ..lineTo(frontEnd, h * 0.78)
        ..close();
    }

    if (isOccupied) {
      canvas.drawPath(frontPath, Paint()..color = _glassDark);
    } else {
      canvas.drawPath(
        frontPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  // ============================================================
  // Draw the lights (yellow headlights or red taillights)
  // ============================================================
  void _drawLights(Canvas canvas, double x, double h, {required bool isFront}) {
    if (isOccupied) {
      // Occupied: colored lights (yellow front, red rear)
      final lightColor = isFront ? _headlightYellow : _taillightRed;
      final radius = isFront ? 2.5 : 2.0;
      canvas.drawCircle(
        Offset(x, h * 0.28),
        radius,
        Paint()..color = lightColor,
      );
      canvas.drawCircle(
        Offset(x, h * 0.72),
        radius,
        Paint()..color = lightColor,
      );
    } else {
      // Available: simple lights matching car color
      canvas.drawCircle(
        Offset(x, h * 0.28),
        2.0,
        Paint()..color = _greenMain,
      );
      canvas.drawCircle(
        Offset(x, h * 0.72),
        2.0,
        Paint()..color = _greenMain,
      );
    }
  }

  // ============================================================
  // When to repaint the car (for performance)
  // Only when isOccupied or faceRight changes
  // ============================================================
  @override
  bool shouldRepaint(covariant CarPainter oldDelegate) =>
      oldDelegate.isOccupied != isOccupied ||
      oldDelegate.faceRight != faceRight;
}
