import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/reminder_service.dart';
import 'core/session.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_shell.dart';
import 'screens/teacher/teacher_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReminderService.initialize();
  runApp(const MindfulEduApp());
}

class MindfulEduApp extends StatelessWidget {
  const MindfulEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Session()..bootstrap(),
      child: MaterialApp(
        title: 'MindfulEdu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _RootGate(),
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();

    if (session.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!session.isAuthenticated) {
      return const LoginScreen();
    }

    if (session.isTeacher) {
      return const TeacherShell();
    }

    return const StudentShell();
  }
}
