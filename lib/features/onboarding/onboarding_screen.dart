import 'package:flutter/material.dart';

import '../../core/security/pin_service.dart';
import '../vault/vault_home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PinService _pinService = PinService();
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  Future<void> _save() async {
    try {
      await _pinService.setPin(_pinController.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(VaultHomeScreen.routeName, (_) => false);
    } catch (error) {
      setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create a private vault PIN', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 12,
              decoration: InputDecoration(
                labelText: 'PIN',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _save, child: const Text('Create Vault')),
          ],
        ),
      ),
    );
  }
}
