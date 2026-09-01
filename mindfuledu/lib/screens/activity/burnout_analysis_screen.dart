import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/dashboard_refresh.dart';
import '../../widgets/app_chrome.dart';
import 'kabat_zinn_practice_screen.dart';

class BurnoutAnalysisScreen extends StatefulWidget {
  const BurnoutAnalysisScreen({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  State<BurnoutAnalysisScreen> createState() => _BurnoutAnalysisScreenState();
}

class _BurnoutAnalysisScreenState extends State<BurnoutAnalysisScreen> {
  late DateTime _date;
  String _period = 'daily';
  bool _loading = false;
  bool _hasAnalysis = false;
  Map<String, dynamic>? _snapshot;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _run() async {
    setState(() => _loading = true);
    try {
      final snapshot = await Api.createBurnoutAnalysis(
        periodType: _period,
        date: DateFormat('yyyy-MM-dd').format(_date),
      );
      if (mounted) {
        requestDashboardRefresh();
        requestAnalysisRefresh();
        setState(() {
          _snapshot = snapshot;
          _hasAnalysis = true;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _close() => Navigator.of(context).pop(_hasAnalysis);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: _close,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Analisis Burnout'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Form Analisis',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PeriodChip(
                        label: 'Harian',
                        value: 'daily',
                        selected: _period,
                        onSelected: (v) => setState(() => _period = v),
                      ),
                      _PeriodChip(
                        label: 'Mingguan',
                        value: 'weekly',
                        selected: _period,
                        onSelected: (v) => setState(() => _period = v),
                      ),
                      _PeriodChip(
                        label: 'Bulanan',
                        value: 'monthly',
                        selected: _period,
                        onSelected: (v) => setState(() => _period = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      DateFormat('d MMMM yyyy', 'id_ID').format(_date),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _loading ? null : _run,
                    icon: const Icon(Icons.insights),
                    label: Text(
                      _loading ? 'Menganalisis...' : 'Jalankan Analisis',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_snapshot == null)
              const _GuidanceCard()
            else
              _AnalysisResult(snapshot: _snapshot!),
          ],
        ),
      ),
    );
  }
}

class _AnalysisResult extends StatelessWidget {
  const _AnalysisResult({required this.snapshot});

  final Map<String, dynamic> snapshot;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    final recommendation = _jsonMap(snapshot['recommendation_summary']);
    final category = '${snapshot['category'] ?? 'belum cukup'}';
    final sufficient = snapshot['data_sufficiency'] == true;
    final factors = (recommendation['dominant_factors'] as List? ?? [])
        .map((item) => _factorLabel('$item'))
        .toList();
    final review = '${recommendation['analysis_review'] ?? ''}'.trim();
    final movement = '${recommendation['recommended_movement'] ?? ''}'.trim();
    final reason = '${recommendation['why_this_tactic'] ?? ''}'.trim();
    final practiceTitle = '${recommendation['practice_title'] ?? ''}'.trim();
    final reductionSteps =
        (recommendation['risk_reduction_steps'] as List? ?? [])
            .map((item) => '$item'.trim())
            .where((item) => item.isNotEmpty)
            .toList();
    final canStart = const {'hijau', 'kuning', 'merah'}.contains(category);
    void openPractice() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => KabatZinnPracticeScreen(snapshot: snapshot),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sufficient
                    ? '${recommendation['headline'] ?? 'Rekomendasi'}'
                    : 'Data belum cukup',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                sufficient
                    ? '${recommendation['action'] ?? ''}'
                    : 'Lengkapi check-out dan jurnal pasca aktivitas agar rekomendasi bisa mengikuti kondisi Anda.',
              ),
              if (review.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InsightLine(icon: Icons.psychology_outlined, text: review),
              ],
              if (reason.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InsightLine(icon: Icons.lightbulb_outline, text: reason),
              ],
              if (reductionSteps.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...reductionSteps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _InsightLine(
                      icon: Icons.check_circle_outline,
                      text: step,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.self_improvement, color: primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (practiceTitle.isNotEmpty) ...[
                            Text(
                              practiceTitle,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text('${recommendation['practice'] ?? ''}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (movement.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InsightLine(icon: Icons.accessibility_new, text: movement),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canStart ? openPractice : null,
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('Info Teknik'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: canStart ? openPractice : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Mulai Latihan'),
                    ),
                  ),
                ],
              ),
              if (factors.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: factors
                      .map(
                        (factor) =>
                            StatusPill(label: factor, color: AppTheme.muted),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;

    return SoftCard(
      child: Row(
        children: [
          Icon(Icons.fact_check_outlined, color: primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Lengkapi check-in, check-out, dan jurnal pasca aktivitas agar rekomendasi bisa mengikuti kondisi Anda.',
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightLine extends StatelessWidget {
  const _InsightLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final primary = Theme.of(context).colorScheme.secondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onSelected(value),
    );
  }
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _factorLabel(String factor) {
  return switch (factor) {
    'workload_over_capacity' => 'Beban > kapasitas',
    'dense_workload' => 'Jadwal padat',
    'high_wellbeing_pressure' => 'Tekanan wellbeing tinggi',
    'crisis_flag' => 'Perlu dukungan segera',
    'teacher_self_report_high' => 'Tekanan guru tinggi',
    'checkout_negative_mood' => 'Mood checkout negatif',
    'journal_pressure_terms' => 'Jurnal menekan',
    'consecutive_high_intensity' => 'Intensitas tinggi',
    'late_activity' => 'Aktivitas larut',
    'balanced_period' => 'Periode seimbang',
    _ => factor,
  };
}
