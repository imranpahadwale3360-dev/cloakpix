import 'package:flutter/material.dart';

import '../alerts/security_alerts_screen.dart';
import '../backup/backup_status_screen.dart';
import '../settings/settings_screen.dart';
import '../trash/trash_screen.dart';
import 'photos_screen.dart';
import 'videos_screen.dart';

class VaultHomeScreen extends StatelessWidget {
  const VaultHomeScreen({super.key});

  static const routeName = '/vault';

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _Destination('Photos', Icons.photo_library_outlined, PhotosScreen.routeName),
      _Destination('Videos', Icons.video_library_outlined, VideosScreen.routeName),
      _Destination('Trash', Icons.delete_outline, TrashScreen.routeName),
      _Destination('Backup', Icons.cloud_upload_outlined, BackupStatusScreen.routeName),
      _Destination('Alerts', Icons.security_outlined, SecurityAlertsScreen.routeName),
      _Destination('Settings', Icons.settings_outlined, SettingsScreen.routeName),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('CloakPix')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(context).pushNamed(destination.route),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(destination.icon, size: 40),
                  const SizedBox(height: 12),
                  Text(destination.title),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Destination {
  const _Destination(this.title, this.icon, this.route);
  final String title;
  final IconData icon;
  final String route;
}
