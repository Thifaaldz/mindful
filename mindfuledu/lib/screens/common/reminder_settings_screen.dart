import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/reminder_service.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  String _channel = 'push';
  String _timezone = 'Asia/Jakarta';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      final reminder = await Api.reminderPreference();
      final parts = (reminder['time'] as String? ?? '07:00').split(':');
      setState(() {
        _enabled = reminder['enabled'] as bool? ?? false;
        _time = TimeOfDay(
          hour: int.tryParse(parts.first) ?? 7,
          minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
        );
        _channel = reminder['channel'] as String? ?? 'push';
        _timezone = reminder['timezone'] as String? ?? timezone.identifier;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected != null) setState(() => _time = selected);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      _timezone = timezone.identifier;
      final time = _formatTime(_time);

      await Api.updateReminderPreference(
        enabled: _enabled,
        time: time,
        channel: _channel,
        timezone: _timezone,
      );

      final notificationScheduled = _enabled && _channel == 'push'
          ? await ReminderService.scheduleDaily(_time)
          : false;
      final pendingCount = notificationScheduled
          ? await ReminderService.pendingCount()
          : 0;
      final pushSuffix = _channel == 'push'
          ? ' ($pendingCount jadwal aktif)'
          : '';

      if (_enabled && _channel == 'push' && !notificationScheduled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notifikasi belum diizinkan di HP. Aktifkan permission notifikasi untuk MindfulEdu.',
            ),
          ),
        );
        return;
      }

      if (_enabled && _channel != 'push') {
        await ReminderService.cancelDaily();
      } else if (!_enabled) {
        await ReminderService.cancelDaily();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _enabled
                ? 'Pengingat $_channel aktif pukul $time$pushSuffix'
                : 'Pengingat dimatikan',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menjadwalkan pengingat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Harian')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFEAF6F3),
            child: SwitchListTile(
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Aktifkan Pengingat'),
              subtitle: const Text('Jadwalkan latihan mindfulness harian.'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Waktu'),
              subtitle: Text(_formatTime(_time)),
              trailing: const Icon(Icons.edit),
              enabled: _enabled,
              onTap: _enabled ? _pickTime : null,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kanal Pengingat',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'push',
                        label: Text('Push'),
                        icon: Icon(Icons.phone_android),
                      ),
                      ButtonSegment(
                        value: 'email',
                        label: Text('Email'),
                        icon: Icon(Icons.mail_outline),
                      ),
                    ],
                    selected: {_channel},
                    onSelectionChanged: _enabled
                        ? (selection) =>
                              setState(() => _channel = selection.first)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Simpan Pengingat'),
          ),
        ],
      ),
    );
  }
}
