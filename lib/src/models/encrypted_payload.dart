class EncryptedPayload {
  const EncryptedPayload({
    required this.cipherText,
    required this.nonce,
    required this.mac,
    required this.algorithm,
  });

  final String cipherText;
  final String nonce;
  final String mac;
  final String algorithm;

  Map<String, dynamic> toMap() => {
        'cipherText': cipherText,
        'nonce': nonce,
        'mac': mac,
        'algorithm': algorithm,
      };

  factory EncryptedPayload.fromMap(Map<String, dynamic> map) => EncryptedPayload(
        cipherText: map['cipherText'] as String,
        nonce: map['nonce'] as String,
        mac: map['mac'] as String,
        algorithm: map['algorithm'] as String,
      );
}
