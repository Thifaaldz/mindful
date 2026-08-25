import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../widgets/app_chrome.dart';
import 'checklist_screen.dart';

Color statusColor(String? status) {
  switch (status) {
    case 'merah':
      return const Color(0xFFE86C58);
    case 'kuning':
      return const Color(0xFFE9BE51);
    case 'hijau':
      return const Color(0xFF78B69B);
    default:
      return AppTheme.muted;
  }
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  final int classId;
  final String className;

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late Future<List<dynamic>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = Api.studentsInClass(widget.classId);
  }

  Future<void> _openChecklist(Map<String, dynamic> student) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChecklistScreen(
          classId: widget.classId,
          studentId: student['id'] as int,
          studentName: '${student['name'] ?? 'Siswa'}',
          className: widget.className,
        ),
      ),
    );
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat siswa';
              return _StateCard(
                message: message,
                onRetry: () => setState(_load),
              );
            }

            final students = _filter(_asMapList(snapshot.data), _search);
            return RefreshIndicator(
              onRefresh: () async {
                setState(_load);
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  const BrandHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            Expanded(
                              child: Text(
                                'Observasi Siswa',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            SizedBox(
                              width: 122,
                              child: TextField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: widget.className,
                                  suffixIcon: const Icon(
                                    Icons.keyboard_arrow_down,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() => _search = value);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Cari siswa',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        if (students.isEmpty)
                          const SoftCard(child: Text('Belum ada siswa.'))
                        else
                          for (final student in students) ...[
                            _StudentObservationCard(
                              student: student,
                              className: widget.className,
                              onTap: () => _openChecklist(student),
                            ),
                            const SizedBox(height: 14),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filter(
    List<Map<String, dynamic>> students,
    String query,
  ) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return students;
    return students
        .where(
          (student) => '${student['name'] ?? ''}'.toLowerCase().contains(value),
        )
        .toList();
  }
}

class _StudentObservationCard extends StatelessWidget {
  const _StudentObservationCard({
    required this.student,
    required this.className,
    required this.onTap,
  });

  final Map<String, dynamic> student;
  final String className;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = student['latest_status'] as String?;
    final color = statusColor(status);
    final warning = status == 'merah';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: warning ? const Color(0xFFFFF4EF) : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: warning ? const Color(0xFFFFDED4) : const Color(0xFFF0F1EF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(name: '${student['name'] ?? 'S'}'),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${student['name'] ?? 'Siswa'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      StatusPill(label: _statusLabel(status), color: color),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _latestNote(student, className),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (warning) Icon(Icons.error_outline, color: color, size: 18),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }

  String _latestNote(Map<String, dynamic> student, String className) {
    final note = '${student['latest_notes'] ?? ''}'.trim();
    if (note.isNotEmpty) return 'Catatan terbaru: $note';
    final observedOn = '${student['latest_observed_on'] ?? ''}'.trim();
    if (observedOn.isNotEmpty) return 'Observasi terakhir pada $observedOn.';
    return 'Belum ada catatan observasi untuk $className.';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 27,
      backgroundColor: AppTheme.mint,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppTheme.olive,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const BrandHeader(),
        const SizedBox(height: 88),
        SoftCard(
          child: Column(
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _statusLabel(String? status) {
  return switch (status) {
    'merah' => 'Merah',
    'kuning' => 'Kuning',
    'hijau' => 'Hijau',
    _ => 'Baru',
  };
}

List<Map<String, dynamic>> _asMapList(List<dynamic>? data) {
  return (data ?? [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}
