import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/account_role.dart';
import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/login_history_widgets.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  DateTime _date = DateTime.now();
  late Future<Map<String, dynamic>> _future;

  String get _dateParam => DateFormat('yyyy-MM-dd').format(_date);

  @override
  void initState() {
    super.initState();
    _future = Api.parentDashboard(date: _dateParam);
  }

  void _refresh() {
    setState(() => _future = Api.parentDashboard(date: _dateParam));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _future = Api.parentDashboard(date: _dateParam);
    });
  }

  Future<void> _linkChild() async {
    final linked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _LinkChildSheet(),
    );
    if (linked == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<Session>().user;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BrandHeader(
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Pilih tanggal',
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                  IconButton(
                    tooltip: 'Tambah anak',
                    onPressed: _linkChild,
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      final message = snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : '${snapshot.error}';
                      return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _EmptyState(
                            icon: Icons.wifi_off,
                            title: 'Data belum terbuka',
                            message: message,
                          ),
                        ],
                      );
                    }

                    final data = snapshot.data ?? const <String, dynamic>{};
                    final children = (data['children'] as List? ?? [])
                        .cast<dynamic>();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      children: [
                        _DateHeader(date: _date),
                        const SizedBox(height: 8),
                        LastLoginCaption(
                          login: loginHistoryMap(user?['latest_login']),
                          color: AccountRole.parent.primary,
                        ),
                        const SizedBox(height: 16),
                        if (children.isEmpty)
                          const _EmptyState(
                            icon: Icons.family_restroom,
                            title: 'Belum ada anak tertaut',
                            message:
                                'Masukkan kode verifikasi dari akun siswa.',
                          )
                        else
                          for (final child in children)
                            _ChildMonitoringCard(data: _map(child)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.today, color: AppTheme.olive),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _ChildMonitoringCard extends StatelessWidget {
  const _ChildMonitoringCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final student = _map(data['student']);
    final analysis = _map(data['analysis']);
    final recommendation = _map(analysis['recommendation_summary']);
    final category = '${analysis['category'] ?? 'belum cukup'}';
    final activities = (data['activities'] as List? ?? []).cast<dynamic>();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _categoryColor(
                    category,
                  ).withValues(alpha: .14),
                  child: Icon(Icons.backpack, color: _categoryColor(category)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student['name'] ?? 'Siswa'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${student['school'] ?? '-'}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                _StatusPill(category: category),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '${recommendation['headline'] ?? 'Belum ada rekomendasi'}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${recommendation['action'] ?? 'Lengkapi check-in dan check-out siswa untuk membuka rekomendasi.'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              Text(
                'Belum ada aktivitas pada tanggal ini.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
              )
            else
              for (final item in activities)
                _ActivityLine(activity: _map(item)),
          ],
        ),
      ),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.activity});

  final Map<String, dynamic> activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${activity['title'] ?? 'Aktivitas'}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TinyChip(
                icon: Icons.login,
                label: 'Check-in: ${activity['checkin_mood'] ?? '-'}',
              ),
              _TinyChip(
                icon: Icons.logout,
                label: 'Check-out: ${activity['checkout_mood'] ?? '-'}',
              ),
              if (activity['teacher'] != null)
                _TinyChip(
                  icon: Icons.school,
                  label: 'Guru: ${_map(activity['teacher'])['name'] ?? '-'}',
                ),
            ],
          ),
          if ('${activity['checkout_suggestion'] ?? ''}'.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${activity['checkout_suggestion']}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkChildSheet extends StatefulWidget {
  const _LinkChildSheet();

  @override
  State<_LinkChildSheet> createState() => _LinkChildSheetState();
}

class _LinkChildSheetState extends State<_LinkChildSheet> {
  final _schoolController = TextEditingController();
  final _codeController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _schoolController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_schoolController.text.trim().isEmpty ||
        _codeController.text.trim().isEmpty) {
      setState(() => _error = 'Sekolah dan kode wajib diisi.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await Api.linkParentChild(
        school: _schoolController.text.trim(),
        studentVerificationCode: _codeController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tambah Anak', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(
            controller: _schoolController,
            decoration: const InputDecoration(
              labelText: 'Sekolah anak',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Kode verifikasi siswa',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _categoryLabel(category),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TinyChip extends StatelessWidget {
  const _TinyChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.muted),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          Icon(icon, size: 46, color: AppTheme.muted),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return <String, dynamic>{};
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
    'hijau' => AppTheme.olive,
    'kuning' => const Color(0xFFD9973A),
    'merah' => const Color(0xFFC65A4A),
    _ => AppTheme.muted,
  };
}
