import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/reminder_service.dart';
import 'core/session.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_completion_screen.dart';
import 'screens/student/student_shell.dart';
import 'screens/teacher/teacher_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
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
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppTheme.mint,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.olive.withValues(alpha: 0.16),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: AppTheme.olive,
                  size: 46,
                ),
              ),
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
