import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/dashboard_refresh.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import 'kabat_zinn_practice_screen.dart';

class AnalysisDashboardScreen extends StatefulWidget {
  const AnalysisDashboardScreen({super.key});

  @override
  State<AnalysisDashboardScreen> createState() =>
      _AnalysisDashboardScreenState();
}

class _AnalysisDashboardScreenState extends State<AnalysisDashboardScreen> {
  late Future<_AnalysisBundle> _future;
  DateTime _date = DateTime.now();
  String _period = 'weekly';
  String _source = 'auto_weekly';
  int _selfReportLevel = 5;
  bool _running = false;
  bool _savingSelfReport = false;
  Map<String, dynamic>? _freshSnapshot;

  @override
  void initState() {
    super.initState();
    _future = _load();
    analysisRefreshTick.addListener(_reload);
  }

  @override
  void dispose() {
    analysisRefreshTick.removeListener(_reload);
    super.dispose();
  }

  Future<_AnalysisBundle> _load() async {
    final results = await Future.wait<dynamic>([
      Api.burnoutOverview(),
      Api.burnoutAnalyses(),
    ]);
    final analysesResponse = results[1] as Map<String, dynamic>;

    return _AnalysisBundle(
      overview: results[0] as Map<String, dynamic>,
      analyses: (analysesResponse['data'] as List? ?? [])
          .map((item) => _jsonMap(item))
          .toList(),
    );
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _load());
  }

  Future<void> _refresh() async {
    _reload();
    await _future;
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

  Future<void> _runManual() async {
    setState(() => _running = true);
    try {
      final snapshot = await Api.createBurnoutAnalysis(
        periodType: _period,
        date: DateFormat('yyyy-MM-dd').format(_date),
      );
      if (mounted) {
        setState(() {
          _freshSnapshot = _jsonMap(snapshot);
          _future = _load();
        });
      }
      requestDashboardRefresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _saveSelfReport() async {
    setState(() => _savingSelfReport = true);
    try {
      await Api.saveBurnoutSelfReport(level: _selfReportLevel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kondisi hari ini tersimpan.')),
        );
        _reload();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _savingSelfReport = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<Session>().isTeacher;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<_AnalysisBundle>(
            future: _future,
            builder: (context, snapshot) {
              final loading =
                  snapshot.connectionState == ConnectionState.waiting;
              final bundle = snapshot.data;
              final overview = bundle?.overview ?? <String, dynamic>{};
              final analyses = _mergedAnalyses(
                bundle?.analyses ?? [],
                _freshSnapshot,
              );
              final today = _freshTodayPreview(overview, _freshSnapshot);
              final dailyHistory = (overview['daily_history'] as List? ?? [])
                  .map((item) => _jsonMap(item))
                  .toList();
              final weekly = analyses
                  .where(
                    (item) =>
                        item['period_type'] == 'weekly' &&
                        item['source'] == _source,
                  )
                  .toList();
              final todaySnapshot = _snapshotFromPreview(today);
              final latest =
                  (_freshSnapshot?['category'] != null
                      ? _freshSnapshot
                      : null) ??
                  todaySnapshot ??
                  analyses
                      .where((item) => item['category'] != null)
                      .firstOrNull ??
                  analyses.firstOrNull;
              final reviewSnapshot = _reviewSnapshot(
                todaySnapshot,
                analyses,
                _freshSnapshot,
              );

              return ListView(
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  const BrandHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Hasil Analisis',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'History analisis',
                              onPressed: analyses.isEmpty
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => _AnalysisHistoryScreen(
                                          analyses: analyses,
                                        ),
                                      ),
                                    ),
                              icon: const Icon(Icons.history),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Grafik risiko mingguan, analisis manual, dan rekomendasi dari jurnal aktivitas.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        if (snapshot.hasError)
                          _InfoCard(message: _errorMessage(snapshot.error))
                        else if (loading)
                          const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else ...[
                          _TodayScaleCard(today: today),
                          const SizedBox(height: 18),
                          _JournalReviewCard(snapshot: reviewSnapshot),
                          const SizedBox(height: 18),
                          _AnalysisGraphCard(
                            snapshot: reviewSnapshot,
                            dailyHistory: dailyHistory,
                          ),
                          const SizedBox(height: 18),
                          _ManualAnalysisCard(
                            date: _date,
                            period: _period,
                            running: _running,
                            onDateTap: _pickDate,
                            onPeriodChanged: (value) =>
                                setState(() => _period = value),
                            onRun: _runManual,
                          ),
                          if (isTeacher) ...[
                            const SizedBox(height: 18),
                            _SelfReportCard(
                              level: _selfReportLevel,
                              saving: _savingSelfReport,
                              onChanged: (value) => setState(
                                () => _selfReportLevel = value.round(),
                              ),
                              onSave: _saveSelfReport,
                            ),
                          ],
                          const SizedBox(height: 18),
                          _WeeklyChartCard(
                            source: _source,
                            analyses: weekly,
                            onSourceChanged: (value) =>
                                setState(() => _source = value),
                          ),
                          const SizedBox(height: 18),
                          if (latest == null)
                            const _InfoCard(
                              message:
                                  'Belum ada hasil analisis. Jalankan analisis manual setelah aktivitas punya check-out dan jurnal pasca.',
                            )
                          else
                            _RecommendationCard(snapshot: latest),
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

class _ManualAnalysisCard extends StatelessWidget {
  const _ManualAnalysisCard({
    required this.date,
    required this.period,
    required this.running,
    required this.onDateTap,
    required this.onPeriodChanged,
    required this.onRun,
  });

  final DateTime date;
  final String period;
  final bool running;
  final VoidCallback onDateTap;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Analisis Manual',
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
                selected: period,
                onSelected: onPeriodChanged,
              ),
              _PeriodChip(
                label: 'Mingguan',
                value: 'weekly',
                selected: period,
                onSelected: onPeriodChanged,
              ),
              _PeriodChip(
                label: 'Bulanan',
                value: 'monthly',
                selected: period,
                onSelected: onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onDateTap,
            icon: const Icon(Icons.calendar_month),
            label: Text(DateFormat('d MMMM yyyy', 'id_ID').format(date)),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: running ? null : onRun,
            icon: const Icon(Icons.insights),
            label: Text(running ? 'Menganalisis...' : 'Jalankan Manual'),
          ),
        ],
      ),
    );
  }
}

class _TodayScaleCard extends StatelessWidget {
  const _TodayScaleCard({required this.today});

  final Map<String, dynamic> today;

  @override
  Widget build(BuildContext context) {
    final hasScore = today['score'] != null;
    final category = '${today['category'] ?? 'belum cukup'}';
    final color = _categoryColor(category);
    final recommendation = _jsonMap(today['recommendation']);
    final headline = '${recommendation['headline'] ?? 'Belum ada rekomendasi'}';
    final action = '${recommendation['action'] ?? ''}';
    final practice = '${recommendation['practice'] ?? ''}';
    final practiceTitle = '${recommendation['practice_title'] ?? ''}'.trim();
    final activityCount = _numValue(today['activity_count']).round();
    final journalCount = _numValue(
      today['journal_count'],
      fallback: _listOfMaps(today['journal_reviews']).length.toDouble(),
    ).round();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kondisi Anda Hari Ini',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Icon(
                Icons.spa_outlined,
                color: hasScore ? color : AppTheme.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: _categoryLabel(category),
                color: hasScore ? color : AppTheme.muted,
              ),
              StatusPill(
                label: '$activityCount activity dihitung',
                color: AppTheme.muted,
              ),
              StatusPill(
                label: '$journalCount journal dihitung',
                color: AppTheme.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasScore)
            const Text(
              'Lengkapi check-out dan jurnal pasca aktivitas agar aplikasi bisa memberi rekomendasi yang sesuai.',
            )
          else ...[
            Text(headline, style: Theme.of(context).textTheme.titleMedium),
            if (action.isNotEmpty) ...[const SizedBox(height: 8), Text(action)],
            if (practice.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PracticeCallout(title: practiceTitle, text: practice),
            ],
          ],
        ],
      ),
    );
  }
}

