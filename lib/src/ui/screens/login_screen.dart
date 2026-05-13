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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final email = _email.text.trim();
    final password = _password.text;
    final name = _name.text.trim();

    if (email.isEmpty || password.isEmpty || (_register && name.isEmpty)) {
      _showMessage('Please fill in all required fields.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_register) {
        await widget.authService.signUp(email, password);
        await widget.userRepository.upsertMyProfile(displayName: name, email: email);
      } else {
        await widget.authService.signIn(email, password);
        await widget.userRepository.upsertMyProfile(displayName: '', email: email);
      }
    } catch (e) {
      _showMessage('Authentication failed. ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            FilledButton(onPressed: _isSubmitting ? null : _submit, child: Text(_register ? 'Register' : 'Login')),
            if (_isSubmitting) const Padding(padding: EdgeInsets.only(top: 8), child: CircularProgressIndicator()),
            TextButton(
              onPressed: _isSubmitting ? null : () => setState(() => _register = !_register),
              child: Text(_register ? 'Already have an account?' : 'Create account'),
            )
          ],
        ),
      ),
    );
  }
}
