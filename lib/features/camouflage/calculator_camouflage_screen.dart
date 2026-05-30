import 'package:flutter/material.dart';

import '../../core/security/pin_service.dart';
import '../auth/pin_lock_screen.dart';
import '../onboarding/onboarding_screen.dart';

class PhoneLockCamouflageScreen extends StatefulWidget {
  const PhoneLockCamouflageScreen({super.key});

  static const routeName = '/';

  @override
  State<PhoneLockCamouflageScreen> createState() => _PhoneLockCamouflageScreenState();
}

class _PhoneLockCamouflageScreenState extends State<PhoneLockCamouflageScreen> {
  final PinService _pinService = PinService();
  String _status = 'Device lock is ready';
  bool _armed = false;

  Future<void> _openHiddenVault() async {
    final hasPin = await _pinService.hasPin();
    if (!mounted) return;
    await Navigator.of(context).pushNamed(hasPin ? PinLockScreen.routeName : OnboardingScreen.routeName);
  }

  void _fakeLock() {
    setState(() {
      _armed = true;
      _status = 'Screen lock simulation enabled';
    });
  }

  void _fakeUnlock() {
    setState(() {
      _armed = false;
      _status = 'Device lock is ready';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B0D),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF111C22), Color(0xFF070B0D)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF17252B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF294049)),
                      ),
                      child: const Icon(Icons.lock_outline, color: Color(0xFFD7E6E8)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Phone Lock',
                        style: TextStyle(
                          color: Color(0xFFEAF7F5),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: GestureDetector(
                    onLongPress: _openHiddenVault,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 178,
                      height: 178,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _armed ? const Color(0xFF0EA5A4) : const Color(0xFF132126),
                        border: Border.all(
                          color: _armed ? const Color(0xFFBDF3EF) : const Color(0xFF294049),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_armed ? const Color(0xFF0EA5A4) : Colors.black).withOpacity(0.28),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Icon(
                        _armed ? Icons.lock : Icons.lock_open_outlined,
                        size: 74,
                        color: _armed ? const Color(0xFF031111) : const Color(0xFFD7E6E8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFEAF7F5),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _armed
                      ? 'Tap unlock to disable the protection overlay.'
                      : 'Tap lock to activate the protection overlay.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF9FB2B7),
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _armed ? _fakeUnlock : _fakeLock,
                  icon: Icon(_armed ? Icons.lock_open_outlined : Icons.lock_outline),
                  label: Text(_armed ? 'Unlock Screen' : 'Lock Screen'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _status = 'No threats detected'),
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('Run Lock Check'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
