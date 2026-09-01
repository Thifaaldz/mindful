import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/account_role.dart';
import 'core/app_theme.dart';
import 'core/reminder_service.dart';
import 'core/session.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_completion_screen.dart';
import 'screens/parent/parent_shell.dart';
import 'screens/student/student_shell.dart';
import 'screens/teacher/teacher_shell.dart';
import 'widgets/app_chrome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _safeStartupInitialize();
  runApp(const MindfulEduApp());
}

Future<void> _safeStartupInitialize() async {
  try {
    await initializeDateFormatting('id_ID').timeout(const Duration(seconds: 3));
  } catch (_) {
    // The app can still render with fallback date formatting.
  }

  unawaited(
    ReminderService.initialize()
        .timeout(const Duration(seconds: 5))
        .catchError((_) {}),
  );
}

class MindfulEduApp extends StatelessWidget {
  const MindfulEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Session()..bootstrap(),
      child: Consumer<Session>(
        builder: (context, session, _) => MaterialApp(
          title: 'MindfulEdu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.forRole(AccountRole.byId(session.role)),
          home: const _RootGate(),
        ),
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
      return const SplashScreen();
    }

    if (!session.isAuthenticated) {
      return const LoginScreen();
    }

    if (session.needsProfileCompletion) {
      return const ProfileCompletionScreen();
    }

    if (session.isTeacher) {
      return const TeacherShell();
    }

    if (session.isParent) {
      return const ParentShell();
    }

    return const StudentShell();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const BrandMark(size: 92, radius: 24, iconSize: 46),
              const SizedBox(height: 24),
              Text(
                'MindfulEdu',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Semakin jujur Anda mencatat, semakin berguna sistem ini.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              const Spacer(),
              Text(
                'Activity Ledger - Check-in - Analisis Burnout',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
