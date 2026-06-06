class DeviceStateModel {
  final double temp;
  final String light;
  final String mode;
  final String led;
  final String fan;
  final double threshold;

  DeviceStateModel({
    required this.temp,
    required this.light,
    required this.mode,
    required this.led,
    required this.fan,
    required this.threshold,
  });

  factory DeviceStateModel.fromJson(Map<String, dynamic> json) {
    return DeviceStateModel(
      temp: (json['temp'] as num).toDouble(),
      light: json['light'] ?? '',
      mode: json['mode'] ?? '',
      led: json['led'] ?? '',
      fan: json['fan'] ?? '',
      threshold: (json['threshold'] as num?)?.toDouble() ?? 30.0,
    );
  }
}
