import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/dashboard_refresh.dart';
import '../../widgets/app_chrome.dart';
import 'logbook_history_screen.dart';

class LogbookFormScreen extends StatefulWidget {
  const LogbookFormScreen({
    super.key,
    required this.sessionId,
    required this.durationSeconds,
    required this.distractionScore,
  });

  final int sessionId;
  final int durationSeconds;
  final int distractionScore;

  @override
  State<LogbookFormScreen> createState() => _LogbookFormScreenState();
}

class _LogbookFormScreenState extends State<LogbookFormScreen> {
  double _before = 5;
  double _after = 5;
  final _bodyController = TextEditingController();
  final _helpfulController = TextEditingController();
  final Map<String, int> _answers = {
    'mood': 3,
    'energy': 3,
    'focus': 3,
    'teaching_readiness': 3,
  };
  bool _saving = false;

  static const _questions = [
    ('mood', 'Suasana hati saya hari ini terasa stabil.'),
    ('energy', 'Energi saya cukup untuk melanjutkan aktivitas.'),
    ('focus', 'Saya mampu kembali fokus setelah latihan.'),
    ('teaching_readiness', 'Saya merasa siap hadir lebih tenang di kelas.'),
  ];

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await Api.finishSession(
        sessionId: widget.sessionId,
        durationSeconds: widget.durationSeconds,
        distractionScore: widget.distractionScore,
        calmnessBefore: _before.round(),
        calmnessAfter: _after.round(),
        reflection: _bodyController.text.trim(),
        bodyNote: _bodyController.text.trim(),
        helpfulNote: _helpfulController.text.trim(),
        logbookAnswers: _answers,
      );
      if (mounted) {
        requestDashboardRefresh();
        requestTeacherTab(0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logbook tersimpan. Kerja bagus!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _helpfulController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.durationSeconds ~/ 60;
    final seconds = widget.durationSeconds % 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Logbook Hari Ini')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 22),
              child: Text(
                'Ringkasan sesi berhasil dicatat otomatis.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    icon: Icons.schedule,
                    label: 'Durasi Latihan',
                    value: '$minutes:${seconds.toString().padLeft(2, '0')}',
                    caption: 'menit',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricTile(
                    icon: Icons.show_chart,
                    label: 'Skor Distraksi',
                    value: '${widget.distractionScore}',
                    caption: 'kali',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Waktu Sesi',
                    value: TimeOfDay.now().format(context),
                    caption: 'WIB',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Skala Ketenangan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                children: [
                  _CalmnessSlider(
                    title: 'Sebelum',
                    question: 'Seberapa tenang sebelum latihan?',
                    value: _before,
                    onChanged: (v) => setState(() => _before = v),
                  ),
                  const Divider(height: 30),
                  _CalmnessSlider(
                    title: 'Sesudah',
                    question: 'Seberapa tenang setelah latihan?',
                    value: _after,
                    onChanged: (v) => setState(() => _after = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Refleksi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                children: [
                  _ReflectionField(
                    controller: _bodyController,
                    label: 'Apa yang dirasakan tubuh saat ini?',
                  ),
                  const Divider(height: 34),
                  _ReflectionField(
                    controller: _helpfulController,
                    label: 'Apa yang paling membantu hari ini?',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Kuesioner Harian',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                children: [
                  for (final question in _questions) ...[
                    _DailyQuestion(
                      text: question.$2,
                      value: _answers[question.$1]!,
                      onChanged: (value) =>
                          setState(() => _answers[question.$1] = value),
                    ),
                    if (question != _questions.last) const Divider(height: 28),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: AppTheme.olive),
                title: const Text(
                  'Lihat Riwayat',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LogbookHistoryScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan Logbook'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalmnessSlider extends StatelessWidget {
  const _CalmnessSlider({
    required this.title,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String question;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${value.round()}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.olive),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(question, style: Theme.of(context).textTheme.bodyMedium),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.olive,
            inactiveTrackColor: const Color(0xFFE9E9E9),
            thumbColor: AppTheme.olive,
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            label: '${value.round()}',
            onChanged: onChanged,
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('1'), Text('10')],
        ),
      ],
    );
  }
}

class _ReflectionField extends StatelessWidget {
  const _ReflectionField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Tulis jawaban Anda...',
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}

class _DailyQuestion extends StatelessWidget {
  const _DailyQuestion({
    required this.text,
    required this.value,
    required this.onChanged,
  });

  final String text;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            final score = index + 1;
            final selected = value == score;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 4 ? 0 : 8),
                child: ChoiceChip(
                  label: Center(child: Text('$score')),
                  selected: selected,
                  onSelected: (_) => onChanged(score),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
