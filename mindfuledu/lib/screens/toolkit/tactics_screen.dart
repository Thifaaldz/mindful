import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';

class TacticsScreen extends StatefulWidget {
  const TacticsScreen({super.key});

  @override
  State<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends State<TacticsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.tactics();
  }

  Future<void> _toggle(Map<String, dynamic> tactic) async {
    try {
      final bookmarked = await Api.toggleBookmark(tactic['id'] as int);
      setState(() => tactic['is_bookmarked'] = bookmarked);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taktik Mindful Lecturing')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Gagal memuat taktik';
            return Center(child: Text(message));
          }

          final tactics = snapshot.data!.cast<Map<String, dynamic>>();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tactics.length,
            itemBuilder: (context, index) {
              final tactic = tactics[index];
              final bookmarked = tactic['is_bookmarked'] as bool;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    tactic['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(tactic['description'] as String),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: bookmarked ? Colors.amber : null,
                    ),
                    onPressed: () => _toggle(tactic),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
