import 'package:flutter/material.dart';

import '../../core/security/biometric_service.dart';
import '../../core/security/break_in_alert_service.dart';
import '../../core/security/pin_service.dart';
import '../vault/vault_home_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  static const routeName = '/pin-lock';

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final PinService _pinService = PinService();
  final BiometricService _biometricService = BiometricService();
  final BreakInAlertService _breakInAlertService = BreakInAlertService();
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  Future<void> _unlock() async {
    final valid = await _pinService.verifyPin(_pinController.text, countFailure: true);
    if (valid) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(VaultHomeScreen.routeName, (_) => false);
      return;
    }
    final failed = await _pinService.failedAttempts();
    await _breakInAlertService.recordFailedPin(failedCount: failed);
    setState(() => _error = 'Incorrect PIN. Failed attempts: $failed');
  }

  Future<void> _biometricUnlock() async {
    if (await _biometricService.authenticate()) {
      await _pinService.resetFailedAttempts();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(VaultHomeScreen.routeName, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'PIN',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _unlock(),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _unlock, child: const Text('Unlock')),
            TextButton(onPressed: _biometricUnlock, child: const Text('Use biometric unlock')),
          ],
        ),
      ),
    );
  }
}
