import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/device_bloc.dart';
import '../models/device_state_model.dart';

class DashboardScreen extends StatefulWidget {
  final String ipAddress;
  const DashboardScreen({super.key, required this.ipAddress});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<FlSpot> _tempData = [];
  double _time = 0;

  @override
  void initState() {
    super.initState();
    context.read<DeviceBloc>().add(ConnectDeviceEvent(widget.ipAddress));
  }

  @override
  void deactivate() {
    context.read<DeviceBloc>().add(DisconnectDeviceEvent());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Dashboard"),
        actions: [
          BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              if (state is DeviceConnected) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.cloud_done, color: Colors.green),
                );
              }
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.cloud_off, color: Colors.red),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceConnected) {
            setState(() {
              _tempData.add(FlSpot(_time, state.deviceState.temp));
              _time += 1;
              if (_tempData.length > 20) {
                _tempData.removeAt(0); // keep last 20 pts
              }
            });
          }
        },
        builder: (context, state) {
          if (state is DeviceConnected) {
            final dev = state.deviceState;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildChartCard(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatusCard("Temperature", "${dev.temp} °C", Icons.thermostat)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatusCard("Light", dev.light, Icons.light_mode)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildControlPanel(dev),
                ],
              ),
            );
          } else if (state is DeviceConnecting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("Disconnected from device."));
          }
        },
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Live Temperature", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 10,
                  maxY: 50,
                  titlesData: const FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _tempData,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(DeviceStateModel dev) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Control Panel", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("AUTO Mode"),
              subtitle: const Text("Sensor-based automation"),
              value: dev.mode == "AUTO",
              onChanged: (val) {
                context.read<DeviceBloc>().add(SendCommandEvent("mode", "toggle"));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text("LED Light"),
              trailing: Switch(
                value: dev.led == "ON",
                onChanged: dev.mode == "AUTO" ? null : (val) {
                  context.read<DeviceBloc>().add(SendCommandEvent("led", "toggle"));
                },
              ),
            ),
            ListTile(
              title: const Text("Fan (Motor)"),
              trailing: Switch(
                value: dev.fan == "ON",
                onChanged: dev.mode == "AUTO" ? null : (val) {
                  context.read<DeviceBloc>().add(SendCommandEvent("fan", "toggle"));
                },
              ),
            ),
            if (dev.mode == "AUTO") ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Fan Temp Threshold", style: Theme.of(context).textTheme.bodyLarge),
                        Text("${dev.threshold.round()} °C", 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: dev.threshold,
                      min: 15,
                      max: 45,
                      divisions: 30,
                      label: "${dev.threshold.round()} °C",
                      onChanged: (val) {
                        context.read<DeviceBloc>().add(SendCommandEvent("threshold", val.round().toString()));
                      },
                    ),
                  ],
                ),
              ),
            ],
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: OutlinedButton.icon(
                onPressed: () => _showResetDialog(context),
                icon: const Icon(Icons.refresh, color: Colors.red),
                label: const Text("Factory Reset (Clear WiFi)", style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Factory Reset?"),
        content: const Text("This will clear WiFi credentials and restart the device in BLE mode. You will need to provision it again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              context.read<DeviceBloc>().add(SendCommandEvent("reset", "now"));
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('device_address');
              if (mounted) {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Exit dashboard to Home
              }
            },
            child: const Text("Reset Device"),
          ),
        ],
      ),
    );
  }
}
