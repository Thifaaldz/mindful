import 'package:flutter/material.dart';

import '../../core/dashboard_refresh.dart';
import '../common/profile_screen.dart';
import 'parent_dashboard_screen.dart';

class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int _index = 0;
  final Set<int> _loadedTabs = {0};

  @override
  void initState() {
    super.initState();
    parentTabRequest.addListener(_handleTabRequest);
  }

  @override
  void dispose() {
    parentTabRequest.removeListener(_handleTabRequest);
    super.dispose();
  }

  void _handleTabRequest() {
    final requestedIndex = parentTabRequest.value;
    if (requestedIndex == null || !mounted) return;
    setState(() {
      _index = requestedIndex;
      _loadedTabs.add(requestedIndex);
    });
    parentTabRequest.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(2, (index) {
          if (!_loadedTabs.contains(index)) {
            return const SizedBox.shrink();
          }

          return index == 0
              ? const ParentDashboardScreen()
              : const ProfileScreen();
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
            icon: Icon(Icons.family_restroom_outlined),
            selectedIcon: Icon(Icons.family_restroom),
            label: 'Anak',
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
