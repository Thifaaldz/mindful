import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import 'reminder_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final user = session.user ?? {};
    final className = (user['class'] as Map?)?['name'] as String?;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const BrandHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.mint,
                    backgroundImage: user['avatar_url'] != null
                        ? NetworkImage(user['avatar_url'] as String)
                        : null,
                    child: user['avatar_url'] == null
                        ? const Icon(
                            Icons.person,
                            color: AppTheme.olive,
                            size: 42,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['name'] as String? ?? '-',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] as String? ?? '-',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SoftCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Peran',
                          value: (user['role'] as String? ?? '-').toUpperCase(),
                        ),
                        if (user['school'] != null) ...[
                          const Divider(height: 28),
                          _InfoRow(
                            icon: Icons.school_outlined,
                            label: 'Sekolah',
                            value: user['school'] as String,
                          ),
                        ],
                        if (className != null) ...[
                          const Divider(height: 28),
                          _InfoRow(
                            icon: Icons.class_outlined,
                            label: 'Kelas',
                            value: className,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _ActionCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'Pengingat Harian',
                    subtitle: 'Push notification atau email.',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReminderSettingsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.read<Session>().logout(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.mint,
          child: Icon(icon, color: AppTheme.olive),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.mint,
          child: Icon(icon, color: AppTheme.olive),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
