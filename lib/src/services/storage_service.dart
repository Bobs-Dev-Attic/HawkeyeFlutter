import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAvatar({required String uid, required File file}) async {
    final bytes = await file.length();
    const maxBytes = 5 * 1024 * 1024;
    if (bytes > maxBytes) {
      throw ArgumentError('Avatar must be 5MB or smaller.');
    }

    final extension = file.path.split('.').last.toLowerCase();
    final allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
    if (!allowedExtensions.contains(extension)) {
      throw ArgumentError('Unsupported avatar format. Use JPG, PNG, or WEBP.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('avatars').child(uid).child('avatar_$timestamp.$extension');
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$extension', cacheControl: 'public,max-age=3600'),
    );
    return ref.getDownloadURL();
  }
}
