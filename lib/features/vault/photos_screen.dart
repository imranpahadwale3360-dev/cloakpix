import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/crypto/vault_crypto_service.dart';
import '../../core/database/vault_database.dart';
import '../../core/storage/vault_file_storage.dart';
import '../../shared/models/vault_item.dart';
import '../../shared/widgets/empty_state.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  static const routeName = '/photos';

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final VaultDatabase _database = VaultDatabase();
  final VaultFileStorage _storage = VaultFileStorage();
  final VaultCryptoService _crypto = VaultCryptoService();
  late Future<List<VaultItem>> _items = _database.listVaultItems(type: VaultItemType.photo);

  Future<void> _import() async {
    await _storage.importPhoto();
    setState(() => _items = _database.listVaultItems(type: VaultItemType.photo));
  }

  Future<void> _delete(String id) async {
    await _storage.softDelete(id);
    setState(() => _items = _database.listVaultItems(type: VaultItemType.photo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _import,
        child: const Icon(Icons.add_photo_alternate_outlined),
      ),
      body: FutureBuilder<List<VaultItem>>(
        future: _items,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const EmptyState(title: 'No photos', subtitle: 'Imported photos are encrypted before storage.');
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _EncryptedPhotoTile(
              item: items[index],
              crypto: _crypto,
              onDelete: () => _delete(items[index].id),
            ),
          );
        },
      ),
    );
  }
}

class _EncryptedPhotoTile extends StatelessWidget {
  const _EncryptedPhotoTile({
    required this.item,
    required this.crypto,
    required this.onDelete,
  });

  final VaultItem item;
  final VaultCryptoService crypto;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: crypto.decryptFileToMemory(File(item.encryptedPath)),
      builder: (context, snapshot) {
        final image = snapshot.data;
        return InkWell(
          onLongPress: onDelete,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image == null
                ? const ColoredBox(color: Color(0xFF1B2630), child: Center(child: CircularProgressIndicator()))
                : Image.memory(image, fit: BoxFit.cover, gaplessPlayback: false),
          ),
        );
      },
    );
  }
}