class _SelfReportCard extends StatelessWidget {
  const _SelfReportCard({
    required this.level,
    required this.saving,
    required this.onChanged,
    required this.onSave,
  });

  final int level;
  final bool saving;
  final ValueChanged<double> onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Refleksi Kondisi Guru',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Seberapa berat tekanan yang terasa hari ini?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(
            '$level / 10',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Slider(
            value: level.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$level',
            onChanged: saving ? null : onChanged,
          ),
          FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: const Icon(Icons.check),
            label: Text(saving ? 'Menyimpan...' : 'Simpan Kondisi'),
          ),
        ],
      ),
    );
  }
}

class _JournalReviewCard extends StatelessWidget {
  const _JournalReviewCard({required this.snapshot});

  final Map<String, dynamic>? snapshot;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    final data = snapshot ?? <String, dynamic>{};
    final period = '${data['period_type'] ?? 'daily'}';
    final reviews = _journalReviews(data);
    final grouped = _groupReviewsByDate(reviews);
    final category = '${data['category'] ?? 'belum cukup'}';
    final activityCount = _numValue(data['activity_count']).round();
    final completedCount = _numValue(data['completed_activity_count']).round();
    final journalCount = _numValue(
      data['journal_count'],
      fallback: reviews.length.toDouble(),
    ).round();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Review AI Jurnal ${_periodReviewLabel(period)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Icon(Icons.edit_note, color: primary),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: _categoryLabel(category),
                color: _categoryColor(category),
              ),
              StatusPill(
                label: '$activityCount activity dihitung',
                color: AppTheme.muted,
              ),
              StatusPill(
                label: '$completedCount selesai',
                color: AppTheme.muted,
              ),
              StatusPill(
                label: '$journalCount journal dihitung',
                color: AppTheme.muted,
              ),
            ],
          ),
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${reviews.length} review jurnal aktivitas terbaca dalam periode ini.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (reviews.isEmpty)
            const _InfoInline(
              message:
                  'Belum ada review. Isi check-out dan jurnal pasca aktivitas untuk melihat masukan.',
            )
          else if (reviews.length > 3)
            SizedBox(
              height: 250,
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _reviewGroupWidgets(grouped),
                  ),
                ),
              ),
            )
          else
            ..._reviewGroupWidgets(grouped),
        ],
      ),
    );
  }
}

