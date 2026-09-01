import 'package:flutter/material.dart';

import '../../core/account_role.dart';
import '../../core/dashboard_refresh.dart';
import '../activity/analysis_dashboard_screen.dart';
import '../activity/activity_home_screen.dart';
import '../common/profile_screen.dart';
import '../toolkit/toolkit_screen.dart';
import 'dashboard_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;
  final Set<int> _loadedTabs = {0};

  @override
  void initState() {
    super.initState();
    studentTabRequest.addListener(_handleTabRequest);
  }

  @override
  void dispose() {
    studentTabRequest.removeListener(_handleTabRequest);
    super.dispose();
  }

  void _handleTabRequest() {
    final requestedIndex = studentTabRequest.value;
    if (requestedIndex == null || !mounted) return;
    setState(() {
      _index = requestedIndex;
      _loadedTabs.add(requestedIndex);
    });
    if (requestedIndex == 0) {
      requestDashboardRefresh();
    } else if (requestedIndex == 1) {
      requestActivityRefresh();
    } else if (requestedIndex == 2) {
      requestAnalysisRefresh();
    }
    studentTabRequest.value = null;
  }

  @override
  Widget build(BuildContext context) {
    const role = AccountRole.student;
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: Theme.of(context).navigationBarTheme.copyWith(
          indicatorColor: role.accent.withValues(alpha: 0.34),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? role.primary
                  : const Color(0xFF61635F),
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: List.generate(5, (index) {
            if (!_loadedTabs.contains(index)) {
              return const SizedBox.shrink();
            }

            return _screenFor(index);
          }),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) {
            setState(() {
              _index = i;
              _loadedTabs.add(i);
            });
            if (i == 0) {
              requestDashboardRefresh();
            } else if (i == 1) {
              requestActivityRefresh();
            } else if (i == 2) {
              requestAnalysisRefresh();
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Aktivitas',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Analisis',
            ),
            NavigationDestination(
              icon: Icon(Icons.handyman_outlined),
              selectedIcon: Icon(Icons.handyman),
              label: 'Toolkit',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _screenFor(int index) {
    return switch (index) {
      0 => const StudentDashboardScreen(),
      1 => const ActivityHomeScreen(),
      2 => const AnalysisDashboardScreen(),
      3 => const ToolkitScreen(),
      _ => const ProfileScreen(),
    };
  }
}
