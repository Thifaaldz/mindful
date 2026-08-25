import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../widgets/app_chrome.dart';
import 'checklist_screen.dart';
import 'student_list_screen.dart';

class ObservationHomeScreen extends StatefulWidget {
  const ObservationHomeScreen({super.key});

  @override
  State<ObservationHomeScreen> createState() => _ObservationHomeScreenState();
}

class _ObservationHomeScreenState extends State<ObservationHomeScreen> {
  late Future<_ObservationData> _future;
  int? _selectedClassId;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ObservationData> _load() async {
    final classes = _asMapList(await Api.classes());
    if (classes.isEmpty) {
      _selectedClassId = null;
      return const _ObservationData(classes: [], students: []);
    }

    final ids = classes.map((item) => item['id']).whereType<int>().toList();
    if (_selectedClassId == null || !ids.contains(_selectedClassId)) {
      _selectedClassId = ids.first;
    }

    final students = _selectedClassId == null
        ? <Map<String, dynamic>>[]
        : _asMapList(await Api.studentsInClass(_selectedClassId!));
    return _ObservationData(classes: classes, students: students);
  }

  void _reload() {
    setState(() => _future = _load());
  }

  void _selectClass(int? classId) {
    if (classId == null) return;
    setState(() {
      _selectedClassId = classId;
      _future = _load();
    });
  }

  Future<void> _openChecklist(
    Map<String, dynamic> student,
    String className,
  ) async {
    final classId = _selectedClassId;
    final studentId = student['id'];
    if (classId == null || studentId is! int) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChecklistScreen(
          classId: classId,
          studentId: studentId,
          studentName: '${student['name'] ?? 'Siswa'}',
          className: className,
        ),
      ),
    );
    _reload();
  }

  void _showStudentPicker(_ObservationData data, String className) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: data.students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final student = data.students[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.line),
                ),
                leading: _StudentAvatar(name: '${student['name'] ?? 'S'}'),
                title: Text(
                  '${student['name'] ?? 'Siswa'}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(className),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  _openChecklist(student, className);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FutureBuilder<_ObservationData>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null || data.students.isEmpty) return const SizedBox();
          final className = data.classNameFor(_selectedClassId);
          return FloatingActionButton.extended(
            onPressed: () => _showStudentPicker(data, className),
            icon: const Icon(Icons.add),
            label: const Text('Checklist Baru'),
          );
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _reload();
            await _future;
          },
          child: FutureBuilder<_ObservationData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                final message = snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : 'Gagal memuat observasi';
                return _MessageState(message: message, onRetry: _reload);
              }

              final data = snapshot.data ?? const _ObservationData();
              if (data.classes.isEmpty) {
                return _MessageState(
                  message: 'Belum ada kelas yang terhubung.',
                  onRetry: _reload,
                );
              }

              final selectedClassName = data.classNameFor(_selectedClassId);
              final students = data.filteredStudents(_search);

              return ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  const BrandHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _CircleButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.maybePop(context),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'Observasi Siswa',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(width: 56),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: DropdownButtonFormField<int>(
                                initialValue: _selectedClassId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                ),
                                items: data.classes
                                    .map(
                                      (item) => DropdownMenuItem<int>(
                                        value: item['id'] as int,
                                        child: Text(
                                          '${item['name'] ?? 'Kelas'}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _selectClass,
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
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        if (students.isEmpty)
                          SoftCard(
                            child: Text(
                              _search.trim().isEmpty
                                  ? 'Belum ada siswa di $selectedClassName.'
                                  : 'Siswa tidak ditemukan.',
                            ),
                          )
                        else
                          for (final student in students) ...[
                            _ObservationStudentCard(
                              student: student,
                              className: selectedClassName,
                              onTap: () =>
                                  _openChecklist(student, selectedClassName),
                            ),
                            const SizedBox(height: 14),
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

class _ObservationData {
  const _ObservationData({this.classes = const [], this.students = const []});

  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> students;

  String classNameFor(int? classId) {
    final match = classes.where((item) => item['id'] == classId).firstOrNull;
    return '${match?['name'] ?? 'Kelas'}';
  }

  List<Map<String, dynamic>> filteredStudents(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return students;
    return students.where((student) {
      final name = '${student['name'] ?? ''}'.toLowerCase();
      return name.contains(value);
    }).toList();
  }
}

class _ObservationStudentCard extends StatelessWidget {
  const _ObservationStudentCard({
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
            _StudentAvatar(name: '${student['name'] ?? 'S'}'),
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
                    style: Theme.of(context).textTheme.bodyMedium,
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
    if (observedOn.isNotEmpty) {
      return 'Observasi terakhir pada $observedOn.';
    }

    return 'Belum ada catatan observasi untuk $className.';
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.name});

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

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.ink),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});

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
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
