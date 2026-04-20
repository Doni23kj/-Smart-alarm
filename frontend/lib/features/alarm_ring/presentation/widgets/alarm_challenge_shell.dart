import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/alarm_audio_service.dart';

class AlarmChallengeShell extends StatefulWidget {
  const AlarmChallengeShell({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.ringVolume = 0.8,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final double ringVolume;

  static const backgroundTop = Color(0xFF261D4B);
  static const backgroundBottom = Color(0xFF151026);
  static const card = Color(0xFF2C2350);
  static const cardSoft = Color(0xFF392D67);
  static const border = Color(0xFF53427F);
  static const accent = Color(0xFF8D5CFF);
  static const success = Color(0xFF33D17A);
  static const muted = Color(0xFFA79CC9);

  @override
  State<AlarmChallengeShell> createState() => _AlarmChallengeShellState();
}

class _AlarmChallengeShellState extends State<AlarmChallengeShell> {
  @override
  void initState() {
    super.initState();
    unawaited(AlarmAudioService.instance.start(volume: widget.ringVolume));
  }

  @override
  void dispose() {
    unawaited(AlarmAudioService.instance.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AlarmChallengeShell.backgroundBottom,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AlarmChallengeShell.backgroundTop,
                AlarmChallengeShell.backgroundBottom,
              ],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -80,
                right: -30,
                child: _GlowOrb(size: 190, color: Color(0x448D5CFF)),
              ),
              const Positioned(
                bottom: 90,
                left: -50,
                child: _GlowOrb(size: 160, color: Color(0x2233D17A)),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.94, end: 1),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      builder: (context, value, cardChild) {
                        return Transform.scale(scale: value, child: cardChild);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AlarmChallengeShell.card,
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(color: AlarmChallengeShell.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x330B0816),
                              blurRadius: 34,
                              offset: Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: AlarmChallengeShell.accent.withValues(
                                  alpha: 0.16,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x338D5CFF),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AlarmChallengeShell.muted,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 24),
                            widget.child,
                          ],
                        ),
                      ),
                    ),
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

class AlarmChallengeField extends StatelessWidget {
  const AlarmChallengeField({
    super.key,
    required this.controller,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AlarmChallengeShell.muted),
        errorText: errorText,
        errorStyle: const TextStyle(color: Color(0xFFFF9CB7)),
        filled: true,
        fillColor: AlarmChallengeShell.cardSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AlarmChallengeShell.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AlarmChallengeShell.accent),
        ),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

class AlarmChallengeButton extends StatefulWidget {
  const AlarmChallengeButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<AlarmChallengeButton> createState() => _AlarmChallengeButtonState();
}

class _AlarmChallengeButtonState extends State<AlarmChallengeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.985 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AlarmChallengeShell.success,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4433D17A),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class ChallengeClockBadge extends StatelessWidget {
  const ChallengeClockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final label =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white70),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
