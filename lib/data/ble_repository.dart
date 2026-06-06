import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleRepository {
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String charUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String scanCharUuid = "d991b58a-36b6-4f7f-8566-f3353549666c";
  static const String ipCharUuid = "c77b4a2c-d64e-46ad-9720-6d8048f3f4e2";

  Future<BluetoothDevice?> scanForDevice() async {
    BluetoothDevice? foundDevice;
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        bool matchesName = (r.device.platformName == "eSRA_ESP32" || r.advertisementData.advName == "eSRA_ESP32");
        bool matchesUuid = r.advertisementData.serviceUuids.any((uuid) => uuid.toString().toLowerCase() == serviceUuid.toLowerCase());
        
        if (matchesName || matchesUuid) {
          foundDevice = r.device;
          FlutterBluePlus.stopScan();
          break;
        }
      }
    });
    
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    await Future.delayed(const Duration(milliseconds: 500)); // wait a bit for stopScan to process
    await subscription.cancel();
    return foundDevice;
  }

  Future<List<String>> fetchAvailableNetworks(BluetoothDevice device) async {
    try {
      if (device.connectionState != BluetoothConnectionState.connected) {
        await device.connect(timeout: const Duration(seconds: 5), license: License.free);
      }
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == scanCharUuid) {
              final rawData = await characteristic.read();
              final jsonString = utf8.decode(rawData);
              final List<dynamic> networks = jsonDecode(jsonString);
              return networks.map((e) => e.toString()).toList();
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching networks: $e");
    }
    return [];
  }

  Future<String?> connectAndProvision(BluetoothDevice device, String ssid, String pass) async {
    try {
      if (device.connectionState != BluetoothConnectionState.connected) {
        await device.connect(license: License.free);
      }
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? provisionChar;
      BluetoothCharacteristic? ipChar;

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == charUuid) {
              provisionChar = characteristic;
            } else if (characteristic.uuid.toString().toLowerCase() == ipCharUuid) {
              ipChar = characteristic;
            }
          }
        }
      }

      if (provisionChar != null && ipChar != null) {
        final payload = jsonEncode({"ssid": ssid, "pass": pass});
        await provisionChar.write(utf8.encode(payload));

        // Poll for IP address (max 15 seconds)
        for (int i = 0; i < 15; i++) {
          await Future.delayed(const Duration(seconds: 1));
          final rawIp = await ipChar.read();
          final ip = utf8.decode(rawIp);
          if (ip != "0.0.0.0" && ip.isNotEmpty) {
            return ip;
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
