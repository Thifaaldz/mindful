import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Map<String, dynamic>? loginHistoryMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String loginHistoryDate(dynamic value) {
  final parsed = value is String ? DateTime.tryParse(value) : null;
  if (parsed == null) return '-';
  return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(parsed.toLocal());
}

String loginHistoryDevice(Map<String, dynamic> login) {
  final device = '${login['device_name'] ?? ''}'.trim();
  final brand = '${login['device_brand'] ?? ''}'.trim();
  final model = '${login['device_model'] ?? ''}'.trim();
  final merged = [
    brand,
    model,
  ].where((part) => part.isNotEmpty && part != '-').join(' ');
  if (device.isNotEmpty && device != '-') return device;
  if (merged.isNotEmpty) return merged;
  return '${login['device_platform'] ?? 'Perangkat'}';
}

class LastLoginCaption extends StatelessWidget {
  const LastLoginCaption({super.key, required this.login, required this.color});

  final Map<String, dynamic>? login;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final latest = login;
    if (latest == null) return const SizedBox.shrink();

    final location = '${latest['location'] ?? 'Jakarta'}';
    final device = loginHistoryDevice(latest);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.security_outlined, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Last login ${loginHistoryDate(latest['logged_in_at'])} - $location - $device',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class LoginHistoryCard extends StatelessWidget {
  const LoginHistoryCard({
    super.key,
    required this.histories,
    required this.color,
  });

  final List<dynamic> histories;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final items = histories
        .map(loginHistoryMap)
        .whereType<Map<String, dynamic>>();
    final visible = items.take(8).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_outlined, color: color),
                const SizedBox(width: 10),
                Text(
                  'History Login',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final item in visible)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(Icons.phone_android_outlined, color: color),
                ),
                title: Text(loginHistoryDevice(item)),
                subtitle: Text(
                  '${item['location'] ?? 'Jakarta'} - ${loginHistoryDate(item['logged_in_at'])}',
                ),
                trailing: item['revoked_previous_sessions'] == true
                    ? Tooltip(
                        message: 'Device lama otomatis logout',
                        child: Icon(Icons.logout_outlined, color: color),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
