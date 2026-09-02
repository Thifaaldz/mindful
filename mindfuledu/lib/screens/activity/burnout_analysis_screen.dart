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
    final recommendation = _jsonMap(snapshot['recommendation_summary']);
    final category = '${snapshot['category'] ?? 'belum cukup'}';
    final sufficient = snapshot['data_sufficiency'] == true;
    final factors = (recommendation['dominant_factors'] as List? ?? [])
        .map((item) => _factorLabel('$item'))
        .toList();
    final review = '${recommendation['analysis_review'] ?? ''}'.trim();
    final reductionSteps = _listOfStrings(
      recommendation['risk_reduction_steps'],
    ).where((item) => item.trim().isNotEmpty).toList();
    final reviews = _journalReviews(snapshot);
    final score = snapshot['final_burnout_risk_score'];
    final periodType = '${snapshot['period_type'] ?? 'daily'}';
    final activityCount = _numValue(snapshot['activity_count']).round();
    final completedCount = _numValue(
      snapshot['completed_activity_count'],
    ).round();
    final journalCount = _numValue(
      _jsonMap(snapshot['payload'])['journal_count'],
      fallback: reviews.length.toDouble(),
    ).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sufficient
                    ? 'Kesimpulan ${_periodLabel(periodType)}'
                    : 'Data belum cukup',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusPill(
                    label: _categoryLabel(category),
                    color: _categoryColor(category),
                  ),
                  if (score != null)
                    StatusPill(
                      label: 'Skor ${_numValue(score).toStringAsFixed(0)}/100',
                      color: _scoreColor(_numValue(score)),
                    ),
                  StatusPill(
                    label: '$activityCount activity',
                    color: AppTheme.muted,
                  ),
                  StatusPill(
                    label: '$completedCount selesai',
                    color: AppTheme.muted,
                  ),
                  StatusPill(
                    label: '$journalCount journal',
                    color: AppTheme.muted,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                sufficient
                    ? '${recommendation['headline'] ?? 'Rekomendasi'}'
                    : 'Lengkapi check-out dan jurnal pasca aktivitas agar rekomendasi bisa mengikuti kondisi Anda.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if ('${recommendation['action'] ?? ''}'.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${recommendation['action']}'),
              ],
              if (review.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InsightLine(icon: Icons.psychology_outlined, text: review),
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
        const SizedBox(height: 16),
        _ActivityAnalysisSection(
          periodType: periodType,
          reviews: reviews,
          fallbackActivityCount: activityCount,
        ),
      ],
    );
  }
}

class _ActivityAnalysisSection extends StatelessWidget {
  const _ActivityAnalysisSection({
    required this.periodType,
    required this.reviews,
    required this.fallbackActivityCount,
  });

  final String periodType;
  final List<Map<String, dynamic>> reviews;
  final int fallbackActivityCount;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return SoftCard(
        child: _InsightLine(
          icon: Icons.edit_note_outlined,
          text: fallbackActivityCount > 0
              ? 'Activity sudah tercatat, tetapi detail review akan muncul setelah activity selesai check-out dan jurnal pasca terisi.'
              : 'Belum ada activity pada periode ini.',
        ),
      );
    }

    final grouped = _groupReviewsByDate(reviews);
    final entries = grouped.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            'Detail Analisis Activity ${_periodLabel(periodType)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        for (var groupIndex = 0; groupIndex < entries.length; groupIndex++) ...[
          _DayDivider(date: entries[groupIndex].key),
          const SizedBox(height: 10),
          for (final review in entries[groupIndex].value) ...[
            _ActivityAnalysisCard(review: review),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.line),
      ),
      child: Text(
        _dayLabel(date),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActivityAnalysisCard extends StatelessWidget {
  const _ActivityAnalysisCard({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final condition = '${review['condition'] ?? _categoryFromReview(review)}';
    final score = review['score'];
    final color = _categoryColor(condition);
    final mood = '${review['mood_detected'] ?? review['mood'] ?? ''}'.trim();
    final fact = '${review['fact'] ?? ''}'.trim();
    final feeling = '${review['feeling'] ?? ''}'.trim();
    final pattern = '${review['pattern'] ?? ''}'.trim();
    final plan = '${review['plan'] ?? ''}'.trim();
    final suggestion = '${review['suggestion'] ?? ''}'.trim();
    final dimensions = _listOfStrings(review['burnout_dimensions']);
    final tactic = _jsonMap(review['recommended_tactic']);
    final tacticTitle = '${tactic['title'] ?? ''}'.trim();
    final tacticText = '${tactic['description'] ?? tactic['practice'] ?? ''}'
        .trim();
    final tacticReason = '${tactic['why_this_tactic'] ?? ''}'.trim();
    final movement = '${tactic['recommended_movement'] ?? ''}'.trim();

    void openTechnique() {
      if (tactic.isEmpty) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => KabatZinnPracticeScreen(
            snapshot: {
              'source': 'activity_analysis',
              'category': condition,
              'recommendation_summary': {
                'practice_code': tactic['code'],
                'practice_title': tactic['title'],
                'practice': tacticText,
                'recommended_movement': tactic['recommended_movement'],
                'why_this_tactic': tactic['why_this_tactic'],
                'tactic': tactic,
              },
              'tactic': tactic,
            },
          ),
        ),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(Icons.analytics_outlined, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${review['title'] ?? 'Aktivitas'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _reviewDateLabel(
                        review['checked_out_at'] ?? review['activity_date'],
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: score == null
                    ? _categoryLabel(condition)
                    : '${_categoryLabel(condition)} ${_numValue(score).toStringAsFixed(0)}',
                color: color,
              ),
              if (mood.isNotEmpty)
                StatusPill(label: 'Mood: $mood', color: color),
            ],
          ),
          const SizedBox(height: 12),
          _InsightLine(
            icon: Icons.psychology_outlined,
            text: _activityInsight(review),
          ),
          if (fact.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DetailBlock(label: 'Fakta', text: fact),
          ],
          if (feeling.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailBlock(label: 'Perasaan', text: feeling),
          ],
          if (pattern.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailBlock(label: 'Pola', text: pattern),
          ],
          if (plan.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailBlock(label: 'Rencana', text: plan),
          ],
          if (suggestion.isNotEmpty) ...[
            const SizedBox(height: 12),
            _AiSuggestion(text: suggestion),
          ],
          if (dimensions.isNotEmpty) ...[
            const SizedBox(height: 12),
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
          if (tactic.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TechniqueRecommendation(
              condition: condition,
              title: tacticTitle,
              text: tacticText,
              reason: tacticReason,
              movement: movement,
              onOpen: openTechnique,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(text),
      ],
    );
  }
}

class _AiSuggestion extends StatelessWidget {
  const _AiSuggestion({required this.text});

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

class _TechniqueRecommendation extends StatelessWidget {
  const _TechniqueRecommendation({
    required this.condition,
    required this.title,
    required this.text,
    required this.reason,
    required this.movement,
    required this.onOpen,
  });

  final String condition;
  final String title;
  final String text;
  final String reason;
  final String movement;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(condition);
    final actionPrefix = condition == 'hijau'
        ? 'Untuk menjaga kondisi tetap stabil'
        : 'Untuk membantu menurunkan tekanan activity ini';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.self_improvement, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title.isEmpty ? 'Teknik mindfulness' : title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$actionPrefix, lakukan ${title.isEmpty ? 'teknik ini' : title}.',
          ),
          if (text.isNotEmpty) ...[const SizedBox(height: 8), Text(text)],
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InsightLine(icon: Icons.lightbulb_outline, text: reason),
          ],
          if (movement.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InsightLine(icon: Icons.accessibility_new, text: movement),
          ],
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Buka Teknik Ini'),
          ),
        ],
      ),
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

