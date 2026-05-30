import 'package:flutter/material.dart';

import '../../core/database/vault_database.dart';
import '../../core/storage/vault_file_storage.dart';
import '../../shared/models/vault_item.dart';
import '../../shared/widgets/empty_state.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  static const routeName = '/trash';

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final VaultDatabase _database = VaultDatabase();
  final VaultFileStorage _storage = VaultFileStorage();
  late Future<List<VaultItem>> _items = _database.listTrash();

  Future<void> _restore(String id) async {
    await _storage.restore(id);
    setState(() => _items = _database.listTrash());
  }

  Future<void> _purgeExpired() async {
    await _storage.purgeExpiredTrash();
    setState(() => _items = _database.listTrash());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          IconButton(
            tooltip: 'Purge expired',
            onPressed: _purgeExpired,
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<VaultItem>>(
        future: _items,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const EmptyState(title: 'Trash is empty', subtitle: 'Deleted encrypted items remain restorable for 30 days.');
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(item.type == VaultItemType.photo ? Icons.photo_outlined : Icons.movie_outlined),
                title: Text(item.originalName),
                subtitle: Text('Deleted ${item.deletedAt}'),
                trailing: IconButton(
                  tooltip: 'Restore',
                  icon: const Icon(Icons.restore_outlined),
                  onPressed: () => _restore(item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
