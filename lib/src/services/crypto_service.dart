import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/encrypted_payload.dart';

class CryptoService {
  static const _keyName = 'hawkeye.symmetric.key';
  static const _storage = FlutterSecureStorage();
  final _algo = AesGcm.with256bits();

  Future<SecretKey> _getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) {
      return SecretKey(hex.decode(existing));
    }

    final random = Cryptography.instance.newRandomBytes(32);
    await _storage.write(key: _keyName, value: hex.encode(random));
    return SecretKey(random);
  }

  Future<EncryptedPayload> encryptJson(Map<String, dynamic> value) async {
    final key = await _getOrCreateKey();
    final clear = utf8.encode(jsonEncode(value));
    final secretBox = await _algo.encrypt(clear, secretKey: key);

    return EncryptedPayload(
      cipherText: base64Encode(secretBox.cipherText),
      nonce: base64Encode(secretBox.nonce),
      mac: base64Encode(secretBox.mac.bytes),
      algorithm: 'AES-256-GCM',
    );
  }
}
