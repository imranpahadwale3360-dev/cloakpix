import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'secure_key_service.dart';

class VaultCryptoService {
  VaultCryptoService({SecureKeyService? secureKeyService})
      : _secureKeyService = secureKeyService ?? SecureKeyService();

  final SecureKeyService _secureKeyService;
  final AesGcm _aesGcm = AesGcm.with256bits();

  Future<void> encryptFile({
    required File inputFile,
    required File outputFile,
  }) async {
    final bytes = await inputFile.readAsBytes();
    final encrypted = await encryptBytes(bytes);
    await outputFile.parent.create(recursive: true);

    // Format: 12-byte nonce + cipherText + 16-byte GCM MAC.
    await outputFile.writeAsBytes(encrypted, flush: true);
  }

  Future<Uint8List> decryptFileToMemory(File encryptedFile) async {
    final encrypted = await encryptedFile.readAsBytes();
    return decryptBytes(encrypted);
  }

  Future<Uint8List> encryptBytes(List<int> clearBytes) async {
    final key = await _secureKeyService.getOrCreateMasterKey();
    final secretBox = await _aesGcm.encrypt(
      clearBytes,
      secretKey: SecretKey(key),
    );
    return Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
  }

  Future<Uint8List> decryptBytes(List<int> encryptedBytes) async {
    if (encryptedBytes.length < 28) {
      throw const FormatException('Encrypted vault file is too short.');
    }
    final key = await _secureKeyService.getOrCreateMasterKey();
    final nonce = encryptedBytes.sublist(0, 12);
    final mac = encryptedBytes.sublist(encryptedBytes.length - 16);
    final cipherText = encryptedBytes.sublist(12, encryptedBytes.length - 16);
    final clearBytes = await _aesGcm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: SecretKey(key),
    );
    return Uint8List.fromList(clearBytes);
  }
}
