import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../data/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.alarms = const []});

  final List<Map<String, dynamic>> alarms;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _bg = Color(0xFFF8F6F1);
  static const _card = Color(0xFFFFFFFF);
  static const _cardBorder = Color(0xFFE8E2F0);
  static const _textPrimary = Color(0xFF2B2540);
  static const _textSecondary = Color(0xFF8F879E);
  static const _accent = Color(0xFF7B61FF);
  static const _cyan = Color(0xFF4F8CFF);
  static const _danger = Color(0xFFE66A86);
  static const _warning = Color(0xFFE7B06A);

  Map<String, dynamic>? _user;
  bool _notificationAllowed = true;
  bool _loadingPermission = true;
  bool _savingProfile = false;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final localUser = await AuthStorage.getUser();
    Map<String, dynamic>? user = localUser;
    try {
      user = await _profileService.getProfile();
      await AuthStorage.saveUser(user);
    } catch (_) {
      user = localUser;
    }
    final notificationAllowed = await NotificationService.instance
        .hasNotificationPermission();
    if (!mounted) return;
    setState(() {
      _user = user;
      _notificationAllowed = notificationAllowed;
      _loadingPermission = false;
    });
  }

  Future<void> _requestNotifications() async {
    setState(() => _loadingPermission = true);
    final allowed = await NotificationService.instance
        .requestNotificationPermissions();
    if (!mounted) return;
    setState(() {
      _notificationAllowed = allowed;
      _loadingPermission = false;
    });
  }

  Future<void> _openSystemSettings() async {
    final opened = await NotificationService.instance.openSystemSettings();
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось открыть настройки устройства.')),
    );
  }

  Future<void> _logout() async {
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  String _initials() {
    final username = (_user?['username'] ?? 'U').toString().trim();
    if (username.isEmpty) return 'U';
    return username.substring(0, 1).toUpperCase();
  }

  ImageProvider<Object>? _avatarProvider() {
    final avatar = (_user?['avatar'] ?? '').toString().trim();
    if (avatar.isEmpty) return null;
    if (avatar.startsWith('data:image')) {
      final commaIndex = avatar.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(avatar.substring(commaIndex + 1));
          return MemoryImage(bytes);
        } catch (_) {
          return null;
        }
      }
    }
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return NetworkImage(avatar);
    }
    return null;
  }

  Future<void> _openEditProfile() async {
    final usernameController = TextEditingController(
      text: (_user?['username'] ?? '').toString(),
    );
    final emailController = TextEditingController(
      text: (_user?['email'] ?? '').toString(),
    );
    final phoneController = TextEditingController(
      text: (_user?['phone'] ?? '').toString(),
    );

    String avatarValue = (_user?['avatar'] ?? '').toString();
    Uint8List? avatarPreview;

    if (avatarValue.startsWith('data:image')) {
      final commaIndex = avatarValue.indexOf(',');
      if (commaIndex != -1) {
        try {
          avatarPreview = base64Decode(avatarValue.substring(commaIndex + 1));
        } catch (_) {}
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickAvatar() async {
              final picker = ImagePicker();
              final file = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 72,
                maxWidth: 900,
              );
              if (file == null) return;
              final bytes = await file.readAsBytes();
              setModalState(() {
                avatarPreview = bytes;
                avatarValue = 'data:image/jpeg;base64,${base64Encode(bytes)}';
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _cardBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: pickAvatar,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: _accent.withValues(alpha: 0.14),
                        backgroundImage: avatarPreview != null
                            ? MemoryImage(avatarPreview!)
                            : _avatarProvider(),
                        child:
                            avatarPreview == null && _avatarProvider() == null
                            ? Text(
                                _initials(),
                                style: const TextStyle(
                                  color: _accent,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Изменить профиль',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _EditField(
                      controller: usernameController,
                      icon: Icons.person_outline_rounded,
                      hint: 'Имя пользователя',
                    ),
                    const SizedBox(height: 10),
                    _EditField(
                      controller: emailController,
                      icon: Icons.email_outlined,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    _EditField(
                      controller: phoneController,
                      icon: Icons.phone_outlined,
                      hint: 'Телефон',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileActionButton(
                            label: 'Отмена',
                            color: _cardBorder,
                            textColor: _textPrimary,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ProfileActionButton(
                            label: _savingProfile ? 'Сохр...' : 'Сохранить',
                            color: _accent,
                            textColor: Colors.white,
                            onTap: _savingProfile
                                ? () {}
                                : () async {
                                    final username = usernameController.text
                                        .trim();
                                    final email = emailController.text.trim();
                                    if (username.isEmpty || email.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Имя и email должны быть заполнены',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _savingProfile = true);
                                    try {
                                      final updated = await _profileService
                                          .updateProfile(
                                            username: username,
                                            email: email,
                                            phone: phoneController.text.trim(),
                                            avatar: avatarValue,
                                          );
                                      await AuthStorage.saveUser(updated);
                                      if (!mounted || !context.mounted) return;
                                      setState(() => _user = updated);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        this.context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Профиль обновлён'),
                                        ),
                                      );
                                    } catch (error) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        this.context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('$error')),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _savingProfile = false);
                                      }
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _activeCount() {
    return widget.alarms.where((alarm) => alarm['active'] == true).length;
  }

  String _favoriteTask() {
    final counts = <String, int>{};
    for (final alarm in widget.alarms) {
      final task = (alarm['task'] ?? 'Математика').toString();
      counts[task] = (counts[task] ?? 0) + 1;
    }
    if (counts.isEmpty) return 'Пока нет';
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: const Text(
          'Профиль',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            top: -90,
            right: -70,
            child: _SoftGlow(size: 220, color: Color(0x227B61FF)),
          ),
          const Positioned(
            bottom: 40,
            left: -90,
            child: _SoftGlow(size: 240, color: Color(0x224F8CFF)),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 132,
            ),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF3EEFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _cardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x184D3C7A),
                      blurRadius: 18,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8FE7FF), _accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: ClipOval(
                            child: _avatarProvider() != null
                                ? Image(
                                    image: _avatarProvider()!,
                                    width: 66,
                                    height: 66,
                                    fit: BoxFit.cover,
                                  )
                                : Text(
                                    _initials(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (_user?['username'] ?? 'Пользователь')
                                    .toString(),
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                (_user?['email'] ?? 'Email не указан')
                                    .toString(),
                                style: const TextStyle(
                                  color: _textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _openEditProfile,
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatTile(
                            title: 'Будильники',
                            value: '${widget.alarms.length}',
                            color: _accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStatTile(
                            title: 'Активные',
                            value: '${_activeCount()}',
                            color: _cyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _PermissionStatusPill(
                allowed: _notificationAllowed,
                loading: _loadingPermission,
                onTap: _notificationAllowed
                    ? _openSystemSettings
                    : _requestNotifications,
              ),
              const SizedBox(height: 10),
              if (_loadingPermission)
                const _PermissionLoadingCard()
              else if (!_notificationAllowed)
                _PermissionAlertCard(
                  onRequest: _requestNotifications,
                  onOpenSettings: _openSystemSettings,
                ),
              if (!_notificationAllowed || _loadingPermission)
                const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Личные данные',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ProfileTile(
                icon: Icons.person_outline_rounded,
                label: 'Имя пользователя',
                value: (_user?['username'] ?? 'Не указано').toString(),
              ),
              const SizedBox(height: 10),
              _ProfileTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: (_user?['email'] ?? 'Не указано').toString(),
              ),
              const SizedBox(height: 10),
              _ProfileTile(
                icon: Icons.phone_outlined,
                label: 'Телефон',
                value: (_user?['phone'] ?? 'Не указано').toString(),
              ),
              const SizedBox(height: 10),
              _ProfileTile(
                icon: Icons.auto_awesome_rounded,
                label: 'Любимый тип задачи',
                value: _favoriteTask(),
              ),
              const SizedBox(height: 16),
              _ProfileActionButton(
                label: 'Редактировать профиль',
                color: _accent,
                textColor: Colors.white,
                onTap: _openEditProfile,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _danger.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _danger.withValues(alpha: 0.35)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Выйти из аккаунта',
                    style: TextStyle(
                      color: _danger,
                      fontSize: 15,
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

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _PermissionLoadingCard extends StatelessWidget {
  const _PermissionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ProfilePageState._card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ProfilePageState._cardBorder),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Проверяем доступ к уведомлениям...',
              style: TextStyle(color: _ProfilePageState._textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionAlertCard extends StatelessWidget {
  const _PermissionAlertCard({
    required this.onRequest,
    required this.onOpenSettings,
  });

  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ProfilePageState._warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _ProfilePageState._warning.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_off_rounded,
                color: _ProfilePageState._warning,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Уведомления отключены',
                  style: TextStyle(
                    color: _ProfilePageState._textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Без разрешения на уведомления будильник может не сработать. Включите доступ и дайте приложению право показывать звук и баннеры.',
            style: TextStyle(
              color: _ProfilePageState._textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProfileActionButton(
                  label: 'Разрешить',
                  color: _ProfilePageState._warning,
                  textColor: _ProfilePageState._textPrimary,
                  onTap: onRequest,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileActionButton(
                  label: 'Настройки',
                  color: _ProfilePageState._accent,
                  textColor: Colors.white,
                  onTap: onOpenSettings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionStatusPill extends StatelessWidget {
  const _PermissionStatusPill({
    required this.allowed,
    required this.loading,
    required this.onTap,
  });

  final bool allowed;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = allowed
        ? _ProfilePageState._cyan
        : _ProfilePageState._warning;
    final label = loading
        ? 'Проверяем уведомления...'
        : allowed
        ? 'Уведомления включены'
        : 'Нужно включить уведомления';

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Row(
          children: [
            Icon(
              allowed
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _ProfilePageState._textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _ProfilePageState._textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  const _MiniStatTile({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _ProfilePageState._textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _ProfilePageState._textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ProfilePageState._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ProfilePageState._cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _ProfilePageState._accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _ProfilePageState._accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _ProfilePageState._textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Не указано' : value,
                  style: const TextStyle(
                    color: _ProfilePageState._textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _ProfilePageState._accent),
        filled: true,
        fillColor: _ProfilePageState._bg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _ProfilePageState._cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _ProfilePageState._accent),
        ),
      ),
    );
  }
}
