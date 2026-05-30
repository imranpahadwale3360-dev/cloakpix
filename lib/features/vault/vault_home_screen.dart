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
    return Scaffold(
      backgroundColor: const Color(0xFF071013),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF182B30), Color(0xFF071013), Color(0xFF241A18)],
            ),
          ),
          child: Stack(
            children: [
              const _VaultBackground(),
              ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                children: [
                  const _TopStatusBar(),
                  const SizedBox(height: 18),
                  const _BrandHeader(),
                  const SizedBox(height: 22),
                  const _SecurityBadge(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassAction(
                          title: 'Photos',
                          subtitle: 'Private gallery',
                          icon: Icons.photo_library_outlined,
                          route: PhotosScreen.routeName,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _GlassAction(
                          title: 'Videos',
                          subtitle: 'Encrypted clips',
                          icon: Icons.play_arrow_rounded,
                          route: VideosScreen.routeName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassAction(
                          title: 'Trash',
                          subtitle: '30 day restore',
                          icon: Icons.delete_outline,
                          route: TrashScreen.routeName,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _GlassAction(
                          title: 'Cloud',
                          subtitle: 'Encrypted backup',
                          icon: Icons.cloud_upload_outlined,
                          route: BackupStatusScreen.routeName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _BottomPill(
                          title: 'Shield',
                          icon: Icons.shield_outlined,
                          route: SecurityAlertsScreen.routeName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BottomPill(
                          title: 'Settings',
                          icon: Icons.settings_outlined,
                          route: SettingsScreen.routeName,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopStatusBar extends StatelessWidget {
  const _TopStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Text(
        'PREMIUM SECURITY ACTIVE',
        style: TextStyle(
          color: Color(0xFFC9D6D8),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'CloakPix',
            style: TextStyle(
              color: Color(0xFFEAF2F3),
              fontSize: 36,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A2E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6C7B7E).withOpacity(0.45)),
          ),
          child: const Icon(Icons.photo_camera_back_outlined, color: Color(0xFFDDE8E9)),
        ),
      ],
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.30),
            const Color(0xFF20363B).withOpacity(0.82),
            const Color(0xFF0B1518).withOpacity(0.94),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF50D8D2).withOpacity(0.20),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.enhanced_encryption_outlined, size: 46, color: Color(0xFFE8F3F4)),
          const SizedBox(height: 12),
          Text(
            'VAULT SECURED',
            style: TextStyle(
              color: const Color(0xFFEAF2F3).withOpacity(0.82),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Encrypted',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 38,
              fontWeight: FontWeight.w300,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'FILES PROTECTED',
            style: TextStyle(
              color: Color(0xFFB8C8CB),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassAction extends StatelessWidget {
  const _GlassAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        height: 154,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF23383D).withOpacity(0.84),
              const Color(0xFF091214).withOpacity(0.90),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.34),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1B2A2E),
                border: Border.all(color: const Color(0xFFC7D6D8).withOpacity(0.28)),
              ),
              child: Icon(icon, color: const Color(0xFFE8F3F4), size: 30),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFEAF2F3),
                fontSize: 24,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF91A7AB), fontSize: 12, letterSpacing: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPill extends StatelessWidget {
  const _BottomPill({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: const Color(0xFF0D191B).withOpacity(0.92),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1B2A2E),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Icon(icon, color: const Color(0xFFE8F3F4), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFEAF2F3),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultBackground extends StatelessWidget {
  const _VaultBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _VaultBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _VaultBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.50);
    final cyan = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF67E8E3).withOpacity(0.18);
    final copper = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = const Color(0xFFD79A74).withOpacity(0.16);
    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.06);

    for (var i = 0; i < 7; i++) {
      final radius = 58.0 + (i * 38);
      canvas.drawCircle(center, radius, i.isEven ? cyan : copper);
    }

    final path = Path()
      ..moveTo(-20, size.height * 0.27)
      ..quadraticBezierTo(size.width * 0.42, size.height * 0.18, size.width + 24, size.height * 0.04);
    canvas.drawPath(path, copper);

    final secondPath = Path()
      ..moveTo(0, size.height * 0.74)
      ..cubicTo(size.width * 0.24, size.height * 0.58, size.width * 0.70, size.height * 0.94, size.width, size.height * 0.70);
    canvas.drawPath(secondPath, cyan);

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(Offset(size.width * (0.16 + i * 0.18), size.height * 0.78), 34 + i * 7, soft);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
