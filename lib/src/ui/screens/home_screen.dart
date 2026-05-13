import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../repositories/location_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authService,
    required this.userRepository,
    required this.locationRepository,
  });

  final AuthService authService;
  final UserRepository userRepository;
  final LocationRepository locationRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _circleName = TextEditingController();
  final _joinCode = TextEditingController();
  bool _isCreating = false;
  bool _isJoining = false;
  bool _isSendingLocation = false;

  @override
  void dispose() {
    _circleName.dispose();
    _joinCode.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        await widget.userRepository.updateAvatarImage(File(file.path));
      }
    } catch (e) {
      _showMessage('Avatar upload failed. ${e.toString()}');
    }
  }

  Future<void> _createGroup() async {
    if (_isCreating) return;
    final name = _circleName.text.trim();
    if (name.isEmpty) return _showMessage('Group name is required.');
    setState(() => _isCreating = true);
    try {
      await widget.locationRepository.createCircle(name: name, type: 'custom');
      _showMessage('Group created.');
    } catch (e) {
      _showMessage('Failed to create group. ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _joinGroup() async {
    if (_isJoining) return;
    final code = _joinCode.text.trim();
    if (code.isEmpty) return _showMessage('Join code is required.');
    setState(() => _isJoining = true);
    try {
      await widget.locationRepository.joinCircleByCode(code);
      _showMessage('Join request completed.');
    } catch (e) {
      _showMessage('Failed to join group. ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _sendLocation() async {
    if (_isSendingLocation) return;
    final circles = await widget.locationRepository.watchMyCircles().first;
    if (circles.isEmpty) return _showMessage('Create or join a group first.');
    final circleId = circles.first['id'] as String;
    setState(() => _isSendingLocation = true);
    try {
      await widget.locationRepository.saveEncryptedLocation(circleId: circleId, lat: 40.0, lng: -73.0);
      _showMessage('Mock location sent.');
    } catch (e) {
      _showMessage('Failed to send location. ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSendingLocation = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawkeye Circles'),
        actions: [IconButton(onPressed: widget.authService.signOut, icon: const Icon(Icons.logout))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(onPressed: () => widget.userRepository.updateAvatarIcon('person'), child: const Text('Icon: Person')),
                FilledButton.tonal(onPressed: () => widget.userRepository.updateAvatarIcon('pets'), child: const Text('Icon: Pet')),
                FilledButton.tonal(onPressed: _pickAvatar, child: const Text('Upload Avatar')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _circleName, decoration: const InputDecoration(labelText: 'New group name (family/friends/coworkers)')),
            Row(
              children: [
                FilledButton(onPressed: _isCreating ? null : _createGroup, child: const Text('Create Group')),
                const SizedBox(width: 8),
                FilledButton.tonal(onPressed: _isSendingLocation ? null : _sendLocation, child: const Text('Send Mock Location')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _joinCode, decoration: const InputDecoration(labelText: 'Join with share code')),
            FilledButton.tonal(onPressed: _isJoining ? null : _joinGroup, child: const Text('Join Group')),
            const Divider(height: 24),
            const Text('Your groups'),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: widget.locationRepository.watchMyCircles(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load groups'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final circles = snapshot.data ?? const [];
                  if (circles.isEmpty) {
                    return const Center(child: Text('No groups yet'));
                  }
                  return ListView.builder(
                    itemCount: circles.length,
                    itemBuilder: (context, index) {
                      final circle = circles[index];
                      return Card(
                        child: ListTile(
                          title: Text(circle['name'] as String? ?? 'Unnamed group'),
                          subtitle: Text('Type: ${circle['type']} • Share code: ${circle['shareCode']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.bookmark_add),
                            onPressed: () => widget.locationRepository.saveEncryptedPlace(
                              circleId: circle['id'] as String,
                              name: 'Saved Place ${index + 1}',
                              lat: 37.4,
                              lng: -122.1,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
