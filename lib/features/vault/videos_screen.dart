import 'package:flutter/material.dart';

import '../../core/database/vault_database.dart';
import '../../core/storage/vault_file_storage.dart';
import '../../shared/models/vault_item.dart';
import '../../shared/widgets/empty_state.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  static const routeName = '/videos';

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final VaultDatabase _database = VaultDatabase();
  final VaultFileStorage _storage = VaultFileStorage();
  late Future<List<VaultItem>> _items = _database.listVaultItems(type: VaultItemType.video);

  Future<void> _import() async {
    await _storage.importVideo();
    setState(() => _items = _database.listVaultItems(type: VaultItemType.video));
  }

  Future<void> _delete(String id) async {
    await _storage.softDelete(id);
    setState(() => _items = _database.listVaultItems(type: VaultItemType.video));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _import,
        child: const Icon(Icons.video_call_outlined),
      ),
      body: FutureBuilder<List<VaultItem>>(
        future: _items,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const EmptyState(title: 'No videos', subtitle: 'Imported videos are encrypted in app-private storage.');
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: const Icon(Icons.movie_outlined),
                title: Text(item.originalName),
                subtitle: Text('${item.sizeBytes} encrypted bytes'),
                trailing: IconButton(
                  tooltip: 'Move to trash',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
