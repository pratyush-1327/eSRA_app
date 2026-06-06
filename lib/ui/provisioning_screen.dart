import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ble_bloc.dart';

class ProvisioningScreen extends StatefulWidget {
  const ProvisioningScreen({super.key});

  @override
  State<ProvisioningScreen> createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends State<ProvisioningScreen> {
  String? _selectedSSID;
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BleBloc>().add(StartScanEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Device")),
      body: BlocConsumer<BleBloc, BleState>(
        listener: (context, state) {
          if (state is BleError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is BleProvisionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Provisioning Successful!")));
            Navigator.pop(context, state.ip); // Return the IP address to HomeScreen
          }
        },
        builder: (context, state) {
          if (state is BleScanning || state is BleInitial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Scanning for eSRA ESP32..."),
                ],
              ),
            );
          } else if (state is BleFetchingNetworks) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Device Found! Fetching WiFi networks..."),
                ],
              ),
            );
          } else if (state is BleNetworksFetched) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.developer_board, size: 80, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    "Device Ready",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedSSID,
                    decoration: const InputDecoration(
                      labelText: "Select WiFi Network",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.wifi),
                    ),
                    items: state.networks.toSet().map((ssid) {
                      return DropdownMenuItem(
                        value: ssid,
                        child: Text(ssid),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSSID = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "WiFi Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _selectedSSID == null ? null : () {
                      context.read<BleBloc>().add(ProvisionEvent(
                        state.device,
                        _selectedSSID!,
                        _passController.text,
                      ));
                    },
                    icon: const Icon(Icons.send),
                    label: const Text("Send Credentials"),
                  ),
                ],
              ),
            );
          } else if (state is BleProvisioning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Sending credentials via BLE..."),
                ],
              ),
            );
          } else {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.read<BleBloc>().add(StartScanEvent()),
                child: const Text("Retry Scan"),
              ),
            );
          }
        },
      ),
    );
  }
}
