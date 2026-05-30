import 'package:flutter/material.dart';

import '../../core/sync/cloud_sync_service.dart';
import '../../core/sync/sync_worker.dart';

class BackupStatusScreen extends StatefulWidget {
  const BackupStatusScreen({super.key});

  static const routeName = '/backup';

  @override
  State<BackupStatusScreen> createState() => _BackupStatusScreenState();
}

class _BackupStatusScreenState extends State<BackupStatusScreen> {
  final CloudSyncService _syncService = CloudSyncService();
  final SyncWorker _syncWorker = SyncWorker();
  String _status = 'Idle';

  Future<void> _syncNow() async {
    setState(() => _status = 'Syncing encrypted files...');
    await _syncService.uploadEncryptedVaultItems();
    setState(() => _status = 'Encrypted backup complete');
  }

  Future<void> _registerBackgroundSync() async {
    await _syncWorker.registerPeriodicSync();
    setState(() => _status = 'Background sync registered');
  }

  Future<void> _restorePreview() async {
    final items = await _syncService.listRemoteRestoreCandidates();
    setState(() => _status = 'Restore candidates: ${items.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_done_outlined),
            title: const Text('Status'),
            subtitle: Text(_status),
          ),
          FilledButton.icon(
            onPressed: _syncNow,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Sync encrypted files'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _registerBackgroundSync,
            icon: const Icon(Icons.schedule_outlined),
            label: const Text('Enable background sync'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _restorePreview,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Check restore candidates'),
          ),
        ],
      ),
    );
  }
}
