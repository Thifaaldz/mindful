import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';

class _QuestionItem {
  const _QuestionItem(this.id, this.section, this.text);

  final String id;
  final String section;
  final String text;
}

const _questions = [
  _QuestionItem(
    'dashboard_easy',
    'Dashboard',
    'Informasi yang ditampilkan pada Dashboard MindfulEdu mudah dipahami.',
  ),
  _QuestionItem(
    'dashboard_chart',
    'Dashboard',
    'Grafik tren ketenangan membantu saya memahami perkembangan latihan.',
  ),
  _QuestionItem(
    'dashboard_stats',
    'Dashboard',
    'Ringkasan statistik membantu saya melihat dampak latihan mindfulness.',
  ),
  _QuestionItem(
    'session_instruction',
    'Sesi Mindfulness',
    'Petunjuk setiap langkah pada Sesi Mindfulness mudah diikuti.',
  ),
  _QuestionItem(
    'session_timer',
    'Sesi Mindfulness',
    'Timer membantu saya mengetahui durasi latihan.',
  ),
  _QuestionItem(
    'session_counter',
    'Sesi Mindfulness',
    'Tombol +1 Distraksi memudahkan saya mencatat gangguan fokus.',
  ),
  _QuestionItem(
    'session_audio',
    'Sesi Mindfulness',
    'Panduan suara membantu saya mengikuti latihan dengan lebih nyaman.',
  ),
  _QuestionItem(
    'logbook_scale',
    'Logbook',
    'Skala ketenangan sebelum dan sesudah latihan mudah digunakan.',
  ),
  _QuestionItem(
    'logbook_reflection',
    'Logbook',
    'Fitur refleksi membantu saya mengevaluasi kondisi setelah latihan.',
  ),
  _QuestionItem(
    'logbook_history',
    'Logbook',
    'Riwayat logbook membantu saya melihat pola latihan dari waktu ke waktu.',
  ),
  _QuestionItem(
    'toolkit_stop',
    'Toolkit',
    'Panduan Teknik STOP mudah ditemukan saat dibutuhkan.',
  ),
  _QuestionItem(
    'toolkit_grounding',
    'Toolkit',
    'Grounding 3-2-1 relevan untuk membantu menenangkan diri.',
  ),
  _QuestionItem(
    'toolkit_tactics',
    'Toolkit',
    'Taktik Mindful Lecturing sesuai dengan kebutuhan guru di kelas.',
  ),
  _QuestionItem(
    'observation_students',
    'Observasi Siswa',
    'Daftar siswa dan kelas memudahkan saya melakukan observasi.',
  ),
  _QuestionItem(
    'observation_checklist',
    'Observasi Siswa',
    'Checklist lima area mudah digunakan untuk menilai kondisi siswa.',
  ),
  _QuestionItem(
    'observation_status',
    'Observasi Siswa',
    'Indikator Hijau, Kuning, dan Merah mudah dipahami.',
  ),
  _QuestionItem(
    'observation_recommendation',
    'Observasi Siswa',
    'Rekomendasi tindakan membantu saya menentukan tindak lanjut.',
  ),
  _QuestionItem(
    'ui_consistency',
    'Usability dan UI/UX',
    'Tampilan aplikasi terasa nyaman dan konsisten.',
  ),
  _QuestionItem(
    'navigation_easy',
    'Usability dan UI/UX',
    'Perpindahan antarhalaman mudah dilakukan.',
  ),
  _QuestionItem(
    'feature_fit',
    'Usability dan UI/UX',
    'Fitur yang tersedia sesuai dengan kebutuhan pengguna.',
  ),
  _QuestionItem(
    'satisfaction',
    'Penerimaan Pengguna',
    'Saya puas dengan aplikasi MindfulEdu secara keseluruhan.',
  ),
  _QuestionItem(
    'intention',
    'Penerimaan Pengguna',
    'Saya bersedia menggunakan MindfulEdu apabila diterapkan di sekolah.',
  ),
];