List<Widget> _reviewGroupWidgets(
  Map<String, List<Map<String, dynamic>>> grouped,
) {
  final widgets = <Widget>[];
  final entries = grouped.entries.toList();

  for (var entryIndex = 0; entryIndex < entries.length; entryIndex++) {
    final entry = entries[entryIndex];
    widgets.add(_JournalDayDivider(date: entry.key));
    widgets.add(const SizedBox(height: 10));

    for (var index = 0; index < entry.value.length; index++) {
      widgets.add(_JournalReviewTile(review: entry.value[index]));
      if (index != entry.value.length - 1) {
        widgets.add(const SizedBox(height: 10));
      }
    }

    if (entryIndex != entries.length - 1) {
      widgets.add(const SizedBox(height: 14));
    }
  }

  return widgets;
}

class _JournalDayDivider extends StatelessWidget {
  const _JournalDayDivider({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.line),
      ),
      child: Text(
        _dayLabel(date),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: primary,
        ),
      ),
    );
  }
}

class _JournalReviewTile extends StatelessWidget {
  const _JournalReviewTile({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;

    void openReview() {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('${review['title'] ?? 'Review Jurnal'}'),
          scrollable: true,
          content: _JournalReviewDialogContent(review: review),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Tutup'),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openReview,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${review['title'] ?? 'Aktivitas'}',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.open_in_new, color: AppTheme.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalReviewDialogContent extends StatelessWidget {
  const _JournalReviewDialogContent({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    final mood = '${review['mood_detected'] ?? review['mood'] ?? ''}'.trim();
    final suggestion = '${review['suggestion'] ?? ''}'.trim();
    final fact = '${review['fact'] ?? ''}'.trim();
    final feeling = '${review['feeling'] ?? ''}'.trim();
    final plan = '${review['plan'] ?? ''}'.trim();
    final crisis = review['crisis_flag'] == true;
    final source = '${review['analysis_source'] ?? ''}'.trim();
    final meta = _reviewDateLabel(
      review['checked_out_at'] ?? review['activity_date'],
    );
    final dimensions = _listOfStrings(review['burnout_dimensions']);
    final recommendedTactic = _jsonMap(review['recommended_tactic']);
    final tacticTitle = '${recommendedTactic['title'] ?? ''}'.trim();
    final tacticDescription =
        '${recommendedTactic['description'] ?? recommendedTactic['practice'] ?? ''}'
            .trim();
    final tacticReason = '${recommendedTactic['why_this_tactic'] ?? ''}'.trim();

    void openTechnique() {
      if (recommendedTactic.isEmpty) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => KabatZinnPracticeScreen(
            snapshot: {
              'source': 'journal_review',
              'category': _categoryFromReview(review),
              'recommendation_summary': {
                'practice_code': recommendedTactic['code'],
                'practice_title': recommendedTactic['title'],
                'practice': tacticDescription,
                'recommended_movement':
                    recommendedTactic['recommended_movement'],
                'why_this_tactic': recommendedTactic['why_this_tactic'],
                'tactic': recommendedTactic,
              },
              'tactic': recommendedTactic,
            },
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (mood.isNotEmpty)
              StatusPill(label: 'Mood: $mood', color: primary),
            _AnalysisSourceBadge(source: source),
            Text(
              meta,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (fact.isNotEmpty) ...[const SizedBox(height: 8), Text(fact)],
        if (feeling.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Perasaan: $feeling',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (suggestion.isNotEmpty) ...[
          const SizedBox(height: 10),
          _JournalSuggestionBubble(text: suggestion),
        ],
        if (recommendedTactic.isNotEmpty) ...[
          const SizedBox(height: 10),
          _PracticeCallout(title: tacticTitle, text: tacticDescription),
          if (tacticReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            _RecommendationDetailLine(
              icon: Icons.lightbulb_outline,
              text: tacticReason,
            ),
          ],
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: openTechnique,
            icon: const Icon(Icons.self_improvement),
            label: const Text('Buka Teknik Ini'),
          ),
        ],
        if (plan.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Rencana: $plan',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (dimensions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dimensions
                .map(
                  (dimension) => StatusPill(
                    label: _dimensionLabel(dimension),
                    color: AppTheme.muted,
                  ),
                )
                .toList(),
          ),
        ],
        if (crisis) ...[
          const SizedBox(height: 8),
          const Text(
            'Ada sinyal perlu dukungan segera. Hubungi orang tepercaya atau pendamping profesional.',
          ),
        ],
      ],
    );
  }
}

class _AnalysisSourceBadge extends StatelessWidget {
  const _AnalysisSourceBadge({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final isAi = _isAiSource(source);
    final color = isAi ? const Color(0xFF24718E) : AppTheme.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_sourceIcon(source), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            _sourceLabel(source),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _JournalSuggestionBubble extends StatelessWidget {
  const _JournalSuggestionBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _DailyChartCard extends StatelessWidget {
  const _DailyChartCard({required this.points});

  final List<Map<String, dynamic>> points;

  @override
  Widget build(BuildContext context) {
    final scored = points.where((item) => item['score'] != null).toList();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Grafik Burnout Harian',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Rekap dari beban aktivitas terbaru dan jurnal check-out per hari.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (scored.isEmpty)
            const _InfoInline(
              message:
                  'Belum ada skor harian. Selesaikan aktivitas dan isi jurnal check-out untuk membentuk grafik.',
            )
          else
            SizedBox(
              height: 180,
              child: CustomPaint(painter: _RiskChartPainter(scored)),
            ),
        ],
      ),
    );
  }
}

class _AnalysisGraphCard extends StatelessWidget {
  const _AnalysisGraphCard({
    required this.snapshot,
    required this.dailyHistory,
  });

  final Map<String, dynamic>? snapshot;
  final List<Map<String, dynamic>> dailyHistory;

  @override
  Widget build(BuildContext context) {
    final data = snapshot ?? <String, dynamic>{};
    final period = '${data['period_type'] ?? 'daily'}';
    final finalScore = _numValue(data['final_burnout_risk_score']);
    final finalCategory = '${data['category'] ?? ''}';
    final activities = _activityBreakdown(
      data,
    ).where((item) => '${item['status'] ?? ''}' != 'cancelled').toList();

    if (period != 'daily') {
      return _DailyChartCard(points: dailyHistory);
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Grafik Activity Harian',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Status setiap activity pada hari yang dianalisis.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            const _InfoInline(
              message:
                  'Belum ada activity pada hari ini untuk digambarkan di grafik.',
            )
          else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: math.max(
                  MediaQuery.sizeOf(context).width - 48,
                  activities.length * 76.0,
                ),
                height: 190,
                child: CustomPaint(
                  painter: _ActivityRiskChartPainter(activities),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (data['final_burnout_risk_score'] != null ||
                finalCategory.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusPill(
                    label: 'Keputusan akhir: ${_categoryLabel(finalCategory)}',
                    color: _categoryColor(finalCategory),
                  ),
                  if (data['final_burnout_risk_score'] != null)
                    StatusPill(
                      label: 'Skor ${finalScore.toStringAsFixed(0)}/100',
                      color: _scoreColor(finalScore),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < activities.length; index++)
                  StatusPill(
                    label:
                        '${index + 1}. ${_shortActivityTitle(activities[index]['title'])} - ${_categoryLabel('${activities[index]['condition']}')}',
                    color: _categoryColor('${activities[index]['condition']}'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({
    required this.source,
    required this.analyses,
    required this.onSourceChanged,
  });

  final String source;
  final List<Map<String, dynamic>> analyses;
  final ValueChanged<String> onSourceChanged;

  @override
  Widget build(BuildContext context) {
    final points = analyses
        .where((item) => item['final_burnout_risk_score'] != null)
        .take(8)
        .toList()
        .reversed
        .toList();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Grafik Mingguan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'auto_weekly',
                    icon: Icon(Icons.autorenew),
                    label: Text('Auto'),
                  ),
                  ButtonSegment(
                    value: 'manual',
                    icon: Icon(Icons.edit_calendar),
                    label: Text('Manual'),
                  ),
                ],
                selected: {source},
                onSelectionChanged: (value) => onSourceChanged(value.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (points.isEmpty)
            const _InfoInline(
              message:
                  'Belum ada data mingguan untuk sumber ini. Auto dibuat scheduler mingguan, manual dibuat dari form di atas.',
            )
          else
            SizedBox(
              height: 180,
              child: CustomPaint(painter: _RiskChartPainter(points)),
            ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.snapshot});

  final Map<String, dynamic> snapshot;

  @override
  Widget build(BuildContext context) {
    final recommendation = _jsonMap(snapshot['recommendation_summary']);
    final category = '${snapshot['category'] ?? 'belum cukup'}';
    final factors = (recommendation['dominant_factors'] as List? ?? [])
        .map((item) => _factorLabel('$item'))
        .toList();
    final review = '${recommendation['analysis_review'] ?? ''}'.trim();
    final movement = '${recommendation['recommended_movement'] ?? ''}'.trim();
    final reason = '${recommendation['why_this_tactic'] ?? ''}'.trim();
    final practiceTitle = '${recommendation['practice_title'] ?? ''}'.trim();
    final reductionSteps = _listOfStrings(
      recommendation['risk_reduction_steps'],
    ).where((item) => item.trim().isNotEmpty).toList();
    final canStart = const {'hijau', 'kuning', 'merah'}.contains(category);
    void openPractice() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => KabatZinnPracticeScreen(snapshot: snapshot),
        ),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${recommendation['headline'] ?? 'Rekomendasi'}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          Text(
            '${recommendation['action'] ?? ''}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (review.isNotEmpty) ...[
            const SizedBox(height: 12),
            _RecommendationDetailLine(
              icon: Icons.psychology_outlined,
              text: review,
            ),
          ],
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            _RecommendationDetailLine(
              icon: Icons.lightbulb_outline,
              text: reason,
            ),
          ],
          if (reductionSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...reductionSteps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _RecommendationDetailLine(
                  icon: Icons.check_circle_outline,
                  text: step,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _PracticeCallout(
            title: practiceTitle,
            text: '${recommendation['practice'] ?? ''}',
          ),
          if (movement.isNotEmpty) ...[
            const SizedBox(height: 10),
            _RecommendationDetailLine(
              icon: Icons.accessibility_new,
              text: movement,
            ),
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
    );
  }
}

class _AnalysisHistoryScreen extends StatelessWidget {
  const _AnalysisHistoryScreen({required this.analyses});

  final List<Map<String, dynamic>> analyses;

  @override
  Widget build(BuildContext context) {
    final items = analyses
        .where((item) => item['period_type'] != null)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('History Analisis')),
      body: SafeArea(
        child: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: _InfoCard(
                  message:
                      'Belum ada history. Jalankan analisis harian, mingguan, atau bulanan untuk menyimpan hasil.',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final snapshot = items[index];
                  return _AnalysisHistoryTile(
                    snapshot: snapshot,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            _AnalysisHistoryDetailScreen(snapshot: snapshot),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _AnalysisHistoryTile extends StatelessWidget {
  const _AnalysisHistoryTile({required this.snapshot, required this.onTap});

  final Map<String, dynamic> snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = '${snapshot['category'] ?? 'belum cukup'}';
    final recommendation = _jsonMap(snapshot['recommendation_summary']);
    final title = '${recommendation['practice_title'] ?? 'Rekomendasi'}';
    final period = '${snapshot['period_type'] ?? 'daily'}';
    final score = snapshot['final_burnout_risk_score'];
    final journalCount = _numValue(
      _jsonMap(snapshot['payload'])['journal_count'],
      fallback: _journalReviews(snapshot).length.toDouble(),
    ).round();

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: _categoryColor(category).withValues(alpha: 0.14),
          child: Icon(
            Icons.analytics_outlined,
            color: _categoryColor(category),
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: _periodReviewLabel(period),
                color: AppTheme.muted,
              ),
              StatusPill(
                label: _historyRangeLabel(snapshot),
                color: AppTheme.muted,
              ),
              StatusPill(
                label: _categoryLabel(category),
                color: _categoryColor(category),
              ),
              if (score != null)
                StatusPill(
                  label: 'Skor ${_numValue(score).toStringAsFixed(0)}',
                  color: _scoreColor(_numValue(score)),
                ),
              StatusPill(label: '$journalCount review', color: AppTheme.muted),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _AnalysisHistoryDetailScreen extends StatelessWidget {
  const _AnalysisHistoryDetailScreen({required this.snapshot});

  final Map<String, dynamic> snapshot;

  @override
  Widget build(BuildContext context) {
    final category = '${snapshot['category'] ?? 'belum cukup'}';
    final score = snapshot['final_burnout_risk_score'];
    final period = '${snapshot['period_type'] ?? 'daily'}';
    final activityCount = _numValue(snapshot['activity_count']).round();
    final journalCount = _numValue(
      _jsonMap(snapshot['payload'])['journal_count'],
      fallback: _journalReviews(snapshot).length.toDouble(),
    ).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail History')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _historyRangeLabel(snapshot),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        label: _periodReviewLabel(period),
                        color: AppTheme.muted,
                      ),
                      StatusPill(
                        label: _categoryLabel(category),
                        color: _categoryColor(category),
                      ),
                      if (score != null)
                        StatusPill(
                          label: 'Skor ${_numValue(score).toStringAsFixed(0)}',
                          color: _scoreColor(_numValue(score)),
                        ),
                      StatusPill(
                        label: '$activityCount activity',
                        color: AppTheme.muted,
                      ),
                      StatusPill(
                        label: '$journalCount review',
                        color: AppTheme.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _RecommendationCard(snapshot: snapshot),
            const SizedBox(height: 16),
            _JournalReviewCard(snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}

class _PracticeCallout extends StatelessWidget {
  const _PracticeCallout({required this.text, this.title = ''});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final primary = Theme.of(context).colorScheme.secondary;

    return Container(
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
                if (title.isNotEmpty) ...[
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                ],
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationDetailLine extends StatelessWidget {
  const _RecommendationDetailLine({required this.icon, required this.text});

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

class _RiskChartPainter extends CustomPainter {
  _RiskChartPainter(this.points);

  final List<Map<String, dynamic>> points;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppTheme.line
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = AppTheme.olive
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final labelPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final chartTop = 8.0;
    final chartBottom = size.height - 26;
    final chartHeight = chartBottom - chartTop;
    final leftInset = points.length == 1 ? size.width / 2 : 18.0;
    final rightInset = points.length == 1 ? size.width / 2 : 18.0;
    final usableWidth = math.max(1.0, size.width - leftInset - rightInset);
    final offsets = <Offset>[];

    for (final threshold in [40.0, 70.0]) {
      final y = chartBottom - (threshold / 100 * chartHeight);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axisPaint);
    }

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final score = _numValue(
        point['final_burnout_risk_score'] ?? point['score'],
      );
      final x = points.length == 1
          ? size.width / 2
          : leftInset + (usableWidth / (points.length - 1)) * i;
      final y = chartBottom - (score.clamp(0, 100) / 100) * chartHeight;
      offsets.add(Offset(x, y));
    }

    if (offsets.length > 1) {
      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final score = _numValue(
        point['final_burnout_risk_score'] ?? point['score'],
      );
      final offset = offsets[i];
      final fillPaint = Paint()..color = _scoreColor(score);
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(offset, 6, fillPaint);
      canvas.drawCircle(offset, 6, strokePaint);

      labelPainter.text = TextSpan(
        text: DateFormat(
          'd/M',
        ).format(_parseDate(point['period_start'] ?? point['date'])),
        style: const TextStyle(color: AppTheme.muted, fontSize: 10),
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(offset.dx - labelPainter.width / 2, chartBottom + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RiskChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _ActivityRiskChartPainter extends CustomPainter {
  _ActivityRiskChartPainter(this.points);

  final List<Map<String, dynamic>> points;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppTheme.line
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = AppTheme.olive
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final labelPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final chartTop = 8.0;
    final chartBottom = size.height - 32;
    final chartHeight = chartBottom - chartTop;
    final leftInset = points.length == 1 ? size.width / 2 : 22.0;
    final rightInset = points.length == 1 ? size.width / 2 : 22.0;
    final usableWidth = math.max(1.0, size.width - leftInset - rightInset);
    final offsets = <Offset>[];

    for (final threshold in [40.0, 70.0]) {
      final y = chartBottom - (threshold / 100 * chartHeight);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axisPaint);
    }

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final score = _numValue(point['score']);
      final x = points.length == 1
          ? size.width / 2
          : leftInset + (usableWidth / (points.length - 1)) * i;
      final y = chartBottom - (score.clamp(0, 100) / 100) * chartHeight;
      offsets.add(Offset(x, y));
    }

    if (offsets.length > 1) {
      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final condition = '${point['condition'] ?? ''}';
      final offset = offsets[i];
      final fillPaint = Paint()..color = _categoryColor(condition);
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(offset, 7, fillPaint);
      canvas.drawCircle(offset, 7, strokePaint);

      labelPainter.text = TextSpan(
        text: '${i + 1}',
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(offset.dx - labelPainter.width / 2, chartBottom + 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityRiskChartPainter oldDelegate) {
    return oldDelegate.points != points;
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SoftCard(child: _InfoInline(message: message));
  }
}

class _InfoInline extends StatelessWidget {
  const _InfoInline({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;

    return Row(
      children: [
        Icon(Icons.info_outline, color: primary),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    );
  }
}

class _AnalysisBundle {
  const _AnalysisBundle({required this.overview, required this.analyses});

  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> analyses;
}

List<Map<String, dynamic>> _mergedAnalyses(
  List<Map<String, dynamic>> analyses,
  Map<String, dynamic>? fresh,
) {
  if (fresh == null || fresh.isEmpty) return analyses;

  final freshId = fresh['id'];
  return [
    fresh,
    ...analyses.where((item) => freshId == null || item['id'] != freshId),
  ];
}

Map<String, dynamic> _freshTodayPreview(
  Map<String, dynamic> overview,
  Map<String, dynamic>? fresh,
) {
  final today = _jsonMap(overview['today']);
  if (fresh == null || fresh.isEmpty) return today;
  if (fresh['period_type'] != 'daily') return today;

  final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  if (fresh['period_start'] != currentDate) return today;

  return {
    ...today,
    'period_type': fresh['period_type'],
    'period_start': fresh['period_start'],
    'period_end': fresh['period_end'],
    'score': fresh['final_burnout_risk_score'],
    'category': fresh['category'],
    'data_sufficiency': fresh['data_sufficiency'],
    'activity_count': fresh['activity_count'],
    'completed_activity_count': fresh['completed_activity_count'],
    'journal_count': _numValue(
      _jsonMap(fresh['payload'])['journal_count'],
    ).round(),
    'weighted_actual_hours': fresh['weighted_actual_hours'],
    'workload_score_raw': fresh['workload_score_raw'],
    'journal_score': fresh['journal_score'],
    'dominant_factors': fresh['dominant_factors'],
    'recommendation': fresh['recommendation_summary'],
    'activity_breakdown':
        _listOfMaps(_jsonMap(fresh['payload'])['activity_breakdown']).isEmpty
        ? today['activity_breakdown']
        : _listOfMaps(_jsonMap(fresh['payload'])['activity_breakdown']),
    'journal_reviews':
        _listOfMaps(_jsonMap(fresh['payload'])['journal_reviews']).isEmpty
        ? today['journal_reviews']
        : _listOfMaps(_jsonMap(fresh['payload'])['journal_reviews']),
  };
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _listOfMaps(dynamic value) {
  if (value is List) return value.map((item) => _jsonMap(item)).toList();
  return const [];
}

List<String> _listOfStrings(dynamic value) {
  if (value is List) return value.map((item) => '$item').toList();
  return const [];
}

List<Map<String, dynamic>> _journalReviews(Map<String, dynamic>? snapshot) {
  if (snapshot == null || snapshot.isEmpty) return const [];

  final direct = _listOfMaps(snapshot['journal_reviews']);
  if (direct.isNotEmpty) return direct;

  return _listOfMaps(_jsonMap(snapshot['payload'])['journal_reviews']);
}

List<Map<String, dynamic>> _activityBreakdown(Map<String, dynamic>? snapshot) {
  if (snapshot == null || snapshot.isEmpty) return const [];

  final direct = _listOfMaps(snapshot['activity_breakdown']);
  if (direct.isNotEmpty) return direct;

  return _listOfMaps(_jsonMap(snapshot['payload'])['activity_breakdown']);
}

Map<String, List<Map<String, dynamic>>> _groupReviewsByDate(
  List<Map<String, dynamic>> reviews,
) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final review in reviews) {
    final key = _dateKey(review['activity_date'] ?? review['checked_out_at']);
    grouped.putIfAbsent(key, () => []).add(review);
  }
  return grouped;
}

Map<String, dynamic>? _reviewSnapshot(
  Map<String, dynamic>? today,
  List<Map<String, dynamic>> analyses,
  Map<String, dynamic>? fresh,
) {
  if (fresh != null && fresh.isNotEmpty) return fresh;
  if (today != null && _journalReviews(today).isNotEmpty) return today;

  for (final analysis in analyses) {
    if (_journalReviews(analysis).isNotEmpty) return analysis;
  }

  return today;
}

Map<String, dynamic>? _snapshotFromPreview(Map<String, dynamic> preview) {
  if (preview.isEmpty) return null;

  return {
    'period_type': preview['period_type'],
    'period_start': preview['period_start'],
    'period_end': preview['period_end'],
    'data_sufficiency': preview['data_sufficiency'],
    'activity_count': preview['activity_count'],
    'completed_activity_count': preview['completed_activity_count'],
    'journal_count': preview['journal_count'],
    'weighted_actual_hours': preview['weighted_actual_hours'],
    'workload_score_raw': preview['workload_score_raw'],
    'journal_score': preview['journal_score'],
    'final_burnout_risk_score': preview['score'],
    'category': preview['category'],
    'dominant_factors': preview['dominant_factors'],
    'recommendation_summary': preview['recommendation'],
    'activity_breakdown': preview['activity_breakdown'],
    'journal_reviews': preview['journal_reviews'],
  };
}

double _numValue(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

String _errorMessage(Object? error) {
  if (error is ApiException) return error.message;
  return 'Gagal memuat hasil analisis.';
}

DateTime _parseDate(dynamic value) {
  return DateTime.tryParse('$value') ?? DateTime.now();
}

String _dateKey(dynamic value) {
  final raw = '$value';
  if (raw.length >= 10) return raw.substring(0, 10);
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

String _dayLabel(String date) {
  return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_parseDate(date));
}

String _periodReviewLabel(String period) {
  return switch (period) {
    'weekly' => 'Mingguan',
    'monthly' => 'Bulanan',
    _ => 'Harian',
  };
}

String _historyRangeLabel(Map<String, dynamic> snapshot) {
  final start = _parseDate(snapshot['period_start']);
  final end = _parseDate(snapshot['period_end'] ?? snapshot['period_start']);
  final format = DateFormat('d MMM yyyy', 'id_ID');

  if (DateUtils.isSameDay(start, end)) {
    return format.format(start);
  }

  return '${format.format(start)} - ${format.format(end)}';
}

String _reviewDateLabel(dynamic date) {
  final parsed = DateTime.tryParse('$date');
  return parsed == null
      ? 'Tanggal belum tersedia'
      : DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(parsed.toLocal());
}

String _sourceLabel(String source) {
  return _isAiSource(source) ? 'Berbasis AI' : 'Lokal';
}

String _categoryFromReview(Map<String, dynamic> review) {
  if (review['crisis_flag'] == true) return 'merah';

  final mood = '${review['mood_detected'] ?? review['mood'] ?? ''}';
  if (const {'cemas', 'sedih', 'marah', 'lelah'}.contains(mood)) {
    return 'kuning';
  }

  return 'hijau';
}

IconData _sourceIcon(String source) {
  return _isAiSource(source) ? Icons.smart_toy_outlined : Icons.storage;
}

bool _isAiSource(String source) {
  return source == 'gemini';
}

String _shortActivityTitle(dynamic title) {
  final text = '$title'.trim();
  if (text.length <= 24) return text;
  return '${text.substring(0, 24)}...';
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
    'merah' => const Color(0xFFC65A4A),
    'kuning' => const Color(0xFFD99B3D),
    'hijau' => AppTheme.olive,
    _ => AppTheme.muted,
  };
}

Color _scoreColor(double score) {
  if (score >= 70) return const Color(0xFFC65A4A);
  if (score >= 40) return const Color(0xFFD99B3D);
  return AppTheme.olive;
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

String _dimensionLabel(String dimension) {
  return switch (dimension) {
    'kelelahan_emosional' => 'Kelelahan emosional',
    'depersonalisasi' => 'Depersonalisasi',
    'rendah_pencapaian_diri' => 'Rendah pencapaian diri',
    _ => dimension,
  };
}
