import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_navigator.dart';
import 'core/services/alarm_runtime_service.dart';
import 'core/services/notification_service.dart';
import 'core/storage/auth_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/navigation/main_navigation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();
  await NotificationService.instance.requestNotificationPermissions();

  runApp(const ProviderScope(child: SmartAlarmApp()));
}

class SmartAlarmApp extends StatefulWidget {
  const SmartAlarmApp({super.key});

  @override
  State<SmartAlarmApp> createState() => _SmartAlarmAppState();
}

class _SmartAlarmAppState extends State<SmartAlarmApp> {
  @override
  void initState() {
    super.initState();
    AlarmRuntimeService.instance.start();
    NotificationService.instance.openChallengeFromLaunchPayload();
  }

  @override
  void dispose() {
    AlarmRuntimeService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppNavigator.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Smart Alarm',
      theme: AppTheme.lightTheme(),
      home: const _AppEntryPoint(),
    );
  }
}

class _AppEntryPoint extends StatelessWidget {
  const _AppEntryPoint();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthStorage.getToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if ((snapshot.data ?? '').isNotEmpty) {
          return const MainNavigationPage();
        }

        return const AuthPage();
      },
    );
  }
}
