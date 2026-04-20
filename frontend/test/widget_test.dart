import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/presentation/pages/auth_page.dart';

void main() {
  testWidgets('Auth page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Умный\nбудильник'), findsOneWidget);
    expect(find.text('Регистрация'), findsOneWidget);
    expect(find.text('Создать аккаунт'), findsOneWidget);
  });
}
