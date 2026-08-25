// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mindfuledu/core/session.dart';
import 'package:mindfuledu/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen renders when unauthenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Session(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('MindfulEdu'), findsOneWidget);
    expect(find.text('Belum punya akun? Daftar'), findsOneWidget);
  });
}
