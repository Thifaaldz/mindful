import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/mindful_avatar.dart';
import 'logbook_history_screen.dart';
import 'session_guide_screen.dart';

class MindfulnessHomeScreen extends StatefulWidget {
  const MindfulnessHomeScreen({super.key});

  @override
  State<MindfulnessHomeScreen> createState() => _MindfulnessHomeScreenState();
}

class _MindfulnessHomeScreenState extends State<MindfulnessHomeScreen> {
  bool _starting = false;

  Future<void> _startSession() async {
    setState(() => _starting = true);
    try {
      final session = await Api.startSession();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionGuideScreen(sessionId: session['id'] as int),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            BrandHeader(
              trailing: IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LogbookHistoryScreen(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
              child: Column(
                children: [
                  const MindfulAvatar(assetName: 'avatar_home.png', size: 210),
                  const SizedBox(height: 26),
                  Text(
                    'Latihan Mindfulness',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ikuti sesi mindfulness 7 langkah untuk menenangkan pikiran sebelum atau setelah mengajar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _starting ? null : _startSession,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_starting ? 'Memulai...' : 'Mulai Latihan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
