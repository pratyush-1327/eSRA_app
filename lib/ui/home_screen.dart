import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provisioning_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _savedDeviceAddress;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedDeviceAddress = prefs.getString('device_address');
    });
  }

  Future<void> _saveDevice(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_address', address);
    _loadDevice();
  }

  Future<void> _removeDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_address');
    setState(() {
      _savedDeviceAddress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("eSRA Home"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_max, size: 100, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                "Welcome to eSRA",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _savedDeviceAddress == null 
                  ? "Smart Room Automation at your fingertips."
                  : "Device 'esra.local' is ready to connect.",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_savedDeviceAddress != null) ...[
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => DashboardScreen(ipAddress: _savedDeviceAddress!),
                    ));
                  },
                  icon: const Icon(Icons.bolt),
                  label: const Text("Enter Dashboard"),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _removeDevice,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Forget Device"),
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: () async {
                    final String? deviceIp = await Navigator.push<String>(
                      context, 
                      MaterialPageRoute(builder: (_) => const ProvisioningScreen())
                    );
                    
                    if (deviceIp != null && deviceIp.isNotEmpty) {
                      _saveDevice(deviceIp);
                    }
                  },
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text("Add New ESP32 Device"),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    _showIpDialog(context);
                  },
                  icon: const Icon(Icons.wifi),
                  label: const Text("Connect Manually (IP)"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showIpDialog(BuildContext context) {
    final TextEditingController ipController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Device IP"),
          content: TextField(
            controller: ipController,
            decoration: const InputDecoration(
              labelText: "IP Address",
              hintText: "e.g. 192.168.1.100",
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                if (ipController.text.isNotEmpty) {
                  _saveDevice(ipController.text);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => DashboardScreen(ipAddress: ipController.text),
                  ));
                }
              },
              child: const Text("Connect"),
            ),
          ],
        );
      },
    );
  }
}
