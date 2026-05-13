import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/circle.dart';
import '../services/auth_service.dart';
import '../services/crypto_service.dart';

class LocationRepository {
  LocationRepository({required AuthService authService, required CryptoService cryptoService})
      : _authService = authService,
        _cryptoService = cryptoService;

  final AuthService _authService;
  final CryptoService _cryptoService;
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<void> createCircle({required String name, required String type}) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user.');
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) throw ArgumentError('Circle name cannot be empty.');
    final id = _uuid.v4();
    final shareCode = _uuid.v4().substring(0, 8).toUpperCase();
    final circle = Circle(id: id, name: trimmedName, type: type, shareCode: shareCode, memberUids: [uid]);
    await _db.collection('circles').doc(id).set(circle.toMap());
    await _db.collection('users').doc(uid).update({'circleIds': FieldValue.arrayUnion([id])});
  }

  Future<void> joinCircleByCode(String code) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user.');
    final trimmedCode = code.trim().toUpperCase();
    if (trimmedCode.isEmpty) throw ArgumentError('Join code cannot be empty.');
    final query = await _db.collection('circles').where('shareCode', isEqualTo: trimmedCode).limit(1).get();
    if (query.docs.isEmpty) return;
    final circleId = query.docs.first.id;
    await _db.collection('circles').doc(circleId).update({'memberUids': FieldValue.arrayUnion([uid])});
    await _db.collection('users').doc(uid).update({'circleIds': FieldValue.arrayUnion([circleId])});
  }

  Future<void> saveEncryptedLocation({required String circleId, required double lat, required double lng}) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user.');
    if (circleId.trim().isEmpty) throw ArgumentError('Circle ID is required.');
    final payload = await _cryptoService.encryptJson({
      'lat': lat,
      'lng': lng,
      'updatedAt': DateTime.now().toIso8601String(),
      'uid': uid,
    });

    await _db.collection('circles').doc(circleId).collection('locations').doc(uid).set({
      ...payload.toMap(),
      'senderUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveEncryptedPlace({required String circleId, required String name, required double lat, required double lng}) async {
    if (circleId.trim().isEmpty) throw ArgumentError('Circle ID is required.');
    if (name.trim().isEmpty) throw ArgumentError('Place name cannot be empty.');
    final payload = await _cryptoService.encryptJson({'name': name.trim(), 'lat': lat, 'lng': lng});
    await _db.collection('circles').doc(circleId).collection('places').add({
      ...payload.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchMyCircles() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _db.collection('circles').where('memberUids', arrayContains: uid).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }
}
