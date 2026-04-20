import 'package:flutter/material.dart';

import '../alarms/presentation/pages/home_page.dart';
import '../profile/presentation/pages/profile_page.dart';
import '../stopwatch/presentation/pages/stopwatch_page.dart';
import '../timer/presentation/pages/timer_page.dart';
import '../world_clock/presentation/pages/world_clock_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _index = 0;

  static const _bg = Color(0xFFF8F6F1);
  static const _nav = Color(0xFFFFFFFF);
  static const _accent = Color(0xFF6E63F6);
  static const _textSecondary = Color(0xFF9A95A8);

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomePage(),
      WorldClockPage(),
      StopwatchPage(),
      TimerPage(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: _nav,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A4D3C7A),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: NavigationBar(
            height: 72,
            selectedIndex: _index,
            backgroundColor: Colors.transparent,
            indicatorColor: _accent.withValues(alpha: 0.12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (value) {
              if (value == _index) return;
              setState(() => _index = value);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.alarm_outlined, color: _textSecondary),
                selectedIcon: Icon(Icons.alarm_rounded, color: _accent),
                label: 'Будильник',
              ),
              NavigationDestination(
                icon: Icon(Icons.public_rounded, color: _textSecondary),
                selectedIcon: Icon(Icons.public_rounded, color: _accent),
                label: 'Часы',
              ),
              NavigationDestination(
                icon: Icon(Icons.timer_outlined, color: _textSecondary),
                selectedIcon: Icon(Icons.timer_rounded, color: _accent),
                label: 'Секунд.',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.hourglass_empty_rounded,
                  color: _textSecondary,
                ),
                selectedIcon: Icon(
                  Icons.hourglass_bottom_rounded,
                  color: _accent,
                ),
                label: 'Таймер',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: _textSecondary),
                selectedIcon: Icon(Icons.person_rounded, color: _accent),
                label: 'Профиль',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
