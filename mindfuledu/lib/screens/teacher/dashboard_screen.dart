import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/dashboard_refresh.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/login_history_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final name = (user?['name'] as String?) ?? 'Guru';

    return Scaffold(
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
                    const SizedBox(height: 120),
                    Center(child: Text(message)),
                  ],
                );
              }

              final data = snapshot.data!;
              final summary = _jsonMap(data['summary']);
              final calendar = _jsonMap(data['activity_calendar']);
              final latestAnalysis = _jsonMap(data['latest_analysis']);

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
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ringkasan activity ledger hari ini',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        LastLoginCaption(
                          login: loginHistoryMap(user?['latest_login']),
                          color: AppTheme.olive,
                        ),
                        const SizedBox(height: 20),
                        _HeroStartCard(onTap: () => requestTeacherTab(1)),
                        const SizedBox(height: 28),
                        _StatsRow(summary: summary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SectionTitle(
                    'Kalender Aktivitas',
                    trailing: Text(
                      'Bulan Ini',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _ActivityCalendarCard(calendar: calendar),
                  ),
                  const SizedBox(height: 28),
                  const SectionTitle('Analisis Terakhir'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _LatestAnalysisCard(analysis: latestAnalysis),
                  ),
                  const SizedBox(height: 28),
                  const SectionTitle('Akses Cepat'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        _QuickAccess(
                          icon: Icons.event_note_outlined,
                          label: 'Aktivitas',
                          onTap: () => requestTeacherTab(1),
                        ),
                        _QuickAccess(
                          icon: Icons.insights_outlined,
                          label: 'Analisis',
                          onTap: () => requestTeacherTab(2),
                        ),
                        _QuickAccess(
                          icon: Icons.medical_services_outlined,
                          label: 'Toolkit',
                          onTap: () => requestTeacherTab(3),
                        ),
                        _QuickAccess(
                          icon: Icons.person_outline,
                          label: 'Profil',
                          onTap: () => requestTeacherTab(4),
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

class _HeroStartCard extends StatelessWidget {
  const _HeroStartCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: AppTheme.olive,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.olive.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.add_task, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Text(
                'Tambah Aktivitas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary});

  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final weightedActual = (summary['weighted_actual_hours_today'] as num? ?? 0)
        .toDouble();
    return Row(
      children: [
        Expanded(
          child: MetricTile(
            icon: Icons.event_note_outlined,
            label: 'Planned',
            value: '${summary['planned_activities_today'] ?? 0}',
            caption: 'Activity',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricTile(
            icon: Icons.trending_up,
            label: 'Completed',
            value: '${summary['completed_activities_today'] ?? 0}',
            caption: 'Ledger',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricTile(
            icon: Icons.notifications_active_outlined,
            label: 'WAH',
            value: weightedActual.toStringAsFixed(1),
            caption: 'Jam',
            color: const Color(0xFFD99B3D),
          ),
        ),
      ],
    );
  }
}

class _ActivityCalendarCard extends StatelessWidget {
  const _ActivityCalendarCard({required this.calendar});

  final Map<String, dynamic> calendar;

  @override
  Widget build(BuildContext context) {
    final monthText =
        '${calendar['month'] ?? DateFormat('yyyy-MM').format(DateTime.now())}';
    final month = DateTime.tryParse('$monthText-01') ?? DateTime.now();
    final days = _jsonMap(calendar['days']);
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlank = firstDay.weekday - 1;
    final totalCells = leadingBlank + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final today = DateTime.now();

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.mint,
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppTheme.olive,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(month),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          for (var row = 0; row < rowCount; row++)
            Padding(
              padding: EdgeInsets.only(bottom: row == rowCount - 1 ? 0 : 8),
              child: Row(
                children: List.generate(7, (column) {
                  final cellIndex = row * 7 + column;
                  final dayNumber = cellIndex - leadingBlank + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 42));
                  }

                  final date = DateTime(month.year, month.month, dayNumber);
                  final key = DateFormat('yyyy-MM-dd').format(date);
                  final dayData = _jsonMap(days[key]);
                  final planned = dayData['planned'] as int? ?? 0;
                  final completed = dayData['completed'] as int? ?? 0;
                  final hasPending = dayData['has_pending'] == true;
                  final hasActivity = planned > 0;
                  final color = hasActivity
                      ? hasPending
                            ? const Color(0xFFD99B3D)
                            : AppTheme.olive
                      : AppTheme.line;
                  final selected = _isSameDay(date, today);

                  return Expanded(
                    child: InkWell(
                      onTap: () => requestTeacherActivityDate(date),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 42,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.mint : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? AppTheme.olive : AppTheme.line,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: hasActivity
                                    ? AppTheme.ink
                                    : AppTheme.muted,
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            if (planned > 1)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Text(
                                  '$completed/$planned',
                                  style: const TextStyle(
                                    color: AppTheme.muted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _LatestAnalysisCard extends StatelessWidget {
  const _LatestAnalysisCard({required this.analysis});

  final Map<String, dynamic> analysis;

  @override
  Widget build(BuildContext context) {
    final hasData = analysis.isNotEmpty;
    final category = '${analysis['category'] ?? 'belum ada'}';
    final score = analysis['final_burnout_risk_score'];
    final recommendation = _jsonMap(analysis['recommendation_summary']);
    final color = _analysisColor(category);

    return SoftCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.insights_outlined, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(
                  label: hasData ? category.toUpperCase() : 'BELUM ADA',
                  color: color,
                ),
                const SizedBox(height: 10),
                Text(
                  hasData
                      ? 'Final risk: ${score ?? '-'}'
                      : 'Jalankan analisis setelah ada aktivitas completed.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if ('${recommendation['practice'] ?? ''}'.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${recommendation['practice']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.muted, size: 28),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

Color _analysisColor(String category) {
  return switch (category) {
    'merah' => const Color(0xFFC65A4A),
    'kuning' => const Color(0xFFD99B3D),
    'hijau' => AppTheme.olive,
    _ => AppTheme.muted,
  };
}
