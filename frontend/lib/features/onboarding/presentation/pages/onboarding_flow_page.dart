import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/layout/main_layout.dart';
import '../widgets/onboarding_next_button.dart';

class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({super.key});

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  String _selectedGoal = 'Рано вставать';
  String _selectedHealth = 'Нормально';
  final Set<String> _selectedReasons = {'Работа'};
  int _selectedAge = 24;
  int _selectedHour = 7;
  int _selectedMinute = 30;

  static const _goals = [
    'Рано вставать',
    'Лучше высыпаться',
    'Не опаздывать',
    'Улучшить режим',
    'Быть продуктивнее',
    'Просыпаться без стресса',
  ];

  static const _healthStates = [
    'Отлично',
    'Нормально',
    'Часто устаю',
    'Сложно просыпаться',
    'Плохой режим сна',
  ];

  static const _reasons = [
    ('Работа', Icons.work_outline_rounded),
    ('Учёба', Icons.menu_book_rounded),
    ('Спорт', Icons.fitness_center_rounded),
    ('Семья', Icons.favorite_border_rounded),
    ('Саморазвитие', Icons.auto_awesome_outlined),
    ('Здоровье', Icons.health_and_safety_outlined),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageIndex >= 4) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _sectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 30),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  BoxDecoration _selectedDecoration() {
    return BoxDecoration(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFFF8A1E), width: 1.2),
      boxShadow: const [
        BoxShadow(color: Color(0x44FF8A1E), blurRadius: 22, spreadRadius: 2),
      ],
    );
  }

  BoxDecoration _baseCardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0B0B0B),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF202020)),
    );
  }

  Widget _buildGoalsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Goals',
          subtitle:
              'Выберите главную цель, ради которой вы хотите изменить утро.',
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              final selected = _selectedGoal == goal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      _selectedGoal = goal;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: selected
                        ? _selectedDecoration()
                        : _baseCardDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selected
                              ? const Color(0xFFFF8A1E)
                              : const Color(0xFF666666),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHealthPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Health',
          subtitle:
              'Оцените своё текущее состояние, чтобы приложение подстроило опыт.',
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _healthStates.length,
            itemBuilder: (context, index) {
              final item = _healthStates[index];
              final selected = _selectedHealth == item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      _selectedHealth = item;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: selected
                        ? _selectedDecoration()
                        : _baseCardDecoration(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          color: selected
                              ? const Color(0xFFFF8A1E)
                              : const Color(0xFF7D7D7D),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReasonsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Reasons',
          subtitle:
              'Почему вам важно просыпаться вовремя? Можно выбрать несколько.',
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            itemCount: _reasons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.06,
            ),
            itemBuilder: (context, index) {
              final (label, icon) = _reasons[index];
              final selected = _selectedReasons.contains(label);

              return InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedReasons.remove(label);
                    } else {
                      _selectedReasons.add(label);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: selected
                      ? _selectedDecoration()
                      : _baseCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0x22FF8A1E)
                              : const Color(0xFF171717),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: selected
                              ? const Color(0xFFFF8A1E)
                              : Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selected ? 'Выбрано' : 'Нажмите для выбора',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgePage() {
    final ages = List<int>.generate(83, (index) => index + 18);
    final selectedIndex = ages.indexOf(_selectedAge).clamp(0, ages.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Возраст',
          subtitle:
              'Выберите ваш возраст. Прокрутка сделана плавной, как в нативном picker.',
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: _baseCardDecoration(),
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: selectedIndex,
              ),
              itemExtent: 54,
              diameterRatio: 1.2,
              magnification: 1.08,
              useMagnifier: true,
              backgroundColor: Colors.transparent,
              selectionOverlay: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x22FFFFFF)),
                  color: const Color(0x11FFFFFF),
                ),
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedAge = ages[index];
                });
              },
              children: ages.map((age) {
                final active = age == _selectedAge;
                return Center(
                  child: Text(
                    '$age',
                    style: TextStyle(
                      fontSize: active ? 30 : 24,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? Colors.white : const Color(0xFF8A8A8A),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePage() {
    final hours = List<int>.generate(24, (index) => index);
    final minutes = List<int>.generate(60, (index) => index);

    Widget wheel({
      required List<int> items,
      required int selectedValue,
      required ValueChanged<int> onChanged,
    }) {
      return Expanded(
        child: Container(
          decoration: _baseCardDecoration(),
          child: CupertinoPicker(
            itemExtent: 58,
            diameterRatio: 1.15,
            magnification: 1.08,
            useMagnifier: true,
            backgroundColor: Colors.transparent,
            scrollController: FixedExtentScrollController(
              initialItem: selectedValue,
            ),
            selectionOverlay: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: const Color(0x11FFFFFF),
                border: Border.all(color: const Color(0x22FFFFFF)),
              ),
            ),
            onSelectedItemChanged: onChanged,
            children: items.map((value) {
              final active = value == selectedValue;
              return Center(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: active ? 32 : 24,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : const Color(0xFF848484),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Время',
          subtitle:
              'Выберите удобное время пробуждения в тёмном кастомном стиле.',
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            wheel(
              items: hours,
              selectedValue: _selectedHour,
              onChanged: (index) {
                setState(() {
                  _selectedHour = hours[index];
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                ':',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            wheel(
              items: minutes,
              selectedValue: _selectedMinute,
              onChanged: (index) {
                setState(() {
                  _selectedMinute = minutes[index];
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: _selectedDecoration(),
          child: Column(
            children: [
              Text('Вы выбрали', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 36),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildGoalsPage(),
      _buildHealthPage(),
      _buildReasonsPage(),
      _buildAgePage(),
      _buildTimePage(),
    ];

    return MainLayout(
      progress: (_pageIndex + 1) / pages.length,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                children: pages,
              ),
            ),
            const SizedBox(height: 12),
            OnboardingNextButton(
              label: _pageIndex == pages.length - 1 ? 'Готово' : 'Следующее',
              onPressed: _nextPage,
            ),
          ],
        ),
      ),
    );
  }
}
