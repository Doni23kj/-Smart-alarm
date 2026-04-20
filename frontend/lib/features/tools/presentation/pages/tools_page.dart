import 'package:flutter/material.dart';

import '../../../profile/presentation/pages/profile_page.dart';
import '../../../stopwatch/presentation/pages/stopwatch_page.dart';
import '../../../world_clock/presentation/pages/world_clock_page.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key, required this.alarms});

  final List<Map<String, dynamic>> alarms;

  static const _bg = Color(0xFF302B63);
  static const _card = Color(0xFF3B3477);
  static const _cardBorder = Color(0xFF4A4388);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xB3D6D0F0);
  static const _accent = Color(0xFFB15CFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Дополнительно',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          _FeatureCard(
            icon: Icons.public_rounded,
            title: 'Мировые часы',
            subtitle: 'Аналоговые и цифровые часы',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WorldClockPage()));
            },
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.timer_outlined,
            title: 'Секундомер',
            subtitle: 'Старт, пауза, сброс жана круги',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const StopwatchPage()));
            },
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.person_outline_rounded,
            title: 'Профиль',
            subtitle: 'Аккаунт, уруксаттар жана статистика',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProfilePage(alarms: alarms)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ToolsPage._card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ToolsPage._cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220A0716),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: ToolsPage._accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ToolsPage._textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ToolsPage._textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: ToolsPage._textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
