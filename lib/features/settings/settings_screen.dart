import 'package:flutter/material.dart';

import '../../core/database/vault_database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final VaultDatabase _database = VaultDatabase();
  bool _wifiOnly = true;
  bool _calculatorLabel = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final wifiOnly = await _database.getSetting('wifi_only_sync');
    final calculatorLabel = await _database.getSetting('camouflage_label_calculator');
    setState(() {
      _wifiOnly = wifiOnly != 'false';
      _calculatorLabel = calculatorLabel == 'true';
    });
  }

  Future<void> _setWifiOnly(bool value) async {
    await _database.setSetting('wifi_only_sync', '$value');
    setState(() => _wifiOnly = value);
  }

  Future<void> _setCalculatorLabel(bool value) async {
    await _database.setSetting('camouflage_label_calculator', '$value');
    setState(() => _calculatorLabel = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            value: _wifiOnly,
            onChanged: _setWifiOnly,
            title: const Text('Wi-Fi-only backup'),
            secondary: const Icon(Icons.wifi_outlined),
          ),
          SwitchListTile(
            value: _calculatorLabel,
            onChanged: _setCalculatorLabel,
            title: const Text('Camouflage label option'),
            subtitle: const Text('Stores preference for future Android alias switching.'),
            secondary: const Icon(Icons.calculate_outlined),
          ),
          const ListTile(
            leading: Icon(Icons.key_outlined),
            title: Text('Encryption keys'),
            subtitle: Text('Stored locally with platform secure storage only.'),
          ),
        ],
      ),
    );
  }
}
