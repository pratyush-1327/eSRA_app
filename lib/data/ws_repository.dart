import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/device_state_model.dart';

class WsRepository {
  WebSocketChannel? _channel;

  Stream<DeviceStateModel> connect(String ip) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$ip:81/'));
    return _channel!.stream.map((event) {
      final data = jsonDecode(event);
      return DeviceStateModel.fromJson(data);
    });
  }

  void sendCommand(String command, String value) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({"command": command, "value": value}));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
