import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  PinService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _pinSaltKey = 'cloakpix.pin_salt.v1';
  static const _pinHashKey = 'cloakpix.pin_hash.v1';
  static const _failedCountKey = 'cloakpix.failed_pin_count.v1';
  static const int _iterations = 120000;

  final FlutterSecureStorage _secureStorage;
  final Random _random = Random.secure();

  Future<bool> hasPin() async => (await _secureStorage.read(key: _pinHashKey)) != null;

  Future<void> setPin(String pin) async {
    _validatePin(pin);
    final salt = _randomBytes(16);
    final hash = _deriveHash(pin, salt);
    await _secureStorage.write(key: _pinSaltKey, value: base64UrlEncode(salt));
    await _secureStorage.write(key: _pinHashKey, value: base64UrlEncode(hash));
    await resetFailedAttempts();
  }

  Future<bool> verifyPin(String pin, {bool countFailure = false}) async {
    final saltValue = await _secureStorage.read(key: _pinSaltKey);
    final hashValue = await _secureStorage.read(key: _pinHashKey);
    if (saltValue == null || hashValue == null) return false;

    // Security-sensitive: compare derived hashes without ever storing raw PINs.
    final candidate = _deriveHash(pin, base64Url.decode(saltValue));
    final expected = base64Url.decode(hashValue);
    final isValid = _constantTimeEquals(candidate, expected);
    if (isValid) {
      await resetFailedAttempts();
    } else if (countFailure) {
      await incrementFailedAttempts();
    }
    return isValid;
  }

  Future<int> failedAttempts() async {
    final value = await _secureStorage.read(key: _failedCountKey);
    return int.tryParse(value ?? '0') ?? 0;
  }

  Future<int> incrementFailedAttempts() async {
    final count = (await failedAttempts()) + 1;
    await _secureStorage.write(key: _failedCountKey, value: '$count');
    return count;
  }

  Future<void> resetFailedAttempts() async {
    await _secureStorage.write(key: _failedCountKey, value: '0');
  }

  Uint8List _deriveHash(String pin, List<int> salt) {
    var output = Uint8List.fromList([...utf8.encode(pin), ...salt]);
    for (var i = 0; i < _iterations; i++) {
      output = Uint8List.fromList(sha256.convert([...output, ...salt]).bytes);
    }
    return output;
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(List<int>.generate(length, (_) => _random.nextInt(256)));
  }

  void _validatePin(String pin) {
    if (pin.length < 4 || pin.length > 12 || int.tryParse(pin) == null) {
      throw ArgumentError('PIN must be 4 to 12 digits.');
    }
  }
}
