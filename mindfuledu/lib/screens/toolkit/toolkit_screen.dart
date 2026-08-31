import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../widgets/app_chrome.dart';
import '../activity/kabat_zinn_practice_screen.dart';

class ToolkitScreen extends StatefulWidget {
  const ToolkitScreen({super.key});

  @override
  State<ToolkitScreen> createState() => _ToolkitScreenState();
}

class _ToolkitScreenState extends State<ToolkitScreen> {
  late Future<List<dynamic>> _future;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = Api.tactics();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _future = Api.tactics());
    await _future;
  }

  Future<void> _toggle(Map<String, dynamic> tactic) async {
    try {
      final bookmarked = await Api.toggleBookmark(tactic['id'] as int);
      if (!mounted) return;
      setState(() => tactic['is_bookmarked'] = bookmarked);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _open(Map<String, dynamic> tactic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KabatZinnPracticeScreen(
          snapshot: {
            'source': 'toolkit',
            'category': 'toolkit',
            'practice_code': tactic['category'],
            'recommendation_summary': {
              'practice_code': tactic['category'],
              'practice_title': tactic['title'],
              'practice': tactic['description'],
            },
            'tactic': tactic,
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> tactics) {
    if (_query.isEmpty) return tactics;

    return tactics.where((tactic) {
      final bestFor = (tactic['best_for'] as List? ?? []).join(' ');
      final text = [
        tactic['title'],
        tactic['description'],
        tactic['knowledge'],
        bestFor,
      ].join(' ').toLowerCase();

      return text.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                final message = snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : 'Gagal memuat tools mindfulness';
                return ListView(
                  padding: const EdgeInsets.all(28),
                  children: [
                    const BrandHeader(),
                    SoftCard(child: Text(message)),
                  ],
                );
              }

              final tactics = snapshot.data!.cast<Map<String, dynamic>>();
              final filtered = _filter(tactics);
              final favorites = tactics
                  .where((item) => item['is_bookmarked'] == true)
                  .take(5)
                  .toList();

              return ListView(
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  const BrandHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari teknik mindfulness...',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: const Color(0xFFF0F0EF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (favorites.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const SectionTitle('Favorit'),
                    SizedBox(
                      height: 148,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        scrollDirection: Axis.horizontal,
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final tactic = favorites[index];
                          return _FavoriteTactic(
                            icon: _iconFor('${tactic['category']}'),
                            label: '${tactic['title']}',
                            onTap: () => _open(tactic),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  const SectionTitle('Tools Mindfulness'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        if (filtered.isEmpty)
                          const SoftCard(
                            child: Text('Teknik yang dicari belum ditemukan.'),
                          )
                        else
                          for (final tactic in filtered) ...[
                            _ToolkitCard(
                              icon: _iconFor('${tactic['category']}'),
                              color: _colorFor('${tactic['category']}'),
                              title: '${tactic['title']}',
                              subtitle: '${tactic['description']}',
                              duration:
                                  '${tactic['duration_minutes'] ?? 3} menit',
                              bookmarked: tactic['is_bookmarked'] == true,
                              onBookmark: () => _toggle(tactic),
                              onTap: () => _open(tactic),
                            ),
                            const SizedBox(height: 14),
                          ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ToolkitCard extends StatelessWidget {
  const _ToolkitCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.bookmarked,
    required this.onBookmark,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String duration;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: color),
                  const SizedBox(width: 5),
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: IconButton(
          tooltip: bookmarked ? 'Hapus favorit' : 'Tambah favorit',
          icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
          color: bookmarked ? AppTheme.olive : AppTheme.muted,
          onPressed: onBookmark,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _FavoriteTactic extends StatelessWidget {
  const _FavoriteTactic({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 126,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SoftCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF0F0EF),
                  child: Icon(icon, color: AppTheme.olive, size: 21),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(String code) {
  return switch (code) {
    'stop_technique' => Icons.pan_tool_alt_outlined,
    'grounding_321' => Icons.touch_app_outlined,
    'breathing_478' => Icons.air,
    'breathing_space_3min' => Icons.hourglass_bottom,
    'maintain_breath_awareness' => Icons.spa_outlined,
    'sitting_meditation' => Icons.self_improvement,
    'body_scan_micro' || 'body_scan_full' => Icons.accessibility_new,
    'mindful_movement' => Icons.accessibility,
    'walking_meditation' => Icons.directions_walk,
    'rain_self_compassion' => Icons.umbrella_outlined,
    'loving_kindness' => Icons.favorite_border,
    'reflective_journal' => Icons.edit_note,
    _ => Icons.lightbulb_outline,
  };
}

Color _colorFor(String code) {
  return switch (code) {
    'grounding_321' => const Color(0xFF24718E),
    'breathing_478' || 'breathing_space_3min' => const Color(0xFF3B7C61),
    'body_scan_micro' || 'body_scan_full' => const Color(0xFF6A6E3D),
    'mindful_movement' || 'walking_meditation' => const Color(0xFF8D6B32),
    'rain_self_compassion' || 'loving_kindness' => const Color(0xFF9A4F64),
    'reflective_journal' => const Color(0xFF5A6B8C),
    _ => AppTheme.olive,
  };
}
