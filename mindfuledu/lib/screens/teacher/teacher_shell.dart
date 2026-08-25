import 'package:flutter/material.dart';

import '../../core/dashboard_refresh.dart';
import '../common/profile_screen.dart';
import '../mindfulness/mindfulness_home_screen.dart';
import '../observation/observation_home_screen.dart';
import '../toolkit/toolkit_screen.dart';
import 'dashboard_screen.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int _index = 0;
  int _dashboardVersion = 0;

  @override
  void initState() {
    super.initState();
    dashboardRefreshTick.addListener(_rebuildDashboard);
    teacherTabRequest.addListener(_handleTabRequest);
  }

  @override
  void dispose() {
    dashboardRefreshTick.removeListener(_rebuildDashboard);
    teacherTabRequest.removeListener(_handleTabRequest);
    super.dispose();
  }

  void _rebuildDashboard() {
    if (!mounted) return;
    setState(() => _dashboardVersion++);
  }

  void _handleTabRequest() {
    final requestedIndex = teacherTabRequest.value;
    if (requestedIndex == null || !mounted) return;
    setState(() => _index = requestedIndex);
    teacherTabRequest.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(key: ValueKey(_dashboardVersion)),
      const MindfulnessHomeScreen(),
      const ObservationHomeScreen(),
      const ToolkitScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          if (i == 0) {
            requestDashboardRefresh();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: 'Latihan',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Observasi',
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
}
