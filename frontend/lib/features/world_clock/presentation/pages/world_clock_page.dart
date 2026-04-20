import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/timezone_country_map.dart';

class WorldClockPage extends StatefulWidget {
  const WorldClockPage({super.key});

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage> {
  static const _bg = Color(0xFFF8F6F1);
  static const _card = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF252033);
  static const _textSecondary = Color(0xFF918BA0);
  static const _accent = Color(0xFF4F8CFF);
  static const _purple = Color(0xFF7B61FF);
  static const _border = Color(0xFFE8E2F0);

  late Timer _timer;
  DateTime _now = DateTime.now();
  bool _isLoadingCities = true;
  List<_WorldCity> _allCities = const [];
  final List<_WorldCity> _selectedCities = [];

  @override
  void initState() {
    super.initState();
    _initTimezoneCities();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _initTimezoneCities() async {
    tzdata.initializeTimeZones();
    final generated = _buildCitiesFromTimezones();
    if (!mounted) return;
    setState(() {
      _allCities = generated;
      _isLoadingCities = false;
    });
  }

  List<_WorldCity> _buildCitiesFromTimezones() {
    final keys =
        tz.timeZoneDatabase.locations.keys
            .where(
              (id) =>
                  id.contains('/') &&
                  !id.startsWith('Etc/') &&
                  !id.startsWith('posix/') &&
                  !id.startsWith('right/'),
            )
            .toList()
          ..sort();

    return keys
        .map((id) {
          final parts = id.split('/');
          final region = parts.first;
          final cityRaw = parts.last;
          final city = cityRaw.replaceAll('_', ' ');
          final country =
              kTimezoneToCountry[id] ?? _regionLabels[region] ?? region;
          return _WorldCity(
            timezoneId: id,
            name: city,
            country: country,
            searchIndex: '$city $id $country'.toLowerCase(),
          );
        })
        .toList(growable: false);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _openCityPicker() async {
    if (_isLoadingCities) return;

    final city = await showModalBottomSheet<_WorldCity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _CityPickerSheet(
          selectedCities: _selectedCities,
          allCities: _allCities,
        );
      },
    );

    if (city == null) return;
    if (_selectedCities.any((item) => item.timezoneId == city.timezoneId)) {
      return;
    }
    setState(() => _selectedCities.add(city));
  }

  void _removeCity(_WorldCity city) {
    setState(() => _selectedCities.remove(city));
  }

  tz.TZDateTime _timeInZone(_WorldCity city) {
    final location = tz.getLocation(city.timezoneId);
    return tz.TZDateTime.from(_now, location);
  }

  String _formattedDate(DateTime value) {
    const months = [
      'янв.',
      'фев.',
      'мар.',
      'апр.',
      'мая',
      'июн.',
      'июл.',
      'авг.',
      'сент.',
      'окт.',
      'нояб.',
      'дек.',
    ];
    return '${value.day} ${months[value.month - 1]}';
  }

  String _formatOffset(Duration offset) {
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final absMinutes = totalMinutes.abs();
    final hours = (absMinutes ~/ 60).toString();
    final minutes = (absMinutes % 60).toString().padLeft(2, '0');
    return 'GMT $sign$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final digitalTime = DateFormat('HH:mm:ss').format(_now);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Мировые часы',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  _RoundIconButton(
                    icon: Icons.add_rounded,
                    onTap: _openCityPicker,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x164D3C7A),
                            blurRadius: 30,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _ClockPainter(dateTime: _now),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      digitalTime,
                      style: const TextStyle(
                        fontSize: 34,
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Местное время ${_formattedDate(_now)}',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _isLoadingCities
                      ? const Center(
                          key: ValueKey('loading'),
                          child: CircularProgressIndicator(color: _accent),
                        )
                      : _selectedCities.isEmpty
                      ? const Center(
                          key: ValueKey('empty'),
                          child: Text(
                            'Нет часов',
                            style: TextStyle(color: Color(0xFFB4ADBF)),
                          ),
                        )
                      : ListView.separated(
                          key: const ValueKey('cities'),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _selectedCities.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final city = _selectedCities[index];
                            final cityTime = _timeInZone(city);
                            return _CityClockTile(
                              city: city,
                              time: DateFormat('HH:mm').format(cityTime),
                              subtitle:
                                  '${city.country}  ${_formatOffset(cityTime.timeZoneOffset)}',
                              onDelete: () => _removeCity(city),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _WorldClockPageState._card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _WorldClockPageState._border),
        ),
        child: Icon(icon, color: _WorldClockPageState._textPrimary),
      ),
    );
  }
}

class _CityClockTile extends StatelessWidget {
  const _CityClockTile({
    required this.city,
    required this.time,
    required this.subtitle,
    required this.onDelete,
  });

