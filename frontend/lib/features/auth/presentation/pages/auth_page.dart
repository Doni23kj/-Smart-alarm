import 'package:flutter/material.dart';

import '../../../navigation/main_navigation_page.dart';
import '../../data/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  static const _bgTop = Color(0xFFF8F6F1);
  static const _bgBottom = Color(0xFFF2EEFB);
  static const _card = Color(0xFFFFFFFF);
  static const _cardSoft = Color(0xFFF5F1FF);
  static const _cardBorder = Color(0xFFE7DFF4);
  static const _accent = Color(0xFF6E63F6);
  static const _textPrimary = Color(0xFF2B2540);
  static const _textSecondary = Color(0xFF8F879E);
  static const _dangerBg = Color(0x33E66A86);
  static const _danger = Color(0xFFE66A86);

  final _registerFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();
  final _registerUsername = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPhone = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirmPassword = TextEditingController();
  final _loginUsername = TextEditingController();
  final _loginPassword = TextEditingController();

  bool _isRegister = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _registerUsername.dispose();
    _registerEmail.dispose();
    _registerPhone.dispose();
    _registerPassword.dispose();
    _registerConfirmPassword.dispose();
    _loginUsername.dispose();
    _loginPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _isRegister
        ? _registerFormKey.currentState
        : _loginFormKey.currentState;
    if (form?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      if (_isRegister) {
        await AuthService.instance.register(
          username: _registerUsername.text.trim(),
          email: _registerEmail.text.trim(),
          phone: _registerPhone.text.trim(),
          password: _registerPassword.text.trim(),
          confirmPassword: _registerConfirmPassword.text.trim(),
        );
      } else {
        await AuthService.instance.login(
          login: _loginUsername.text.trim(),
          password: _loginPassword.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationPage()),
        (route) => false,
      );
    } catch (error) {
      setState(() {
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) return 'Заполните поле';
        if (hint == 'Электронная почта' && !(value!.contains('@'))) {
          return 'Введите корректную почту';
        }
        if (hint == 'Телефон' &&
            value!.trim().isNotEmpty &&
            value.trim().length < 6) {
          return 'Введите корректный номер';
        }
        if (hint == 'Пароль' && value!.trim().length < 6) {
          return 'Минимум 6 символов';
        }
        if (hint == 'Подтвердите пароль' &&
            value!.trim() != _registerPassword.text.trim()) {
          return 'Пароли не совпадают';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary),
        prefixIcon: icon == null ? null : Icon(icon, color: _accent),
        filled: true,
        fillColor: _cardSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _danger),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -40,
              child: _GlowOrb(size: 220, color: Color(0x226E63F6)),
            ),
            const Positioned(
              bottom: 120,
              left: -50,
              child: _GlowOrb(size: 180, color: Color(0x224F8CFF)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8EDBFF), _accent],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x336E63F6),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.alarm_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Умный\nбудильник',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        height: 0.92,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Регистрация и вход работают нормально. После успешного входа сразу откроется главный экран.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: _cardBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x184D3C7A),
                            blurRadius: 28,
                            offset: Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _cardSoft,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _cardBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ToggleChip(
                                    label: 'Регистрация',
                                    active: _isRegister,
                                    onTap: () {
                                      setState(() => _isRegister = true);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: _ToggleChip(
                                    label: 'Вход',
                                    active: !_isRegister,
                                    onTap: () {
                                      setState(() => _isRegister = false);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isRegister ? 'Создать аккаунт' : 'Войти в аккаунт',
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isRegister
                                ? 'Введите логин, почту, телефон и пароль.'
                                : 'Введите email или имя пользователя и пароль.',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Form(
                            key: _isRegister ? _registerFormKey : _loginFormKey,
                            child: Column(
                              children: [
                                if (_isRegister) ...[
                                  _field(
                                    controller: _registerUsername,
                                    hint: 'Имя пользователя',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 12),
                                  _field(
                                    controller: _registerEmail,
                                    hint: 'Электронная почта',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 12),
                                  _field(
                                    controller: _registerPhone,
                                    hint: 'Телефон',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 12),
                                  _field(
                                    controller: _registerPassword,
                                    hint: 'Пароль',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: true,
                                  ),
                                  const SizedBox(height: 12),
                                  _field(
                                    controller: _registerConfirmPassword,
                                    hint: 'Подтвердите пароль',
                                    icon: Icons.lock_reset_rounded,
                                    obscure: true,
                                  ),
                                ] else ...[
                                  _field(
                                    controller: _loginUsername,
                                    hint: 'Email или имя пользователя',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 12),
                                  _field(
                                    controller: _loginPassword,
                                    hint: 'Пароль',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _dangerBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _danger.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                _errorText!,
                                style: const TextStyle(
                                  color: _danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          _ActionButton(
                            onTap: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isRegister
                                        ? 'Зарегистрироваться'
                                        : 'Войти',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                          if (!_isRegister) ...[
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Забыл пароль',
                                style: TextStyle(color: _accent, fontSize: 13),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF8EDBFF), _AuthPageState._accent],
                )
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x336E63F6),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : _AuthPageState._textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.onTap == null
                  ? const [Color(0xFFA39AC3), Color(0xFF958DB7)]
                  : const [Color(0xFF8EDBFF), _AuthPageState._accent],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: widget.onTap == null
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x336E63F6),
                      blurRadius: 22,
                      offset: Offset(0, 12),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.child,
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
