import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../../stats/presentation/pages/stats_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool vibration = true;
  bool protection = true;
  bool tips = false;
  double volume = 69;
  TimeOfDay defaultAlarmTime = const TimeOfDay(hour: 7, minute: 0);
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vibration = prefs.getBool('vibration') ?? true;
      protection = prefs.getBool('protection') ?? true;
      tips = prefs.getBool('tips') ?? false;
      volume = prefs.getDouble('default_volume') ?? 69;
      defaultAlarmTime = TimeOfDay(
        hour: prefs.getInt('default_alarm_hour') ?? 7,
        minute: prefs.getInt('default_alarm_minute') ?? 0,
      );
    });
    user = await AuthStorage.getUser();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<void> _pickAlarmTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: defaultAlarmTime,
    );
    if (picked == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_alarm_hour', picked.hour);
    await prefs.setInt('default_alarm_minute', picked.minute);

    setState(() {
      defaultAlarmTime = picked;
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _logout() async {
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  Future<void> _openSystemSettings() async {
    final opened = await NotificationService.instance.openSystemSettings();
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось открыть настройки устройства.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          children: [
            Text(
              'Настройки',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Настройте приложение под себя',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _SettingsBlock(
              title: 'Профиль',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (user?['username'] ?? 'Пользователь').toString(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (user?['email'] ?? 'Email не указан').toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _SettingsBlock(
              title: 'Будильник',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.alarm_rounded,
                      color: AppTheme.primary,
                    ),
                    title: const Text('Время будильника'),
                    subtitle: Text(
                      'Текущее время: ${_formatTime(defaultAlarmTime)}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickAlarmTime,
                  ),
                ],
              ),
            ),
            _SettingsBlock(
              title: 'Звук',
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Громкость',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Text(
                        '${volume.round()}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Slider(
                    value: volume,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() => volume = value);
                      saveDouble('default_volume', value);
                    },
                  ),
                  const SizedBox(height: 6),
                  _SwitchRow(
                    icon: Icons.vibration_outlined,
                    title: 'Вибрация',
                    subtitle: 'Вибрация при срабатывании',
                    value: vibration,
                    onChanged: (value) {
                      setState(() => vibration = value);
                      saveBool('vibration', value);
                    },
                  ),
                ],
              ),
            ),
            _SettingsBlock(
              title: 'Защита',
              child: Column(
                children: [
                  _SwitchRow(
                    icon: Icons.shield_outlined,
                    title: 'Строгий режим',
                    subtitle: 'Запретить быстрое закрытие будильника',
                    value: protection,
                    onChanged: (value) {
                      setState(() => protection = value);
                      saveBool('protection', value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.warning.withValues(alpha: 0.30),
                      ),
                    ),
                    child: const Text(
                      'Защита удерживает экран задания активным и помогает проснуться вовремя.',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _SettingsBlock(
              title: 'Советы по сну',
              child: Column(
                children: const [
                  _AdviceTile(
                    title: 'Ложитесь в одно и то же время',
                    subtitle: 'Стабильный режим улучшает пробуждение.',
                  ),
                  SizedBox(height: 12),
                  _AdviceTile(
                    title: 'Уберите яркий экран за 1 час до сна',
                    subtitle: 'Так мозгу легче перейти в спокойный режим.',
                  ),
                  SizedBox(height: 12),
                  _AdviceTile(
                    title: 'Ставьте будильник чуть раньше',
                    subtitle: 'Небольшой запас времени уменьшает стресс утром.',
                  ),
                ],
              ),
            ),
            _SettingsBlock(
              title: 'Приложение',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.settings_suggest_rounded,
                      color: AppTheme.primary,
                    ),
                    title: const Text('Настройки устройства'),
                    subtitle: const Text(
                      'Открыть настройки приложения на телефоне',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _openSystemSettings,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppTheme.primary,
                    ),
                    title: const Text('Статистика'),
                    subtitle: const Text('Открыть экран статистики'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StatsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _SwitchRow(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Подсказки',
                    subtitle: 'Показывать советы внутри приложения',
                    value: tips,
                    onChanged: (value) {
                      setState(() => tips = value);
                      saveBool('tips', value);
                    },
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: AppTheme.glass(
                colors: [
                  AppTheme.danger.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
                label: const Text(
                  'Выйти из аккаунта',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _AdviceTile extends StatelessWidget {
  const _AdviceTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.cyan.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.nights_stay_outlined,
              color: AppTheme.cyan,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsBlock extends StatelessWidget {
  const _SettingsBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
