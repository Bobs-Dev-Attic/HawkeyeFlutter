import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'repositories/location_repository.dart';
import 'repositories/user_repository.dart';
import 'services/auth_service.dart';
import 'services/crypto_service.dart';
import 'services/storage_service.dart';
import 'ui/screens/auth_gate.dart';

class HawkeyeApp extends StatelessWidget {
  const HawkeyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hawkeye',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final cryptoService = CryptoService();
          final authService = AuthService();
          final storageService = StorageService();

          return AuthGate(
            authService: authService,
            userRepository: UserRepository(
              authService: authService,
              storageService: storageService,
            ),
            locationRepository: LocationRepository(
              authService: authService,
              cryptoService: cryptoService,
            ),
          );
        },
      ),
    );
  }
}
