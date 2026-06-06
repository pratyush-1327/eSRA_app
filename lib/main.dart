import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/ble_repository.dart';
import 'data/ws_repository.dart';
import 'bloc/ble_bloc.dart';
import 'bloc/device_bloc.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(const ESRAApp());
}

class ESRAApp extends StatelessWidget {
  const ESRAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => BleRepository()),
        RepositoryProvider(create: (context) => WsRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => BleBloc(
              repository: RepositoryProvider.of<BleRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => DeviceBloc(
              repository: RepositoryProvider.of<WsRepository>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'eSRA Dashboard',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF90CAF9),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
