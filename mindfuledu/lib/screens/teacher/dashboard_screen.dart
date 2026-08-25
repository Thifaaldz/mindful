import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/dashboard_refresh.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';

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
              final trend = _jsonMap(data['calmness_trend']);
              final badges = (data['badges'] as List? ?? []).cast<dynamic>();

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
                          'Ringkasan hari ini',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 26),
                        _HeroStartCard(onTap: () => requestTeacherTab(1)),
                        const SizedBox(height: 28),
                        _StatsRow(summary: summary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const SectionTitle('Tren Ketenangan 7 Hari'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: SoftCard(
                      child: SizedBox(
                        height: 210,
                        child: _CalmnessChart(trend: trend),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SectionTitle(
                    'Pencapaian',
                    trailing: Text(
                      'Lihat Semua',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(
                    height: 74,
                    child: badges.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 28),
                            child: SoftCard(
                              child: Text('Belum ada badge. Terus berlatih!'),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            scrollDirection: Axis.horizontal,
                            itemCount: badges.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final badge = _jsonMap(badges[index]);
                              return _BadgeCard(
                                label: '${badge['name'] ?? 'Badge'}',
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 28),
                  const SectionTitle('Akses Cepat'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        _QuickAccess(
                          icon: Icons.menu_book_outlined,
                          label: 'Logbook',
                          onTap: () => requestTeacherTab(1),
                        ),
                        _QuickAccess(
                          icon: Icons.medical_services_outlined,
                          label: 'Toolkit',
                          onTap: () => requestTeacherTab(3),
                        ),
                        _QuickAccess(
                          icon: Icons.visibility_outlined,
                          label: 'Observasi',
                          onTap: () => requestTeacherTab(2),
                        ),
                        _QuickAccess(
                          icon: Icons.eco_outlined,
                          label: 'Grounding',
                          onTap: () => requestTeacherTab(3),
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
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Text(
                'Mulai Latihan',
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
    final avgAfter = (summary['avg_calmness_after'] as num? ?? 0).toDouble();
    return Row(
      children: [
        Expanded(
          child: MetricTile(
            icon: Icons.event_note_outlined,
            label: 'Total Sesi',
            value: '${summary['total_sessions'] ?? 0}',
            caption: 'Sesi',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricTile(
            icon: Icons.trending_up,
            label: 'Rata-rata',
            value: '${(avgAfter * 10).round()}%',
            caption: 'Baik',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricTile(
            icon: Icons.notifications_active_outlined,
            label: 'Distraksi',
            value: '${summary['avg_distraction_score'] ?? 0}',
            caption: 'Kali',
            color: const Color(0xFFD99B3D),
          ),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFEAF7FF),
              child: Icon(
                Icons.workspace_premium_outlined,
                color: Color(0xFF24718E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
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

class _CalmnessChart extends StatelessWidget {
  const _CalmnessChart({required this.trend});

  final Map<String, dynamic> trend;

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return const Center(child: Text('Belum ada data sesi.'));
    }

    final dates = trend.keys.toList();
    final afterSpots = <FlSpot>[];
    for (var i = 0; i < dates.length; i++) {
      final entry = _jsonMap(trend[dates[i]]);
      afterSpots.add(
        FlSpot(
          i.toDouble(),
          ((entry['calmness_after'] as num? ?? 0) * 10).toDouble(),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppTheme.line, strokeWidth: 1, dashArray: [4, 4]),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 25,
              getTitlesWidget: (value, meta) => Text('${value.round()}%'),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dates.length) {
                  return const SizedBox.shrink();
                }
                return Text(dates[index].substring(5));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: afterSpots,
            isCurved: true,
            color: AppTheme.olive,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.olive.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}
