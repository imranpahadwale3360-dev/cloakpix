import 'dart:io';

import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../crypto/vault_crypto_service.dart';
import '../database/vault_database.dart';
import '../storage/vault_file_storage.dart';
import '../../shared/models/security_event.dart';

class BreakInAlertService {
  BreakInAlertService({
    VaultCryptoService? cryptoService,
    VaultDatabase? database,
    VaultFileStorage? fileStorage,
  })  : _cryptoService = cryptoService ?? VaultCryptoService(),
        _database = database ?? VaultDatabase(),
        _fileStorage = fileStorage ?? VaultFileStorage();

  final VaultCryptoService _cryptoService;
  final VaultDatabase _database;
  final VaultFileStorage _fileStorage;
  final Uuid _uuid = const Uuid();

  Future<void> recordFailedPin({required int failedCount}) async {
    await _database.insertSecurityEvent(
      SecurityEvent(
        id: _uuid.v4(),
        type: SecurityEventType.failedPin,
        createdAt: DateTime.now(),
        message: 'Failed PIN attempt #$failedCount',
      ),
    );

    if (failedCount >= 3) {
      await captureBreakInSelfieIfAllowed();
    }
  }

  Future<void> captureBreakInSelfieIfAllowed() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await _database.insertSecurityEvent(
        SecurityEvent(
          id: _uuid.v4(),
          type: SecurityEventType.breakInPhoto,
          createdAt: DateTime.now(),
          message: 'Break-in selfie skipped because camera permission was unavailable.',
        ),
      );
      return;
    }

    // Android often prevents truly silent camera capture. This foreground-safe
    // skeleton attempts capture only when the platform allows camera startup.
    final cameras = await availableCameras();
    final frontCamera = cameras.where((c) => c.lensDirection == CameraLensDirection.front).firstOrNull;
    if (frontCamera == null) return;

    final controller = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
    try {
      await controller.initialize();
      final image = await controller.takePicture();
      final output = await _fileStorage.securityEventFile('${_uuid.v4()}.cpix');
      await _cryptoService.encryptFile(inputFile: File(image.path), outputFile: output);
      final rawCapture = File(image.path);
      if (await rawCapture.exists()) {
        await rawCapture.delete().catchError((_) => rawCapture);
      }
      await _database.insertSecurityEvent(
        SecurityEvent(
          id: _uuid.v4(),
          type: SecurityEventType.breakInPhoto,
          createdAt: DateTime.now(),
          message: 'Encrypted break-in selfie captured after failed unlock attempts.',
          encryptedMediaPath: output.path,
        ),
      );
    } finally {
      await controller.dispose();
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
