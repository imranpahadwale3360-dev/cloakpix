import 'package:flutter/material.dart';

import '../../core/database/vault_database.dart';
import '../../shared/models/security_event.dart';
import '../../shared/widgets/empty_state.dart';

class SecurityAlertsScreen extends StatefulWidget {
  const SecurityAlertsScreen({super.key});

  static const routeName = '/alerts';

  @override
  State<SecurityAlertsScreen> createState() => _SecurityAlertsScreenState();
}

class _SecurityAlertsScreenState extends State<SecurityAlertsScreen> {
  final VaultDatabase _database = VaultDatabase();
  late Future<List<SecurityEvent>> _events = _database.listSecurityEvents();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Alerts')),
      body: FutureBuilder<List<SecurityEvent>>(
        future: _events,
        builder: (context, snapshot) {
          final events = snapshot.data ?? const [];
          if (events.isEmpty) {
            return const EmptyState(title: 'No alerts', subtitle: 'Failed unlocks and break-in captures appear here.');
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _events = _database.listSecurityEvents()),
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  leading: Icon(event.type == SecurityEventType.breakInPhoto
                      ? Icons.camera_front_outlined
                      : Icons.warning_amber_outlined),
                  title: Text(event.message),
                  subtitle: Text(event.createdAt.toLocal().toString()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
