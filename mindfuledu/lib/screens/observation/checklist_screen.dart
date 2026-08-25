import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../widgets/app_chrome.dart';
import 'student_list_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({
    super.key,
    required this.classId,
    required this.studentId,
    required this.studentName,
    this.className,
  });

  final int classId;
  final int studentId;
  final String studentName;
  final String? className;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final Map<String, String> _answers = {
    'perasaan': 'hijau',
    'perilaku': 'hijau',
    'tubuh': 'hijau',
    'teman': 'hijau',
    'belajar': 'hijau',
  };
  final _notesController = TextEditingController();
  bool _saving = false;

  static const _areas = [
    ('perasaan', 'Perasaan', Icons.favorite_border),
    ('perilaku', 'Perilaku', Icons.psychology_outlined),
    ('tubuh', 'Tubuh', Icons.accessibility_new),
    ('teman', 'Teman', Icons.groups_outlined),
    ('belajar', 'Belajar', Icons.menu_book_outlined),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String get _overallStatus {
    if (_answers.values.contains('merah')) return 'merah';
    if (_answers.values.contains('kuning')) return 'kuning';
    return 'hijau';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final result = await Api.saveObservation(
        studentId: widget.studentId,
        classId: widget.classId,
        perasaan: _answers['perasaan']!,
        perilaku: _answers['perilaku']!,
        tubuh: _answers['tubuh']!,
        teman: _answers['teman']!,
        belajar: _answers['belajar']!,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            'Status ${_statusLabel(result['observation']['status'] as String?)}',
          ),
          content: Text(result['recommendation'] as String),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
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
    final status = _overallStatus;
    final className = widget.className ?? 'Kelas';

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan'),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Detail Observasi Siswa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SoftCard(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.mint,
                      child: Text(
                        _initial(widget.studentName),
                        style: const TextStyle(
                          color: AppTheme.olive,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kelas: $className',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Tanggal: Hari ini',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Status Keseluruhan',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        StatusPill(
                          label: _statusLabel(status),
                          color: statusColor(status),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Checklist PFA',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F2),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'ASPEK',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            'PILIH STATUS',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    for (final area in _areas)
                      _ChecklistArea(
                        icon: area.$3,
                        label: area.$2,
                        value: _answers[area.$1]!,
                        onChanged: (value) {
                          setState(() => _answers[area.$1] = value);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Catatan Kasus',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.info_outline, size: 18),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText:
                            'Tulis catatan observasi secara ringkas, objektif, dan faktual...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Rekomendasi Tindakan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.info_outline, size: 18),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final item in _recommendations(status)) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(item)),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistArea extends StatelessWidget {
  const _ChecklistArea({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF0F1EF),
                child: Icon(icon, color: AppTheme.ink, size: 19),
              ),
              const SizedBox(width: 12),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChoice(
                label: 'Hijau',
                value: 'hijau',
                selectedValue: value,
                onChanged: onChanged,
              ),
              _StatusChoice(
                label: 'Kuning',
                value: 'kuning',
                selectedValue: value,
                onChanged: onChanged,
              ),
              _StatusChoice(
                label: 'Merah',
                value: 'merah',
                selectedValue: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedValue;
    final color = statusColor(value);

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.11) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.42) : AppTheme.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? color : AppTheme.muted),
                color: selected ? color : Colors.transparent,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

String _initial(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? 'S' : trimmed[0].toUpperCase();
}

String _statusLabel(String? status) {
  return switch (status) {
    'merah' => 'Merah',
    'kuning' => 'Kuning',
    'hijau' => 'Hijau',
    _ => 'Baru',
  };
}

List<String> _recommendations(String status) {
  return switch (status) {
    'merah' => [
      'Dekati dengan tenang dan empatik.',
      'Pastikan keselamatan siswa dan lingkungan sekitar.',
      'Libatkan guru BK atau wali kelas segera.',
      'Catat kejadian secara faktual untuk tindak lanjut.',
    ],
    'kuning' => [
      'Dekati dengan tenang dan empatik.',
      'Tanyakan apa yang sedang dirasakan.',
      'Pantau perubahan perilaku dalam beberapa hari.',
      'Libatkan dukungan teman sebaya atau guru BK bila diperlukan.',
    ],
    _ => [
      'Berikan apresiasi atas kondisi yang stabil.',
      'Lanjutkan dukungan rutin di kelas.',
      'Ajak siswa tetap menjaga ritme belajar dan istirahat.',
    ],
  };
}
