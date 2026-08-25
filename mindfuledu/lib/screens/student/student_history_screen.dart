import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import '../observation/student_list_screen.dart';

class StudentHistoryScreen extends StatefulWidget {
  const StudentHistoryScreen({super.key});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  Future<Map<String, dynamic>>? _future;

  Future<void> _refresh() async {
    final studentId = context.read<Session>().user?['id'] as int?;
    if (studentId == null) return;
    setState(() => _future = Api.studentObservationHistory(studentId));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final user = session.user ?? {};
    final studentId = user['id'] as int?;
    _future ??= studentId != null
        ? Api.studentObservationHistory(studentId)
        : null;

    return Scaffold(
      body: SafeArea(
        child: _future == null
            ? const Center(child: Text('Data siswa tidak ditemukan.'))
            : RefreshIndicator(
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
                          : 'Gagal memuat riwayat';
                      return ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 120),
                          Center(child: Text(message)),
                        ],
                      );
                    }

                    final items = (snapshot.data!['data'] as List? ?? [])
                        .whereType<Map>()
                        .map((item) => Map<String, dynamic>.from(item))
                        .toList();
                    final latest = items.isEmpty ? null : items.first;
                    final status = latest?['status'] as String?;

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
                                'Halo, ${user['name'] ?? 'Siswa'}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(user['class'] as Map?)?['name'] ?? 'Kelas'} • ${user['school'] ?? '-'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 24),
                              _StatusHero(status: status),
                              const SizedBox(height: 26),
                              _StudentSummary(items: items),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        const SectionTitle('Riwayat Observasi'),
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 28),
                            child: SoftCard(
                              child: Text('Belum ada catatan observasi.'),
                            ),
                          )
                        else
                          ...items.map((item) => _ObservationCard(item: item)),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final label = status == null ? 'Belum Ada Data' : status!.toUpperCase();
    final color = statusColor(status);
    final message = switch (status) {
      'merah' => 'Guru akan memberi pendampingan lebih dekat.',
      'kuning' => 'Ada hal yang perlu diperhatikan bersama guru.',
      'hijau' => 'Kondisi terlihat stabil. Pertahankan kebiasaan baik.',
      _ => 'Riwayat observasi akan muncul setelah guru mengisi checklist.',
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.favorite_outline, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(label: label, color: color),
                const SizedBox(height: 10),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentSummary extends StatelessWidget {
  const _StudentSummary({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final green = items.where((item) => item['status'] == 'hijau').length;
    final yellow = items.where((item) => item['status'] == 'kuning').length;
    final red = items.where((item) => item['status'] == 'merah').length;

    return Row(
      children: [
        Expanded(
          child: MetricTile(
            icon: Icons.eco_outlined,
            label: 'Hijau',
            value: '$green',
            caption: 'catatan',
            color: AppTheme.olive,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricTile(
            icon: Icons.flag_outlined,
            label: 'Kuning',
            value: '$yellow',
            caption: 'catatan',
            color: const Color(0xFFC49A3A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricTile(
            icon: Icons.priority_high,
            label: 'Merah',
            value: '$red',
            caption: 'catatan',
            color: const Color(0xFFB94A48),
          ),
        ),
      ],
    );
  }
}

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String?;
    final color = statusColor(status);
    final observedOn = DateTime.tryParse(item['observed_on'] as String? ?? '');
    final dateLabel = observedOn == null
        ? '-'
        : DateFormat('EEEE, d MMM yyyy').format(observedOn);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      child: SoftCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(Icons.assignment_outlined, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Status keseluruhan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusPill(label: (status ?? '-').toUpperCase(), color: color),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AspectPill(label: 'Perasaan', value: item['perasaan']),
                _AspectPill(label: 'Perilaku', value: item['perilaku']),
                _AspectPill(label: 'Tubuh', value: item['tubuh']),
                _AspectPill(label: 'Teman', value: item['teman']),
                _AspectPill(label: 'Belajar', value: item['belajar']),
              ],
            ),
            if ((item['notes'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 14),
              Text('Catatan: ${item['notes']}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _AspectPill extends StatelessWidget {
  const _AspectPill({required this.label, required this.value});

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    final status = value as String?;
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('$label: ${status ?? '-'}'),
        ],
      ),
    );
  }
}
