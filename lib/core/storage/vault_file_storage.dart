import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../crypto/vault_crypto_service.dart';
import '../database/vault_database.dart';
import '../../shared/models/vault_item.dart';

class VaultFileStorage {
  VaultFileStorage({
    VaultCryptoService? cryptoService,
    VaultDatabase? database,
    ImagePicker? imagePicker,
  })  : _cryptoService = cryptoService ?? VaultCryptoService(),
        _database = database ?? VaultDatabase(),
        _imagePicker = imagePicker ?? ImagePicker();

  final VaultCryptoService _cryptoService;
  final VaultDatabase _database;
  final ImagePicker _imagePicker;
  final Uuid _uuid = const Uuid();

  Future<Directory> _vaultDirectory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(p.join(root.path, 'encrypted_vault'));
    return directory.create(recursive: true);
  }

  Future<File> securityEventFile(String fileName) async {
    final root = await getApplicationSupportDirectory();
    final directory = await Directory(p.join(root.path, 'security_events')).create(recursive: true);
    return File(p.join(directory.path, fileName));
  }

  Future<VaultItem?> importPhoto() => _pickAndEncrypt(ImageSource.gallery, VaultItemType.photo);

  Future<VaultItem?> importVideo() => _pickAndEncrypt(ImageSource.gallery, VaultItemType.video);

  Future<VaultItem?> _pickAndEncrypt(ImageSource source, VaultItemType type) async {
    final picked = type == VaultItemType.photo
        ? await _imagePicker.pickImage(source: source)
        : await _imagePicker.pickVideo(source: source);
    if (picked == null) return null;

    final input = File(picked.path);
    final id = _uuid.v4();
    final vaultDirectory = await _vaultDirectory();
    final encryptedFile = File(p.join(vaultDirectory.path, '$id.cpix'));

    // Security-sensitive: encrypt before saving into the vault; plaintext picker
    // cache files are deleted best-effort immediately after encryption.
    await _cryptoService.encryptFile(inputFile: input, outputFile: encryptedFile);
    if (await input.exists()) {
      await input.delete().catchError((_) => input);
    }

    final item = VaultItem(
      id: id,
      type: type,
      encryptedPath: encryptedFile.path,
      originalName: picked.name,
      createdAt: DateTime.now(),
      mimeType: picked.mimeType,
      sizeBytes: await encryptedFile.length(),
    );
    await _database.upsertVaultItem(item);
    return item;
  }

  Future<void> purgeExpiredTrash() async {
    final expired = await _database.expiredTrash();
    for (final item in expired) {
      final encryptedFile = File(item.encryptedPath);
      if (await encryptedFile.exists()) {
        await encryptedFile.delete().catchError((_) => encryptedFile);
      }
      await _database.removeItemRecord(item.id);
    }
  }

  Future<void> softDelete(String id) => _database.softDeleteItem(id);

  Future<void> restore(String id) => _database.restoreItem(id);
}
