#  Smart Parking System

> IoT-based real-time parking management solution built with Flutter and Firebase.

A cross-platform mobile application that displays the live availability of 16 parking slots in real time. Drivers can check which slots are free before they even arrive at the parking lot — eliminating wasted time and reducing traffic congestion.

This project is my **graduation project** for the Software Engineering program at the **University of Jeddah**.

---

##  Features

-  **Real-time slot tracking** — slot status updates every 2 seconds from the cloud
-  **Visual parking layout** — 16 slots displayed with direction-aware car illustrations
-  **Cloud-connected** — powered by Firebase Realtime Database
-  **Cross-platform** — runs on Android, iOS, Web, Windows, macOS, and Linux from a single codebase
-  **Gym schedule screen** — secondary screen showing weekly gym timing
-  **Fully tested** — 24 automated tests across unit, widget, and integration layers

---


##  Tech Stack

| Layer            | Technology                              |
|------------------|-----------------------------------------|
| **Frontend**     | Flutter (Dart)                          |
| **Backend**      | Firebase Realtime Database              |
| **Communication**| HTTP REST (`http` package)              |
| **IoT Hardware** | ESP32 + UltraSound Sensors              |
| **Testing**      | `flutter_test`, `integration_test`      |
| **IDE**          | Visual Studio Code                      |
| **Version Control** | Git & GitHub                         |

---

##  System Architecture

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   IoT Hardware  │      │  Cloud Database  │      │   Mobile App    │
│   ESP32         │ ───→ │   Firebase RTDB  │ ───→ │  Flutter (Dart) │
│ + uSound Sensors│      │   parking/slotN  │      │   Real-time UI  │
└─────────────────┘      └──────────────────┘      └─────────────────┘
   Detects car           Stores 0 or 1 per         Polls every 2s,
   presence              parking slot              redraws UI live
```

---

##  Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extension
- Android emulator or physical device
- A Firebase project with Realtime Database enabled

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/mohammedjed08/smart-parking-system.git
cd smart-parking-system
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

   Update the Firebase URL in `lib/main.dart`:

```dart
const String firebaseUrl =
    'https://your-project-id.firebaseio.com';
```

4. **Run the app**

```bash
flutter run
```

---

##  Project Structure

```
parking_app/
├── lib/
│   ├── main.dart              # Main app + UI
│   └── parking_service.dart   # Firebase data layer
├── test/
│   ├── parking_service_test.dart   # 11 unit tests
│   └── widget_test.dart            # 9 widget tests
├── integration_test/
│   └── app_test.dart               # 4 integration tests
├── android/                   # Android platform code
├── ios/                       # iOS platform code
└── pubspec.yaml               # Dependencies
```

---

##  Testing

The project includes 24 automated tests across three levels:

| Test Level         | Count | Run Command                                    |
|--------------------|-------|------------------------------------------------|
| Unit Tests         | 11    | `flutter test test/parking_service_test.dart`  |
| Widget Tests       | 9     | `flutter test test/widget_test.dart`           |
| Integration Tests  | 4     | `flutter test integration_test/app_test.dart`  |
| **All Tests**      | **24**| `flutter test`                                 |

### Test Results

```
00:02 +20: All tests passed!     (unit + widget)
03:17 +4:  All tests passed!     (integration)
```

---

##  Firebase Data Structure

```json
{
  "parking": {
    "slot1": 0,
    "slot2": 1,
    "slot3": 0,
    ...
    "slot16": 0
  }
}
```

- `0` = Slot is **available** (green)
- `1` = Slot is **occupied** (red)

---

##  Future Work

- [ ] Add slot reservation feature (book ahead)
- [ ] Implement user authentication via Firebase Auth
- [ ] Add usage analytics dashboard (peak hours, occupancy trends)
- [ ] Multi-lot support (scale to multiple parking lots)
- [ ] Push notifications when preferred slot becomes available
- [ ] Payment integration for paid parking

---

##  License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
