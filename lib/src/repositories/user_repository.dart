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
    await upsertMyProfile(displayName: displayName, email: email);
  }

  Future<void> upsertMyProfile({required String displayName, required String email}) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user.');
    final userRef = _db.collection('users').doc(uid);
    final existing = await userRef.get();
    final safeEmail = email.trim();
    final nameFromEmail = safeEmail.isNotEmpty ? safeEmail.split('@').first : 'User';
    final safeDisplayName = displayName.trim().isEmpty ? nameFromEmail : displayName.trim();

    if (!existing.exists) {
      final user = AppUser(
        uid: uid,
        email: safeEmail,
        displayName: safeDisplayName,
        avatarType: 'icon',
        avatarValue: 'person',
        circleIds: const [],
      );
      await userRef.set(user.toMap());
      return;
    }

    await userRef.set({
      'email': safeEmail,
      if (displayName.trim().isNotEmpty) 'displayName': safeDisplayName,
    }, SetOptions(merge: true));
  }

  Future<void> updateAvatarIcon(String iconName) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user.');
    await _db.collection('users').doc(uid).update({'avatarType': 'icon', 'avatarValue': iconName});
  }

  Future<void> updateAvatarImage(File file) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user.');
    final url = await _storageService.uploadAvatar(uid: uid, file: file);
    await _db.collection('users').doc(uid).update({'avatarType': 'image', 'avatarValue': url});
  }

  Stream<AppUser?> watchMe() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!);
    });
  }
}
