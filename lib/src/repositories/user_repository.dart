import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class UserRepository {
  UserRepository({required AuthService authService, required StorageService storageService})
      : _authService = authService,
        _storageService = storageService;

  final AuthService _authService;
  final StorageService _storageService;
  final _db = FirebaseFirestore.instance;

  Future<void> createProfile(String displayName, String email) async {
    final uid = _authService.currentUser!.uid;
    final user = AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      avatarType: 'icon',
      avatarValue: 'person',
      circleIds: const [],
    );
    await _db.collection('users').doc(uid).set(user.toMap());
  }

  Future<void> updateAvatarIcon(String iconName) async {
    final uid = _authService.currentUser!.uid;
    await _db.collection('users').doc(uid).update({'avatarType': 'icon', 'avatarValue': iconName});
  }

  Future<void> updateAvatarImage(File file) async {
    final uid = _authService.currentUser!.uid;
    final url = await _storageService.uploadAvatar(uid: uid, file: file);
    await _db.collection('users').doc(uid).update({'avatarType': 'image', 'avatarValue': url});
  }

  Stream<AppUser?> watchMe() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!);
    });
  }
}
