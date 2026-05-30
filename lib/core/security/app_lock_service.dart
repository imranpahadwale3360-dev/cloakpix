import 'package:flutter/widgets.dart';

class AppLockService with WidgetsBindingObserver {
  AppLockService({required this.onLockRequired});

  final VoidCallback onLockRequired;
  bool _isLocked = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  bool get isLocked => _isLocked;

  void markUnlocked() {
    _isLocked = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isLocked = true;
      onLockRequired();
    }
  }
}
