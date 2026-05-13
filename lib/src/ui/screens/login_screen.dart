import 'package:flutter/material.dart';

import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService, required this.userRepository});
  final AuthService authService;
  final UserRepository userRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;

  Future<void> _submit() async {
    if (_register) {
      await widget.authService.signUp(_email.text, _password.text);
      await widget.userRepository.createProfile(_name.text, _email.text);
    } else {
      await widget.authService.signIn(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hawkeye Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_register) TextField(controller: _name, decoration: const InputDecoration(labelText: 'Display name')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            FilledButton(onPressed: _submit, child: Text(_register ? 'Register' : 'Login')),
            TextButton(
              onPressed: () => setState(() => _register = !_register),
              child: Text(_register ? 'Already have an account?' : 'Create account'),
            )
          ],
        ),
      ),
    );
  }
}
