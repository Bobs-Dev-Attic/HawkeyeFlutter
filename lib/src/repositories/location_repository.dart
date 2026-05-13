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
    final uid = _authService.currentUser!.uid;
    final id = _uuid.v4();
    final shareCode = _uuid.v4().substring(0, 8).toUpperCase();
    final circle = Circle(id: id, name: name, type: type, shareCode: shareCode, memberUids: [uid]);
    await _db.collection('circles').doc(id).set(circle.toMap());
    await _db.collection('users').doc(uid).update({
      'circleIds': FieldValue.arrayUnion([id])
    });
  }

  Future<void> joinCircleByCode(String code) async {
    final uid = _authService.currentUser!.uid;
    final query = await _db.collection('circles').where('shareCode', isEqualTo: code.trim().toUpperCase()).limit(1).get();
    if (query.docs.isEmpty) return;
    final circleId = query.docs.first.id;
    await _db.collection('circles').doc(circleId).update({'memberUids': FieldValue.arrayUnion([uid])});
    await _db.collection('users').doc(uid).update({'circleIds': FieldValue.arrayUnion([circleId])});
  }

  Future<void> saveEncryptedLocation({required String circleId, required double lat, required double lng}) async {
    final uid = _authService.currentUser!.uid;
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
    final payload = await _cryptoService.encryptJson({'name': name, 'lat': lat, 'lng': lng});
    await _db.collection('circles').doc(circleId).collection('places').add({
      ...payload.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchMyCircles() {
    final uid = _authService.currentUser!.uid;
    return _db.collection('circles').where('memberUids', arrayContains: uid).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }
}
