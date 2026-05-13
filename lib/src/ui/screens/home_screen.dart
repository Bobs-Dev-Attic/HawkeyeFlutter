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

  Future<void> _pickAvatar() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      await widget.userRepository.updateAvatarImage(File(file.path));
    }
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
                FilledButton(
                  onPressed: () => widget.locationRepository.createCircle(name: _circleName.text, type: 'custom'),
                  child: const Text('Create Group'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => widget.locationRepository.saveEncryptedLocation(circleId: _circleName.text, lat: 40.0, lng: -73.0),
                  child: const Text('Send Mock Location'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _joinCode, decoration: const InputDecoration(labelText: 'Join with share code')),
            FilledButton.tonal(onPressed: () => widget.locationRepository.joinCircleByCode(_joinCode.text), child: const Text('Join Group')),
            const Divider(height: 24),
            const Text('Your groups'),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: widget.locationRepository.watchMyCircles(),
                builder: (context, snapshot) {
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
