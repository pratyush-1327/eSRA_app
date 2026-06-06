# eSRA Dashboard App

A Flutter-based mobile application for managing and monitoring **eSRA** devices (ESP32-based IoT systems). The app enables seamless Bluetooth provisioning and WebSocket-based real-time communication with eSRA hardware.

## 🎯 Overview

eSRA Dashboard is a companion mobile application that allows users to:
- **Discover & Connect** to eSRA ESP32 devices via Bluetooth Low Energy (BLE)
- **Provision WiFi** credentials to eSRA devices securely
- **Monitor** real-time device metrics (temperature, light levels, mode, etc.)
- **Control** device features (LED, fan, thresholds) via WebSocket commands
- **Save** device addresses for quick reconnection

## ✨ Features

### Device Discovery & Provisioning
- **Bluetooth Scanning**: Auto-discovers nearby eSRA ESP32 devices
- **Network Selection**: Fetches available WiFi networks via BLE
- **Secure Provisioning**: Sends WiFi credentials to device over Bluetooth
- **Device Memory**: Saves last connected device for quick access

### Live Dashboard
- **Real-time Monitoring**: Connected via WebSocket to receive live device updates
- **Live Charts**: Visualizes temperature trends using `fl_chart`
- **Status Indicators**: Visual feedback for connection state
- **Remote Control**: Send commands to adjust device settings
  - Toggle LED on/off
  - Control fan speed
  - Adjust temperature threshold
  - Change device mode

### Cross-Platform Support
- ✅ Android (5.0+)
- ✅ iOS (11.0+)
- ✅ Web (experimental)
- ✅ Linux & Windows (experimental)

## 📱 Screenshots Overview

The app consists of three main screens:
1. **Home Screen**: Device selection and provisioning entry point
2. **Provisioning Screen**: BLE device discovery and WiFi setup
3. **Dashboard Screen**: Real-time monitoring and control interface

## 🏗️ Architecture

The app follows **BLoC (Business Logic Component)** architecture pattern with clean separation of concerns:

```
lib/
├── main.dart                 # App entry point with MultiRepositoryProvider & MultiBlocProvider
├── bloc/                     # Business Logic Components
│   ├── ble_bloc.dart        # Handles BLE operations (scanning, provisioning)
│   └── device_bloc.dart     # Manages device connection and WebSocket communication
├── data/                     # Data layer & Repositories
│   ├── ble_repository.dart  # BLE interactions (scan, fetch networks, provision)
│   └── ws_repository.dart   # WebSocket communication with devices
├── models/                   # Data models
│   └── device_state_model.dart  # Device state representation
└── ui/                       # Presentation layer
    ├── home_screen.dart       # Main navigation screen
    ├── provisioning_screen.dart # BLE device provisioning flow
    └── dashboard_screen.dart   # Live device monitoring & control
```

## 📦 Dependencies

### Core Framework
- **flutter**: Flutter SDK (3.6.1+)
- **flutter_bloc**: 9.1.1 - State management
- **equatable**: 2.0.8 - Value equality helpers

### Hardware & Connectivity
- **flutter_blue_plus**: 2.2.1 - Bluetooth Low Energy communication
- **web_socket_channel**: 3.0.3 - WebSocket client for real-time data
- **permission_handler**: 12.0.1 - Runtime permission management

### UI & Visualization
- **fl_chart**: 0.71.0 - Beautiful charts and graphs
- **Material Design 3**: Built-in modern UI components

### Storage
- **shared_preferences**: 2.5.2 - Local persistent storage (device addresses)

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.6.1 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Android Studio** / **Xcode** for native development
- **Physical Device** or **Emulator** for testing
- An **eSRA ESP32** device for full functionality

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd eSRA_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions** (Android/iOS specific)
   - Android: Ensure Bluetooth and location permissions are declared in `AndroidManifest.xml`
   - iOS: Update `Info.plist` with Bluetooth permissions

4. **Run the app**
   ```bash
   # Development
   flutter run

   # Release build
   flutter run --release
   ```

## 🔧 Configuration

### BLE Service UUIDs
The app searches for eSRA devices with:
- **Device Name**: `eSRA_ESP32`
- **Service UUID**: `4fafc201-1fb5-459e-8fcc-c5c9c331914b`

### Characteristic UUIDs
- **Network Scan**: `d991b58a-36b6-4f7f-8566-f3353549666c` (read available networks)
- **WiFi Provisioning**: `beb5483e-36e1-4688-b7f5-ea07361b26a8` (write WiFi credentials)
- **IP Address**: `c77b4a2c-d64e-46ad-9720-6d8048f3f4e2` (read device IP)

These are defined in [data/ble_repository.dart](lib/data/ble_repository.dart#L6-L9).

## 📊 Data Flow

### Device Provisioning Flow
```
Home Screen
  → Provisioning Screen
    → BLE Scan (StartScanEvent)
    → Device Found (BleFetchingNetworks)
    → Fetch WiFi Networks
    → User selects SSID & enters password
    → Provision Device (ProvisionEvent)
    → Device connects to WiFi & reports IP
  → Dashboard Screen
```

### Live Monitoring Flow
```
Dashboard Screen
  → Connect via WebSocket (ConnectDeviceEvent)
  → Receive device state updates (UpdateDeviceStateEvent)
  → Parse JSON device state
  → Update UI charts & indicators
  → Send commands (SendCommandEvent) on user interaction
  → Disconnect on screen exit (DisconnectDeviceEvent)
```

## 🎨 Theme

The app supports both **Light** and **Dark** themes with Material Design 3:
- **Primary Color**: Deep Blue (`#0D47A1` light, `#90CAF9` dark)
- **Material 3**: Modern UI components and animations
- **System Theme**: Automatically adapts to device theme preference

## 🧪 Development

### Adding New Features

1. **New BLE Operations**: Extend `BleBloc` and `BleRepository`
2. **New Device Controls**: Add events to `DeviceBloc` and `WsRepository`
3. **New UI Screens**: Create in `ui/` folder and add to app routing
4. **New Data Models**: Add to `models/` folder with JSON serialization

### Running on Different Platforms

```bash
# Android
flutter run -d <device-id>

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# macOS/Linux/Windows
flutter run -d <platform>
```

## 📱 Platform-Specific Notes

### Android
- Requires API Level 21+ (Bluetooth 5.0)
- Permissions: `BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION`
- Request runtime permissions for location access

### iOS
- Requires iOS 11.0+
- Add Bluetooth permissions to `Info.plist`
- May require additional configuration for Bluetooth background modes

## 🐛 Troubleshooting

### Device Not Found During Scan
- Ensure eSRA device is powered on and in BLE advertising mode
- Check Bluetooth is enabled on mobile device
- Grant location permissions (required on Android)

### WebSocket Connection Fails
- Verify device IP address is correct
- Ensure device is connected to the same WiFi network
- Check device firewall settings

### BLE Provisioning Fails
- Ensure correct WiFi SSID and password
- Device may need to be factory reset before reprovisioning
- Check BLE connection strength (move closer to device)

## 📋 Future Enhancements

- [ ] Multiple device management (connect to multiple eSRA devices)
- [ ] Advanced analytics and data logging
- [ ] Device firmware update over-the-air (OTA)
- [ ] Custom alert configurations
- [ ] Cloud synchronization
- [ ] Push notifications for device events
- [ ] Voice control integration

## 📄 License

This project is part of the eSRA platform. Please refer to the LICENSE file for details.

## 👥 Support & Contribution

For issues, feature requests, or contributions, please open an issue in the repository.

---

**Built with ❤️ using Flutter**
