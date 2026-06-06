import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/ws_repository.dart';
import '../models/device_state_model.dart';

// Events
abstract class DeviceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
class ConnectDeviceEvent extends DeviceEvent {
  final String ip;
  ConnectDeviceEvent(this.ip);
  @override
  List<Object?> get props => [ip];
}
class UpdateDeviceStateEvent extends DeviceEvent {
  final DeviceStateModel state;
  UpdateDeviceStateEvent(this.state);
  @override
  List<Object?> get props => [state];
}
class SendCommandEvent extends DeviceEvent {
  final String command;
  final String value;
  SendCommandEvent(this.command, this.value);
  @override
  List<Object?> get props => [command, value];
}
class DisconnectDeviceEvent extends DeviceEvent {}

// States
abstract class DeviceState extends Equatable {
  @override
  List<Object?> get props => [];
}
class DeviceDisconnected extends DeviceState {}
class DeviceConnecting extends DeviceState {}
class DeviceConnected extends DeviceState {
  final DeviceStateModel deviceState;
  DeviceConnected(this.deviceState);
  @override
  List<Object?> get props => [deviceState];
}

// Bloc
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final WsRepository repository;
  StreamSubscription? _subscription;

  DeviceBloc({required this.repository}) : super(DeviceDisconnected()) {
    on<ConnectDeviceEvent>((event, emit) {
      emit(DeviceConnecting());
      _subscription?.cancel();
      try {
        _subscription = repository.connect(event.ip).listen((state) {
          add(UpdateDeviceStateEvent(state));
        }, onError: (error) {
          add(DisconnectDeviceEvent());
        });
      } catch (e) {
        emit(DeviceDisconnected());
      }
    });

    on<UpdateDeviceStateEvent>((event, emit) {
      emit(DeviceConnected(event.state));
    });

    on<SendCommandEvent>((event, emit) {
      repository.sendCommand(event.command, event.value);
    });

    on<DisconnectDeviceEvent>((event, emit) {
      repository.disconnect();
      emit(DeviceDisconnected());
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    repository.disconnect();
    return super.close();
  }
}
