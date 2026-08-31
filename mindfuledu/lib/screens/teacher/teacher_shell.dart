import 'package:flutter/material.dart';

import '../../core/dashboard_refresh.dart';
import '../activity/analysis_dashboard_screen.dart';
import '../activity/activity_home_screen.dart';
import '../common/profile_screen.dart';
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
  final Set<int> _loadedTabs = {0};

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
    setState(() {
      _index = requestedIndex;
      _loadedTabs.add(requestedIndex);
    });
    if (requestedIndex == 1) {
      requestActivityRefresh();
    } else if (requestedIndex == 2) {
      requestAnalysisRefresh();
    }
    teacherTabRequest.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _screenFor(int index) {
    return switch (index) {
      0 => DashboardScreen(key: ValueKey(_dashboardVersion)),
      1 => const ActivityHomeScreen(),
      2 => const AnalysisDashboardScreen(),
      3 => const ToolkitScreen(),
      _ => const ProfileScreen(),
    };
  }
}
