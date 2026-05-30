import 'package:flutter/material.dart';

import 'features/alerts/security_alerts_screen.dart';
import 'features/auth/pin_lock_screen.dart';
import 'features/backup/backup_status_screen.dart';
import 'features/camouflage/calculator_camouflage_screen.dart';
import 'features/camouflage/phone_lock_camouflage_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/trash/trash_screen.dart';
import 'features/vault/photos_screen.dart';
import 'features/vault/vault_home_screen.dart';
import 'features/vault/videos_screen.dart';

class CloakPixApp extends StatefulWidget {
  const CloakPixApp({super.key});

  @override
  State<CloakPixApp> createState() => _CloakPixAppState();
}

class _CloakPixAppState extends State<CloakPixApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _lockRequired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _lockRequired = true;
    }
    if (state == AppLifecycleState.resumed && _lockRequired) {
      _lockRequired = false;
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;
      navigator.pushNamedAndRemoveUntil(PhoneLockCamouflageScreen.routeName, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Phone Lock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5A4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071013),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF071013),
          foregroundColor: Color(0xFFEAF7F5),
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF102024),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0EA5A4),
            foregroundColor: const Color(0xFF031111),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: PhoneLockCamouflageScreen.routeName,
      routes: {
        PhoneLockCamouflageScreen.routeName: (_) => const PhoneLockCamouflageScreen(),
        CalculatorCamouflageScreen.routeName: (_) => const CalculatorCamouflageScreen(),
        PinLockScreen.routeName: (_) => const PinLockScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        VaultHomeScreen.routeName: (_) => const VaultHomeScreen(),
        PhotosScreen.routeName: (_) => const PhotosScreen(),
        VideosScreen.routeName: (_) => const VideosScreen(),
        TrashScreen.routeName: (_) => const TrashScreen(),
        BackupStatusScreen.routeName: (_) => const BackupStatusScreen(),
        SecurityAlertsScreen.routeName: (_) => const SecurityAlertsScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
