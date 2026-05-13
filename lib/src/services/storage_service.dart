import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAvatar({required String uid, required File file}) async {
    final ref = _storage.ref().child('avatars').child(uid).child('avatar.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