List<Map<String, dynamic>> _listOfMaps(dynamic value) {
  if (value is List) return value.map((item) => _jsonMap(item)).toList();
  return const [];
}

List<String> _listOfStrings(dynamic value) {
  if (value is List) return value.map((item) => '$item').toList();
  return const [];
}

List<Map<String, dynamic>> _journalReviews(Map<String, dynamic> snapshot) {
  final direct = _listOfMaps(snapshot['journal_reviews']);
  if (direct.isNotEmpty) return direct;

  return _listOfMaps(_jsonMap(snapshot['payload'])['journal_reviews']);
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

String _dateKey(dynamic value) {
  final parsed = DateTime.tryParse('$value');
  if (parsed == null) return '$value';
  return DateFormat('yyyy-MM-dd').format(parsed.toLocal());
}

String _dayLabel(String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(parsed);
}

String _reviewDateLabel(dynamic value) {
  final parsed = DateTime.tryParse('$value');
  if (parsed == null) return 'Tanggal belum tersedia';
  return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(parsed.toLocal());
}

String _periodLabel(String periodType) {
  return switch (periodType) {
    'weekly' => 'mingguan',
    'monthly' => 'bulanan',
    _ => 'harian',
  };
}

double _numValue(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
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

String _categoryFromReview(Map<String, dynamic> review) {
  if (review['crisis_flag'] == true) return 'merah';

  final mood = '${review['mood_detected'] ?? review['mood'] ?? ''}';
  if (const {'cemas', 'sedih', 'marah', 'lelah'}.contains(mood)) {
    return 'kuning';
  }

  return 'hijau';
}

String _activityInsight(Map<String, dynamic> review) {
  final condition = '${review['condition'] ?? _categoryFromReview(review)}';
  final title = '${review['title'] ?? 'Aktivitas ini'}';
  final mood = '${review['mood_detected'] ?? review['mood'] ?? ''}'.trim();
  final fact = '${review['fact'] ?? ''}'.trim();
  final feeling = '${review['feeling'] ?? ''}'.trim();
  final tactic = _jsonMap(review['recommended_tactic']);
  final tacticTitle = '${tactic['title'] ?? ''}'.trim();

  final conditionText = switch (condition) {
    'merah' => 'menunjukkan tekanan tinggi dan perlu dipulihkan lebih serius',
    'kuning' => 'mulai menunjukkan tanda tekanan yang perlu diturunkan',
    'hijau' => 'masih relatif stabil dan bisa dipertahankan',
    _ => 'belum memiliki status yang cukup jelas',
  };
  final moodText = mood.isEmpty ? '' : ' Mood yang terbaca adalah $mood.';
  final factText = fact.isEmpty ? '' : ' Fakta utama: $fact';
  final feelingText = feeling.isEmpty ? '' : ' Perasaan yang muncul: $feeling';
  final tacticText = tacticTitle.isEmpty
      ? ''
      : ' Teknik yang disarankan untuk activity ini adalah $tacticTitle.';

  return '$title $conditionText.$moodText$factText$feelingText$tacticText';
}

String _dimensionLabel(String dimension) {
  return switch (dimension) {
    'kelelahan_emosional' => 'Kelelahan emosional',
    'depersonalisasi' => 'Depersonalisasi',
    'rendah_pencapaian_diri' => 'Rendah pencapaian diri',
    _ => dimension,
  };
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
