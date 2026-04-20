import 'package:flutter/material.dart';

import '../../../../core/storage/alarm_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../alarms/data/datasources/alarm_remote_datasource.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final AlarmRemoteDataSource _alarmRemoteDataSource = AlarmRemoteDataSource();
  int total = 0;
  int active = 0;
  int mathCount = 0;
  int photoCount = 0;
  int memoryCount = 0;
  int logicCount = 0;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final remote = await _alarmRemoteDataSource.getAlarms();
      final decoded = remote.map((alarm) => alarm.toPresentationMap()).toList();
      _applyStats(decoded);
      await AlarmStorage.saveAlarms(decoded);
    } catch (_) {
      final decoded = await AlarmStorage.loadAlarms();
      _applyStats(decoded);
      setState(() {
        _errorText = 'Показаны локальные данные. Сервер временно недоступен.';
      });
    }
  }

  void _applyStats(List<Map<String, dynamic>> decoded) {
    setState(() {
      _errorText = null;
      total = decoded.length;
      active = decoded.where((e) => e['active'] == true).length;
      mathCount = decoded.where((e) => e['task'] == 'Математика').length;
      photoCount = decoded.where((e) => e['task'] == 'Фото').length;
      memoryCount = decoded.where((e) => e['task'] == 'Память').length;
      logicCount = decoded.where((e) => e['task'] == 'Логика').length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final successPercent = total == 0 ? 0 : ((active / total) * 100).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          children: [
            Text(
              'Статистика',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Отслеживайте свои пробуждения',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            if (_errorText != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.glass(),
                child: Text(
                  _errorText!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(22),
              decoration: AppTheme.glass(
                colors: [
                  AppTheme.cyan.withValues(alpha: 0.18),
                  AppTheme.secondary.withValues(alpha: 0.10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Успешные пробуждения',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$successPercent%',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 48),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'доля активных будильников',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Всего',
                  value: '$total',
                  color: AppTheme.primary,
                  icon: Icons.alarm_rounded,
                ),
                _MetricCard(
                  title: 'Активные',
                  value: '$active',
                  color: AppTheme.success,
                  icon: Icons.check_circle_outline_rounded,
                ),
                _MetricCard(
                  title: 'Математика',
                  value: '$mathCount',
                  color: AppTheme.primary,
                  icon: Icons.calculate_outlined,
                ),
                _MetricCard(
                  title: 'Фото',
                  value: '$photoCount',
                  color: AppTheme.warning,
                  icon: Icons.photo_camera_outlined,
                ),
                _MetricCard(
                  title: 'Память',
                  value: '$memoryCount',
                  color: AppTheme.cyan,
                  icon: Icons.psychology_alt_outlined,
                ),
                _MetricCard(
                  title: 'Логика',
                  value: '$logicCount',
                  color: AppTheme.secondary,
                  icon: Icons.extension_rounded,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glass(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Показатели',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _BarRow(
                    label: 'Стабильность',
                    value: successPercent / 100,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _BarRow(
                    label: 'Фото-задания',
                    value: total == 0 ? 0 : photoCount / total,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(height: 12),
                  _BarRow(
                    label: 'Память',
                    value: total == 0 ? 0 : memoryCount / total,
                    color: AppTheme.cyan,
                  ),
                  const SizedBox(height: 12),
                  _BarRow(
                    label: 'Логика',
                    value: total == 0 ? 0 : logicCount / total,
                    color: AppTheme.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.glass(
          colors: [
            color.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value.clamp(0, 1),
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
