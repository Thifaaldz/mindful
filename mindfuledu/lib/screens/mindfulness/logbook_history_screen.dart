import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../widgets/app_chrome.dart';

class LogbookHistoryScreen extends StatefulWidget {
  const LogbookHistoryScreen({super.key});

  @override
  State<LogbookHistoryScreen> createState() => _LogbookHistoryScreenState();
}

class _LogbookHistoryScreenState extends State<LogbookHistoryScreen> {
  late Future<Map<String, dynamic>> _future;
  String _filter = 'Minggu Ini';

  @override
  void initState() {
    super.initState();
    _future = Api.sessionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
              return Center(child: Text(message));
            }

            final items = (snapshot.data!['data'] as List? ?? [])
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            if (items.isEmpty) {
              return const Center(child: Text('Belum ada riwayat latihan.'));
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const BrandHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                  child: Wrap(
                    spacing: 10,
                    children: ['Minggu Ini', 'Bulan Ini', 'Semua']
                        .map(
                          (label) => ChoiceChip(
                            label: Text(label),
                            selected: _filter == label,
                            onSelected: (_) => setState(() => _filter = label),
                          ),
                        )
                        .toList(),
                  ),
                ),
                _DateStrip(items: items),
                const SizedBox(height: 20),
                ...items.map((item) => _HistoryCard(session: item)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final dates = items
        .take(7)
        .map((item) {
          return DateTime.tryParse(
            item['started_at'] as String? ?? '',
          )?.toLocal();
        })
        .whereType<DateTime>()
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dates.map((date) {
            final selected = date.day == DateTime.now().day;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.olive : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : AppTheme.olive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.session});

  final Map<String, dynamic> session;

  @override
  Widget build(BuildContext context) {
    final startedAt = DateTime.tryParse(
      session['started_at'] as String? ?? '',
    )?.toLocal();
    final dateLabel = startedAt == null
        ? '-'
        : DateFormat('EEEE, d MMM yyyy').format(startedAt);
    final timeLabel = startedAt == null
        ? '-'
        : DateFormat('HH:mm').format(startedAt);
    final duration = ((session['duration_seconds'] as num? ?? 0) / 60).round();
    final bodyNote = session['body_note'] ?? session['reflection'] ?? '-';

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 18),
      child: SoftCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFF1F2F0),
                  child: Icon(Icons.article_outlined, color: AppTheme.olive),
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
                        timeLabel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _MiniMetric(
                    label: 'Durasi',
                    value: '$duration',
                    suffix: 'mnt',
                  ),
                  _MiniMetric(
                    label: 'Sebelum',
                    value: '${session['calmness_before'] ?? '-'}',
                    suffix: '/10',
                  ),
                  _MiniMetric(
                    label: 'Sesudah',
                    value: '${session['calmness_after'] ?? '-'}',
                    suffix: '/10',
                    color: AppTheme.olive,
                  ),
                  _MiniMetric(
                    label: 'Distraksi',
                    value: '${session['distraction_score'] ?? '-'}',
                    suffix: 'kali',
                    color: const Color(0xFFE76F51),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Refleksi: $bodyNote',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.suffix,
    this.color = AppTheme.ink,
  });

  final String label;
  final String value;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                TextSpan(text: ' $suffix'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
