import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../widgets/app_chrome.dart';
import 'grounding_screen.dart';
import 'stop_screen.dart';
import 'tactics_screen.dart';

class ToolkitScreen extends StatelessWidget {
  const ToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const BrandHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari toolkit atau taktik...',
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
            const SizedBox(height: 28),
            const SectionTitle('Akses Cepat Saat Dibutuhkan'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  _ToolkitCard(
                    icon: Icons.pan_tool_alt_outlined,
                    color: AppTheme.olive,
                    title: 'Teknik STOP',
                    subtitle:
                        'Berhenti sejenak untuk kembali tenang dan fokus.',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StopScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ToolkitCard(
                    icon: Icons.touch_app_outlined,
                    color: const Color(0xFF24718E),
                    title: 'Grounding 3-2-1',
                    subtitle: 'Kembali ke saat ini dengan hal yang dirasakan.',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GroundingScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ToolkitCard(
                    icon: Icons.school_outlined,
                    color: const Color(0xFF9A623E),
                    title: 'Taktik Mindful Lecturing',
                    subtitle: 'Mengajar dengan hadir penuh dan bermakna.',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TacticsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const SectionTitle('Taktik Favorit'),
            SizedBox(
              height: 158,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                scrollDirection: Axis.horizontal,
                children: const [
                  _FavoriteTactic(
                    icon: Icons.format_list_bulleted,
                    label: 'Single-\nTasking',
                  ),
                  _FavoriteTactic(icon: Icons.schedule, label: 'Tempo Stabil'),
                  _FavoriteTactic(
                    icon: Icons.pause_circle_outline,
                    label: 'Jeda Sengaja',
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

class _ToolkitCard extends StatelessWidget {
  const _ToolkitCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
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
          radius: 32,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _FavoriteTactic extends StatelessWidget {
  const _FavoriteTactic({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      margin: const EdgeInsets.only(right: 14),
      child: SoftCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF0F0EF),
              child: Icon(icon, color: AppTheme.muted, size: 20),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            const Icon(Icons.bookmark, size: 18, color: AppTheme.olive),
          ],
        ),
      ),
    );
  }
}