  final _WorldCity city;
  final String time;
  final String subtitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _WorldClockPageState._card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _WorldClockPageState._border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x104D3C7A),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _WorldClockPageState._purple,
                  _WorldClockPageState._accent,
                ],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.public_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: const TextStyle(
                    color: _WorldClockPageState._textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _WorldClockPageState._textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: _WorldClockPageState._textPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Удалить',
                    style: TextStyle(
                      color: _WorldClockPageState._textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({
    required this.selectedCities,
    required this.allCities,
  });

  final List<_WorldCity> selectedCities;
  final List<_WorldCity> allCities;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  List<_WorldCity> get _filteredCities {
    final value = _query.trim().toLowerCase();
    if (value.isEmpty) return widget.allCities;
    return widget.allCities
        .where((city) => city.searchIndex.contains(value))
        .toList(growable: false);
  }

  String _formatOffset(Duration offset) {
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final absMinutes = totalMinutes.abs();
    final hours = (absMinutes ~/ 60).toString();
    final minutes = (absMinutes % 60).toString().padLeft(2, '0');
    return 'GMT $sign$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final filteredCities = _filteredCities;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: const BoxDecoration(
        color: _WorldClockPageState._bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFDCD5E8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Выберите город',
                        style: TextStyle(
                          color: _WorldClockPageState._textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Часовые пояса • ${widget.allCities.length} городов',
                        style: const TextStyle(
                          color: _WorldClockPageState._textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Поиск страны или города',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                    color: _WorldClockPageState._accent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              itemCount: filteredCities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                final added = widget.selectedCities.any(
                  (item) => item.timezoneId == city.timezoneId,
                );
                final nowInZone = tz.TZDateTime.now(
                  tz.getLocation(city.timezoneId),
                );

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  title: Text(
                    city.name,
                    style: const TextStyle(
                      color: _WorldClockPageState._textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '${city.country}  ${_formatOffset(nowInZone.timeZoneOffset)}',
                    style: const TextStyle(
                      color: _WorldClockPageState._textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: added
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: _WorldClockPageState._purple,
                        )
                      : const Icon(
                          Icons.add_circle_outline_rounded,
                          color: _WorldClockPageState._accent,
                        ),
                  onTap: () => Navigator.pop(context, city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldCity {
  const _WorldCity({
    required this.timezoneId,
    required this.name,
    required this.country,
    required this.searchIndex,
  });

  final String timezoneId;
  final String name;
  final String country;
  final String searchIndex;
}

const _regionLabels = {
  'Africa': 'Африка',
  'America': 'Америка',
  'Antarctica': 'Антарктида',
  'Arctic': 'Арктика',
  'Asia': 'Азия',
  'Atlantic': 'Атлантика',
  'Australia': 'Австралия',
  'Europe': 'Европа',
  'Indian': 'Индийский океан',
  'Pacific': 'Тихий океан',
};

class _ClockPainter extends CustomPainter {
  const _ClockPainter({required this.dateTime});

  final DateTime dateTime;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fillPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = _WorldClockPageState._border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);

    for (var i = 0; i < 60; i++) {
      final angle = (math.pi * 2 * i / 60) - math.pi / 2;
      final isHour = i % 5 == 0;
      final startRadius = radius - (isHour ? 18 : 10);
      final endRadius = radius - 4;
      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = isHour ? const Color(0xFFDAD3EA) : const Color(0xFFECE7F4)
          ..strokeWidth = isHour ? 2 : 1,
      );
    }

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    for (var i = 1; i <= 12; i++) {
      final angle = (math.pi * 2 * i / 12) - math.pi / 2;
      final offset = Offset(
        center.dx + math.cos(angle) * (radius - 34),
        center.dy + math.sin(angle) * (radius - 34),
      );

      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(
          color: _WorldClockPageState._textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    final hourAngle =
        ((dateTime.hour % 12) + dateTime.minute / 60) * math.pi / 6 -
        math.pi / 2;
    final minuteAngle =
        (dateTime.minute + dateTime.second / 60) * math.pi / 30 - math.pi / 2;
    final secondAngle = dateTime.second * math.pi / 30 - math.pi / 2;

    void drawHand({
      required double angle,
      required double length,
      required double width,
      required Color color,
    }) {
      final end = Offset(
        center.dx + math.cos(angle) * length,
        center.dy + math.sin(angle) * length,
      );
      canvas.drawLine(
        center,
        end,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    drawHand(
      angle: hourAngle,
      length: radius * 0.42,
      width: 5,
      color: _WorldClockPageState._textPrimary,
    );
    drawHand(
      angle: minuteAngle,
      length: radius * 0.62,
      width: 4,
      color: _WorldClockPageState._textPrimary,
    );
    drawHand(
      angle: secondAngle,
      length: radius * 0.68,
      width: 2.5,
      color: _WorldClockPageState._accent,
    );

    canvas.drawCircle(center, 6, Paint()..color = _WorldClockPageState._accent);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.dateTime.second != dateTime.second;
  }
}
