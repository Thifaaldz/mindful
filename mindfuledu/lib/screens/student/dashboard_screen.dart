import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/account_role.dart';
import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/dashboard_refresh.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/login_history_widgets.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.dashboard();
    dashboardRefreshTick.addListener(_reload);
  }

  @override
  void dispose() {
    dashboardRefreshTick.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = Api.dashboard());
  }

  Future<void> _refresh() async {
    _reload();
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<Session>().user;
    final name = (user?['name'] as String?) ?? 'Siswa';
    const role = AccountRole.student;

    return Scaffold(
      backgroundColor: role.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                final message = snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : 'Gagal memuat data';
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const BrandHeader(),
                    const SizedBox(height: 80),
                    Center(child: Text(message)),
                  ],
                );
              }

              final data = snapshot.data ?? <String, dynamic>{};
              final summary = _jsonMap(data['activity_summary']);
              final latestAnalysis = _jsonMap(data['latest_analysis']);
              final category = '${latestAnalysis['category'] ?? ''}';

              return ListView(
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  const BrandHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 4, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $name',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: role.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'EEEE, d MMMM yyyy',
                            'id_ID',
                          ).format(DateTime.now()),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        LastLoginCaption(
                          login: loginHistoryMap(user?['latest_login']),
                          color: role.primary,
                        ),
                        const SizedBox(height: 18),
                        _StudentHeroCard(
                          onActivity: () => requestStudentTab(1),
                          onClassroom: () => requestStudentTab(1),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: MetricTile(
                                icon: Icons.event_available_outlined,
                                label: 'Aktivitas',
                                value: '${summary['planned'] ?? 0}',
                                caption: 'hari ini',
                                color: role.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MetricTile(
                                icon: Icons.task_alt,
                                label: 'Selesai',
                                value: '${summary['completed'] ?? 0}',
                                caption: 'check-out',
                                color: const Color(0xFF24718E),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MetricTile(
                                icon: Icons.spa_outlined,
                                label: 'Status',
                                value: _categoryLabel(category),
                                caption: _conditionLabel(category),
                                color: _categoryColor(category),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _StudentQuickCard(
                          icon: Icons.group_add_outlined,
                          title: 'Cari kelas dari guru',
                          subtitle:
                              'Join aktivitas kelas yang dibuka guru di sekolahmu.',
                          onTap: () => requestStudentTab(1),
                        ),
                        const SizedBox(height: 12),
                        _StudentQuickCard(
                          icon: Icons.insights_outlined,
                          title: 'Lihat analisis',
                          subtitle:
                              'Pantau kondisi belajar berdasarkan jurnal harian.',
                          onTap: () => requestStudentTab(2),
                        ),
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

class _StudentHeroCard extends StatelessWidget {
  const _StudentHeroCard({required this.onActivity, required this.onClassroom});

  final VoidCallback onActivity;
  final VoidCallback onClassroom;

  @override
  Widget build(BuildContext context) {
    const role = AccountRole.student;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: role.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: role.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Tambah aktivitas belajar atau masuk kelas yang dibuka guru.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              FilledButton.tonalIcon(
                onPressed: onActivity,
                icon: const Icon(Icons.add_task),
                label: const Text('Aktivitas'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onClassroom,
                icon: const Icon(Icons.groups_outlined),
                label: const Text('Kelas'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentQuickCard extends StatelessWidget {
  const _StudentQuickCard({
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
    const role = AccountRole.student;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: role.accent.withValues(alpha: 0.35),
          child: Icon(icon, color: role.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return <String, dynamic>{};
}

String _conditionLabel(String category) {
  return switch (category) {
    'hijau' => 'Stabil',
    'kuning' => 'Perlu jeda',
    'merah' => 'Butuh dukungan',
    _ => 'Belum ada',
  };
}

String _categoryLabel(String category) {
  return switch (category) {
    'hijau' => 'Hijau',
    'kuning' => 'Kuning',
    'merah' => 'Merah',
    _ => 'Belum',
  };
}

Color _categoryColor(String category) {
  return switch (category) {
    'hijau' => const Color(0xFF3E735B),
    'kuning' => const Color(0xFFE0A22F),
    'merah' => const Color(0xFFC65A4A),
    _ => AccountRole.student.primary,
  };
}
