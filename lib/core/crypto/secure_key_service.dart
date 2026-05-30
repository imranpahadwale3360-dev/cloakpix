import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyService {
  SecureKeyService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _masterKeyName = 'cloakpix.master_key.v1';
  static const _databaseKeyName = 'cloakpix.database_key.v1';

  final FlutterSecureStorage _secureStorage;
  final Random _random = Random.secure();

  Future<Uint8List> getOrCreateMasterKey() async {
    return _getOrCreateKey(_masterKeyName, length: 32);
  }

  Future<String> getOrCreateDatabasePassphrase() async {
    final existing = await _secureStorage.read(key: _databaseKeyName);
    if (existing != null) return existing;
    final bytes = _secureRandomBytes(32);
    final passphrase = base64UrlEncode(bytes);
    await _secureStorage.write(key: _databaseKeyName, value: passphrase);
    return passphrase;
  }

  Future<Uint8List> _getOrCreateKey(String name, {required int length}) async {
    final encoded = await _secureStorage.read(key: name);
    if (encoded != null) return base64Url.decode(encoded);

    // Security-sensitive: this key must never be exported or uploaded.
    final key = _secureRandomBytes(length);
    await _secureStorage.write(key: name, value: base64UrlEncode(key));
    return key;
  }

  Uint8List _secureRandomBytes(int length) {
    return Uint8List.fromList(List<int>.generate(length, (_) => _random.nextInt(256)));
  }
}
