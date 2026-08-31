import 'package:flutter/material.dart';

import '../activity/analysis_dashboard_screen.dart';
import '../activity/activity_home_screen.dart';
import '../common/profile_screen.dart';
import '../toolkit/toolkit_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;
  final Set<int> _loadedTabs = {0};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(4, (index) {
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
        },
        destinations: const [
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
    );
  }

  Widget _screenFor(int index) {
    return switch (index) {
      0 => const ActivityHomeScreen(),
      1 => const AnalysisDashboardScreen(),
      2 => const ToolkitScreen(),
      _ => const ProfileScreen(),
    };
  }
}
