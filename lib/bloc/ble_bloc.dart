import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../data/ble_repository.dart';

// Events
abstract class BleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
class StartScanEvent extends BleEvent {}
class FetchNetworksEvent extends BleEvent {
  final BluetoothDevice device;
  FetchNetworksEvent(this.device);
  @override
  List<Object?> get props => [device];
}
class ProvisionEvent extends BleEvent {
  final BluetoothDevice device;
  final String ssid;
  final String pass;
  ProvisionEvent(this.device, this.ssid, this.pass);
  @override
  List<Object?> get props => [device, ssid, pass];
}

// States
abstract class BleState extends Equatable {
  @override
  List<Object?> get props => [];
}
class BleInitial extends BleState {}
class BleScanning extends BleState {}
class BleFetchingNetworks extends BleState {}
class BleNetworksFetched extends BleState {
  final BluetoothDevice device;
  final List<String> networks;
  BleNetworksFetched(this.device, this.networks);
  @override
  List<Object?> get props => [device, networks];
}
class BleDeviceFound extends BleState {
  final BluetoothDevice device;
  BleDeviceFound(this.device);
  @override
  List<Object?> get props => [device];
}
class BleError extends BleState {
  final String message;
  BleError(this.message);
  @override
  List<Object?> get props => [message];
}
class BleProvisioning extends BleState {}
class BleProvisionSuccess extends BleState {
  final String ip;
  BleProvisionSuccess(this.ip);
  @override
  List<Object?> get props => [ip];
}

// Bloc
class BleBloc extends Bloc<BleEvent, BleState> {
  final BleRepository repository;

  BleBloc({required this.repository}) : super(BleInitial()) {
    on<StartScanEvent>((event, emit) async {
      emit(BleScanning());
      final device = await repository.scanForDevice();
      if (device != null) {
        add(FetchNetworksEvent(device));
      } else {
        emit(BleError("Device not found. Make sure it's in BLE mode."));
      }
    });

    on<FetchNetworksEvent>((event, emit) async {
      emit(BleFetchingNetworks());
      final networks = await repository.fetchAvailableNetworks(event.device);
      emit(BleNetworksFetched(event.device, networks));
    });

    on<ProvisionEvent>((event, emit) async {
      emit(BleProvisioning());
      final ip = await repository.connectAndProvision(event.device, event.ssid, event.pass);
      if (ip != null) {
        emit(BleProvisionSuccess(ip));
      } else {
        emit(BleError("Provisioning failed or IP discovery timed out."));
      }
    });
  }
}