const _likertLabels = {
  1: 'Sangat Tidak Setuju',
  2: 'Tidak Setuju',
  3: 'Netral',
  4: 'Setuju',
  5: 'Sangat Setuju',
};

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _commentController = TextEditingController();
  final _professionController = TextEditingController(text: 'Guru');
  final Map<String, int> _answers = {
    for (final question in _questions) question.id: 4,
  };
  String _ageRange = '25-34';
  String _teachingExperience = '1-5 tahun';
  String _similarAppExperience = 'Belum pernah';
  bool _saving = false;

  @override
  void dispose() {
    _commentController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final result = await Api.submitQuestionnaire(
        respondentProfile: {
          'age_range': _ageRange,
          'profession': _professionController.text.trim(),
          'teaching_experience': _teachingExperience,
          'similar_app_experience': _similarAppExperience,
        },
        answers: _answers,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;
      final response = result['response'] as Map<String, dynamic>;
      final percentage = response['percentage_score'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kuesioner tersimpan. Skor: $percentage%')),
      );
      Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    final grouped = <String, List<_QuestionItem>>{};
    for (final question in _questions) {
      grouped.putIfAbsent(question.section, () => []).add(question);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kuesioner Evaluasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _IntroPanel(
            score: _answers.values.reduce((a, b) => a + b),
            maxScore: _questions.length * 5,
          ),
          const SizedBox(height: 16),
          _ProfileFields(
            ageRange: _ageRange,
            teachingExperience: _teachingExperience,
            similarAppExperience: _similarAppExperience,
            professionController: _professionController,
            onAgeChanged: (value) => setState(() => _ageRange = value),
            onTeachingExperienceChanged: (value) =>
                setState(() => _teachingExperience = value),
            onSimilarAppExperienceChanged: (value) =>
                setState(() => _similarAppExperience = value),
          ),
          const SizedBox(height: 16),
          for (final entry in grouped.entries) ...[
            _SectionHeader(title: entry.key),
            const SizedBox(height: 8),
            for (final question in entry.value)
              _QuestionCard(
                question: question,
                value: _answers[question.id]!,
                onChanged: (value) =>
                    setState(() => _answers[question.id] = value),
              ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Saran atau komentar',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: const Text('Kirim Kuesioner'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({required this.score, required this.maxScore});

  final int score;
  final int maxScore;

  @override
  Widget build(BuildContext context) {
    final percentage = ((score / maxScore) * 100).round();

    return Card(
      color: const Color(0xFFEAF6F3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF4F8A8B),
              foregroundColor: Colors.white,
              child: Icon(Icons.fact_check_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evaluasi Usability dan Penerimaan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Skor sementara $percentage%. Jawab berdasarkan pengalaman mencoba prototype.',
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

class _ProfileFields extends StatelessWidget {
  const _ProfileFields({
    required this.ageRange,
    required this.teachingExperience,
    required this.similarAppExperience,
    required this.professionController,
    required this.onAgeChanged,
    required this.onTeachingExperienceChanged,
    required this.onSimilarAppExperienceChanged,
  });

  final String ageRange;
  final String teachingExperience;
  final String similarAppExperience;
  final TextEditingController professionController;
  final ValueChanged<String> onAgeChanged;
  final ValueChanged<String> onTeachingExperienceChanged;
  final ValueChanged<String> onSimilarAppExperienceChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: professionController,
              decoration: const InputDecoration(
                labelText: 'Profesi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Rentang Usia',
              value: ageRange,
              values: const ['18-24', '25-34', '35-44', '45-54', '55+'],
              onChanged: onAgeChanged,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Lama Mengajar',
              value: teachingExperience,
              values: const [
                '< 1 tahun',
                '1-5 tahun',
                '6-10 tahun',
                '> 10 tahun',
              ],
              onChanged: onTeachingExperienceChanged,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Pengalaman Aplikasi Sejenis',
              value: similarAppExperience,
              values: const ['Belum pernah', 'Pernah sedikit', 'Sering'],
              onChanged: onSimilarAppExperienceChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: const Color(0xFF2F6F73),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final _QuestionItem question;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var score = 1; score <= 5; score++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: score == 5 ? 0 : 6),
                      child: ChoiceChip(
                        label: Center(child: Text('$score')),
                        selected: value == score,
                        onSelected: (_) => onChanged(score),
                        selectedColor: const Color(0xFFB7DED7),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _likertLabels[value]!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF4F8A8B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
