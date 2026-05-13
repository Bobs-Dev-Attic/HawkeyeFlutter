import 'package:flutter/material.dart';

import '../../repositories/location_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.userRepository,
    required this.locationRepository,
  });

  final AuthService authService;
  final UserRepository userRepository;
  final LocationRepository locationRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.authState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginScreen(authService: authService, userRepository: userRepository);
        }

        return HomeScreen(
          authService: authService,
          userRepository: userRepository,
          locationRepository: locationRepository,
        );
      },
    );
  }
}
