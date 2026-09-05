import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/account_role.dart';
import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/dashboard_refresh.dart';
import '../../core/reminder_service.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import 'burnout_analysis_screen.dart';
import 'kabat_zinn_practice_screen.dart';

class ActivityHomeScreen extends StatefulWidget {
  const ActivityHomeScreen({super.key});

  @override
  State<ActivityHomeScreen> createState() => _ActivityHomeScreenState();
}

class _ActivityHomeScreenState extends State<ActivityHomeScreen> {
  DateTime _selectedDate = DateTime.now();
  late Future<_ActivityBundle> _future;
  _ActivityBundle? _lastBundle;
  final Map<String, Map<Object, Map<String, dynamic>>> _optimisticByDate = {};
  final Set<String> _scheduledReminderKeys = {};
  int _optimisticId = -1;
  int _refreshGeneration = 0;
  int _mutationGeneration = 0;
  bool _backgroundLoading = false;
  Timer? _autoRefreshTimer;
  String? _visibleDate;
  List<Map<String, dynamic>> _visibleActivities = [];
  Map<String, dynamic> _visibleSummary = <String, dynamic>{};

  String get _dateParam => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _future = _load();
    teacherActivityDateRequest.addListener(_handleDateRequest);
    activityRefreshTick.addListener(_handleRefreshRequest);
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _reload(background: true, notify: false),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    teacherActivityDateRequest.removeListener(_handleDateRequest);
    activityRefreshTick.removeListener(_handleRefreshRequest);
    super.dispose();
  }

  void _handleDateRequest() {
    final requestedDate = teacherActivityDateRequest.value;
    if (requestedDate == null || !mounted) return;

    setState(() {
      _selectedDate = requestedDate;
      _visibleDate = null;
      _future = _load();
    });
    teacherActivityDateRequest.value = null;
  }

  void _handleRefreshRequest() {
    if (!mounted) return;
    _reload();
  }

  Future<_ActivityBundle> _load({String? dateOverride}) async {
    final date = dateOverride ?? _dateParam;
    final requestGeneration = ++_refreshGeneration;
    final bundle = await _fetchBundle(date);
    if (!mounted || requestGeneration != _refreshGeneration) {
      return _bundleWithOptimisticActivities(bundle, date);
    }
    _rememberBundle(bundle, date);

    return _lastBundle ?? bundle;
  }

  Future<_ActivityBundle> _fetchBundle(String date) async {
    final activityData = await Api.activities(date: date);
    return _ActivityBundle(data: activityData);
  }

  void _rememberBundle(_ActivityBundle bundle, String date) {
    final mergedBundle = _bundleWithOptimisticActivities(bundle, date);
    _lastBundle = mergedBundle;
    if (date != _dateParam) return;

    _visibleDate = date;
    _visibleActivities = (mergedBundle.data['activities'] as List? ?? [])
        .map((item) => _jsonMap(item))
        .where((item) => item['id'] != null && !_isCancelledActivity(item))
        .toList();
    _visibleSummary = _jsonMap(mergedBundle.data['summary']);
    _syncActivityReminders(_visibleActivities);
  }

  void _reload({bool background = false, bool notify = true}) {
    if (!mounted) return;
    final date = _dateParam;
    if (background) {
      if (_backgroundLoading) return;
      final requestGeneration = ++_refreshGeneration;
      final mutationGeneration = _mutationGeneration;
      _backgroundLoading = true;
      unawaited(
        _fetchBundle(date)
            .then((bundle) {
              if (!mounted) return;
              if (requestGeneration != _refreshGeneration ||
                  mutationGeneration != _mutationGeneration) {
                return;
              }
              setState(() {
                _rememberBundle(bundle, date);
                _future = Future.value(_lastBundle ?? bundle);
              });
            })
            .catchError((_) {})
            .whenComplete(() => _backgroundLoading = false),
      );
    } else {
      setState(() {
        _visibleDate = null;
        _future = _load(dateOverride: date);
      });
    }
    if (notify) requestDashboardRefresh();
  }

  Future<void> _shiftDay(int days) async {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _visibleDate = null;
      _future = _load();
    });
  }

  Future<void> _openActivityForm({Map<String, dynamic>? activity}) async {
    final result = await Navigator.of(context).push<_ActivitySaveResult>(
      MaterialPageRoute(
        builder: (_) => _ActivityEditorScreen(
          title: activity == null ? 'Tambah Aktivitas' : 'Edit Aktivitas',
          child: _ActivityFormSheet(
            selectedDate: _selectedDate,
            activity: activity,
            nextOptimisticId: _nextOptimisticId,
          ),
        ),
      ),
    );
    if (result == null) return;

    _applyActivityResponse(result.optimisticResponse, editedActivity: activity);
    requestAnalysisRefresh();
    _snack(result.savingMessage);
    unawaited(_commitActivitySave(result, editedActivity: activity));
  }

  Future<void> _checkIn(Map<String, dynamic> activity) async {
    final result = await Navigator.of(context).push<_JournalSaveResult>(
      MaterialPageRoute(
        builder: (_) => _ActivityEditorScreen(
          title: 'Check-in Aktivitas',
          child: _WellbeingSheet(
            activity: activity,
            mode: _JournalMode.checkIn,
          ),
        ),
      ),
    );
    if (result == null) return;

    _applyActivities([result.optimisticActivity]);
    _snack('Menyimpan check-in...');
    unawaited(_commitJournalSave(result));
  }

  Future<void> _checkOut(Map<String, dynamic> activity) async {
    final result = await Navigator.of(context).push<_JournalSaveResult>(
      MaterialPageRoute(
        builder: (_) => _ActivityEditorScreen(
          title: 'Check-out Aktivitas',
          child: _WellbeingSheet(
            activity: activity,
            mode: _JournalMode.checkOut,
          ),
        ),
      ),
    );
    if (result == null) return;

    _applyActivities([result.optimisticActivity]);
    requestAnalysisRefresh();
    _snack('Menyimpan check-out...');
    unawaited(_commitJournalSave(result));
  }

  Future<void> _analyze() async {
    final analyzed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BurnoutAnalysisScreen(initialDate: _selectedDate),
      ),
    );
    if (analyzed == true && mounted) {
      _reload();
    }
  }

  Future<void> _joinClassroom() async {
    final joined = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _JoinClassroomSheet(date: _dateParam),
    );
    if (joined == null) return;

    final activity = _jsonMap(joined['activity']);
    if (activity.isNotEmpty) {
      _applyActivities([activity]);
      requestAnalysisRefresh();
      _reload(background: true);
    }
  }

  Future<void> _observeClassroom(Map<String, dynamic> activity) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _ClassroomObservationSheet(activityId: _intId(activity['id'])),
    );
  }

  Future<void> _cancel(Map<String, dynamic> activity) async {
    final id = activity['id'];
    if (_isTemporaryId(id)) {
      _applyActivities([activity], remove: true);
      _snack('Aktivitas sementara dibatalkan.');
      return;
    }

    try {
      await Api.cancelActivity(_intId(id));
      await ReminderService.cancelActivity(_intId(id));
      _applyActivities([activity], remove: true);
      requestAnalysisRefresh();
      _reload(background: true);
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _duplicate(Map<String, dynamic> activity) async {
    try {
      final duplicate = await Api.duplicateActivity(
        _intId(activity['id']),
        activityDate: _dateParam,
      );
      await _scheduleReminderFromActivity(_jsonMap(duplicate));
      _applyActivities([_jsonMap(duplicate)]);
      requestAnalysisRefresh();
      _reload(background: true);
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  int _nextOptimisticId() {
    final value = _optimisticId;
    _optimisticId--;
    return value;
  }

  Future<void> _commitActivitySave(
    _ActivitySaveResult result, {
    Map<String, dynamic>? editedActivity,
  }) async {
    try {
      final response = await result.request;
      if (!mounted) return;

      final temporaryActivities = result.optimisticActivities
          .where((activity) => _isTemporaryId(activity['id']))
          .toList();
      if (temporaryActivities.isNotEmpty) {
        _applyActivities(temporaryActivities, remove: true);
      }
      _applyActivityResponse(response, editedActivity: editedActivity);
      requestAnalysisRefresh();
      _snack(_savedMessage(response));
      if (result.scheduleReminders) {
        unawaited(_scheduleRemindersFromResponse(response));
      } else {
        unawaited(
          _scheduleReminderFromActivity(_jsonMap(response['activity'])),
        );
      }
      _reload(background: true);
    } on Object catch (error) {
      if (!mounted) return;
      final temporaryActivities = result.optimisticActivities
          .where((activity) => _isTemporaryId(activity['id']))
          .toList();
      if (temporaryActivities.isNotEmpty) {
        _applyActivities(temporaryActivities, remove: true);
      }
      if (result.rollbackActivities.isNotEmpty) {
        _applyActivities(result.rollbackActivities);
      }
      _snack(_errorMessage(error));
    }
  }

  Future<void> _commitJournalSave(_JournalSaveResult result) async {
    try {
      final response = await result.request;
      if (!mounted) return;

      _applyActivities([_jsonMap(response)]);
      if (result.mode == _JournalMode.checkOut) {
        requestAnalysisRefresh();
        _snack('Check-out dan jurnal tersimpan.');
      } else {
        _snack('Check-in tersimpan.');
      }
      _reload(background: true);
    } on Object catch (error) {
      if (!mounted) return;
      _applyActivities([result.previousActivity]);
      _snack(_errorMessage(error));
    }
  }

  void _applyActivityResponse(
    Map<String, dynamic> response, {
    Map<String, dynamic>? editedActivity,
  }) {
    final updates = _activitiesFromResponse(response);
    if (updates.isEmpty) return;

    final displayDate = updates
        .map((item) => _activityDateKey(item['activity_date']))
        .where((date) => date.isNotEmpty)
        .firstOrNull;
    if (displayDate != null && displayDate != _dateParam) {
      final parsed = DateTime.tryParse(displayDate);
      if (parsed != null) {
        setState(() {
          _selectedDate = parsed;
          _visibleDate = displayDate;
          _visibleActivities = [];
          _visibleSummary = <String, dynamic>{};
        });
      }
    }

    if (editedActivity != null) {
      final oldDate = _activityDateKey(editedActivity['activity_date']);
      final movedFromOldDate = updates.every(
        (item) => _activityDateKey(item['activity_date']) != oldDate,
      );
      if (oldDate.isNotEmpty && movedFromOldDate) {
        _rememberOptimisticActivities([editedActivity], remove: true);
      }
    }

    _forgetOptimisticActivities([?editedActivity, ...updates]);
    _applyActivities(
      updates,
      replaceActivities: editedActivity == null ? const [] : [editedActivity],
    );
  }

  void _syncActivityReminders(List<Map<String, dynamic>> activities) {
    for (final activity in activities) {
      final id = activity['id'];
      if (_isTemporaryId(id)) continue;

      final startAt = DateTime.tryParse('${activity['start_at']}');
      final endAt = DateTime.tryParse('${activity['end_at']}');
      if (id == null || startAt == null || endAt == null) continue;

      final key =
          '${_activityIdKey(id)}|${startAt.toIso8601String()}|'
          '${endAt.toIso8601String()}';
      if (_scheduledReminderKeys.contains(key)) continue;

      _scheduledReminderKeys.removeWhere(
        (item) => item.startsWith('${_activityIdKey(id)}|'),
      );
      _scheduledReminderKeys.add(key);

      unawaited(
        _scheduleReminderFromActivity(activity).catchError((_) {
          _scheduledReminderKeys.remove(key);
        }),
      );
    }
  }

  List<Map<String, dynamic>> _activitiesFromResponse(
    Map<String, dynamic> response,
  ) {
    final activities = response['activities'];
    if (activities is List && activities.isNotEmpty) {
      return activities
          .map((item) => _jsonMap(item))
          .where((item) => item['id'] != null)
          .toList();
    }

    final activity = _jsonMap(response['activity']);
    return activity['id'] == null ? [] : [activity];
  }

  void _forgetOptimisticActivities(List<Map<String, dynamic>> activities) {
    if (activities.isEmpty || _optimisticByDate.isEmpty) return;

    final removeDates = <String>[];
    for (final dateEntry in _optimisticByDate.entries) {
      dateEntry.value.removeWhere(
        (_, item) => activities.any(
          (activity) => _matchesActivityIdentity(item, activity),
        ),
      );
      if (dateEntry.value.isEmpty) removeDates.add(dateEntry.key);
    }

    for (final date in removeDates) {
      _optimisticByDate.remove(date);
    }
  }

  void _rememberOptimisticActivities(
    List<Map<String, dynamic>> updates, {
    bool remove = false,
  }) {
    for (final update in updates) {
      final id = update['id'];
      if (id == null) continue;
      if (!remove) {
        _forgetOptimisticActivities([update]);
      }
      final idKey = _activityIdKey(id);
      final date = _activityDateKey(update['activity_date']);
      if (date.isEmpty) continue;

      final byId = _optimisticByDate.putIfAbsent(
        date,
        () => <Object, Map<String, dynamic>>{},
      );
      if (remove && _isTemporaryId(id)) {
        byId.remove(idKey);
        if (byId.isEmpty) _optimisticByDate.remove(date);
        continue;
      }

      byId[idKey] = remove ? {...update, 'status': 'cancelled'} : update;
    }
  }

  _ActivityBundle _bundleWithOptimisticActivities(
    _ActivityBundle bundle,
    String date,
  ) {
    final optimistic = _optimisticByDate[date];
    if (optimistic == null || optimistic.isEmpty) return bundle;

    final data = Map<String, dynamic>.from(bundle.data);
    final byId = <Object, Map<String, dynamic>>{};
    for (final item in data['activities'] as List? ?? []) {
      final activity = _jsonMap(item);
      final id = activity['id'];
      if (id != null && !_isCancelledActivity(activity)) {
        byId[_activityIdKey(id)] = activity;
      }
    }

    for (final entry in optimistic.entries) {
      final activity = entry.value;
      final status = '${activity['status'] ?? 'planned'}';
      if (status == 'cancelled') {
        byId.remove(entry.key);
      } else {
        final fingerprint = _activityFingerprint(activity);
        if (_isTemporaryId(entry.key) &&
            byId.values.any(
              (item) => _activityFingerprint(item) == fingerprint,
            )) {
          continue;
        }
        byId.removeWhere(
          (id, item) =>
              _isTemporaryId(id) && _activityFingerprint(item) == fingerprint,
        );
        byId[entry.key] = activity;
      }
    }

    final activities = byId.values.toList()
      ..sort((a, b) => '${a['start_at']}'.compareTo('${b['start_at']}'));
    data['activities'] = activities;
    data['summary'] = _summaryFromActivities(activities);

    return _ActivityBundle(data: data);
  }

  void _applyActivities(
    List<Map<String, dynamic>> updates, {
    bool remove = false,
    List<Map<String, dynamic>> replaceActivities = const [],
  }) {
    if (!mounted) return;
    _mutationGeneration++;
    _refreshGeneration++;

    _rememberOptimisticActivities(updates, remove: remove);

    final currentBundle = _lastBundle;
    final data = Map<String, dynamic>.from(
      currentBundle?.data ?? {'date': _dateParam},
    );
    final current =
        (_visibleDate == _dateParam
                ? _visibleActivities
                : (data['activities'] as List? ?? []))
            .map((item) => _jsonMap(item))
            .where((item) => item['id'] != null && !_isCancelledActivity(item))
            .toList();

    if (replaceActivities.isNotEmpty) {
      current.removeWhere(
        (item) => replaceActivities.any(
          (oldActivity) => _matchesActivityIdentity(item, oldActivity),
        ),
      );
    }

    for (final update in updates) {
      final id = update['id'];
      if (id == null) continue;
      final fingerprint = _activityFingerprint(update);
      current.removeWhere(
        (item) =>
            _sameActivityId(item['id'], id) ||
            ((_isTemporaryId(item['id']) || _isTemporaryId(id)) &&
                _activityFingerprint(item) == fingerprint),
      );

      final status = '${update['status'] ?? 'planned'}';
      final date = _activityDateKey(update['activity_date']);
      if (!remove && status != 'cancelled' && date == _dateParam) {
        current.add(update);
      }
    }

    current.sort((a, b) => '${a['start_at']}'.compareTo('${b['start_at']}'));
    data['activities'] = current;
    data['summary'] = _summaryFromActivities(current);
    data['date'] = _dateParam;

    final bundle = _ActivityBundle(data: data);
    _lastBundle = bundle;
    _visibleDate = _dateParam;
    _visibleActivities = current;
    _visibleSummary = _jsonMap(data['summary']);
    setState(() => _future = Future.value(bundle));
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isBundleForSelectedDate(_ActivityBundle? bundle) {
    return bundle != null &&
        '${bundle.data['date'] ?? _dateParam}' == _dateParam;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_ActivityBundle>(
          future: _future,
          builder: (context, snapshot) {
            final cachedBundle = _isBundleForSelectedDate(_lastBundle)
                ? _lastBundle
                : null;
            final snapshotBundle = _isBundleForSelectedDate(snapshot.data)
                ? snapshot.data
                : null;
            final bundle = cachedBundle ?? snapshotBundle;
            final loading =
                snapshot.connectionState == ConnectionState.waiting &&
                bundle == null;
            final data = bundle?.data ?? <String, dynamic>{};
            final dataActivities = (data['activities'] as List? ?? [])
                .map((item) => _jsonMap(item))
                .where((item) => !_isCancelledActivity(item))
                .toList();
            final activities = _visibleDate == _dateParam
                ? _visibleActivities
                : dataActivities;
            final summary = _visibleDate == _dateParam
                ? _visibleSummary
                : _jsonMap(data['summary']);
            final latestAnalysis = _jsonMap(data['latest_analysis']);
            final session = context.watch<Session>();
            final accountRole = AccountRole.byId(session.role);

            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  BrandHeader(
                    trailing: IconButton(
                      tooltip: 'Analisis burnout',
                      onPressed: loading ? null : _analyze,
                      icon: const Icon(Icons.insights_outlined),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Activity Ledger',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'EEEE, d MMMM yyyy',
                                      'id_ID',
                                    ).format(_selectedDate),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Hari sebelumnya',
                              onPressed: () => _shiftDay(-1),
                              icon: const Icon(Icons.chevron_left),
                            ),
                            IconButton(
                              tooltip: 'Hari berikutnya',
                              onPressed: () => _shiftDay(1),
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _LedgerHero(
                          role: accountRole,
                          onAdd: () => _openActivityForm(),
                          onAnalyze: loading ? null : _analyze,
                        ),
                        if (session.isStudent) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _joinClassroom,
                            icon: const Icon(Icons.groups_outlined),
                            label: const Text('Cari kelas dari guru'),
                          ),
                        ],
                        const SizedBox(height: 18),
                        _ActivityStats(
                          role: accountRole,
                          summary: summary,
                          latestAnalysis: latestAnalysis,
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Timeline Hari Ini',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _openActivityForm(),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah'),
                            ),
                          ],
                        ),
                        if (snapshot.hasError)
                          _EmptyState(message: _errorMessage(snapshot.error))
                        else if (loading)
                          const Padding(
                            padding: EdgeInsets.only(top: 42),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (activities.isEmpty)
                          const _EmptyState(
                            message:
                                'Belum ada todo aktivitas pada tanggal ini.',
                          )
                        else
                          ...activities.map((item) {
                            final activity = _jsonMap(item);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ActivityCard(
                                activity: activity,
                                onCheckIn: () => _checkIn(activity),
                                onCheckOut: () => _checkOut(activity),
                                onEdit: () =>
                                    _openActivityForm(activity: activity),
                                onCancel: () => _cancel(activity),
                                onDuplicate: () => _duplicate(activity),
                                onObserve:
                                    session.isTeacher &&
                                        activity['activity_type'] == 'classroom'
                                    ? () => _observeClassroom(activity)
                                    : null,
                              ),
                            );
                          }),
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
}

class _LedgerHero extends StatelessWidget {
  const _LedgerHero({
    required this.role,
    required this.onAdd,
    required this.onAnalyze,
  });

  final AccountRole role;
  final VoidCallback? onAdd;
  final VoidCallback? onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: role.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: role.primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Todo-list menjadi sumber analisis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Catat aktivitas, check-in, check-out, lalu jalankan analisis periode.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.86)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            children: [
              FilledButton.tonalIcon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_task),
                label: const Text('Aktivitas'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onAnalyze,
                icon: const Icon(Icons.insights),
                label: const Text('Analisis'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityStats extends StatelessWidget {
  const _ActivityStats({
    required this.role,
    required this.summary,
    required this.latestAnalysis,
  });

  final AccountRole role;
  final Map<String, dynamic> summary;
  final Map<String, dynamic> latestAnalysis;

  @override
  Widget build(BuildContext context) {
    final category = '${latestAnalysis['category'] ?? ''}';
    return Row(
      children: [
        Expanded(
          child: MetricTile(
            icon: Icons.fact_check_outlined,
            label: 'Planned',
            value: '${summary['planned'] ?? 0}',
            caption: 'activity',
            color: role.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MetricTile(
            icon: Icons.task_alt,
            label: 'Completed',
            value: '${summary['completed'] ?? 0}',
            caption: 'ledger',
            color: const Color(0xFF24718E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MetricTile(
            icon: Icons.spa_outlined,
            label: 'Status',
            value: _categoryLabel(category),
            caption: _conditionLabel(category),
            color: _categoryColor(category),
          ),
        ),
      ],
    );
  }
}

class _ActivityEditorScreen extends StatelessWidget {
  const _ActivityEditorScreen({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: child),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onEdit,
    required this.onCancel,
    required this.onDuplicate,
    this.onObserve,
  });

  final Map<String, dynamic> activity;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onDuplicate;
  final VoidCallback? onObserve;

  @override
  Widget build(BuildContext context) {
    final role = AccountRole.byId(context.watch<Session>().role);
    final hasServerId = !_isTemporaryId(activity['id']);
    final kindText = _activityKindLabel(
      '${activity['activity_kind'] ?? activity['category'] ?? ''}'.trim(),
    );
    final timeText = _activityTimeRange(activity);
    final status = '${activity['status'] ?? 'planned'}';
    final isStudentClassroom = _isStudentClassroomActivity(activity);
    final gate = _jsonMap(activity['classroom_gate']);
    final teacherCheckinReady =
        !isStudentClassroom || gate['teacher_checkin_available'] == true;
    final teacherCheckoutReady =
        !isStudentClassroom || gate['teacher_checkout_available'] == true;
    final gateMessage = '${gate['message'] ?? ''}'.trim();
    final canCheckIn =
        hasServerId &&
        activity['checkin_at'] == null &&
        status != 'cancelled' &&
        teacherCheckinReady;
    final canCheckOut =
        hasServerId &&
        activity['checkin_at'] != null &&
        activity['checkout_at'] == null &&
        status != 'cancelled' &&
        teacherCheckoutReady;
    final detectedMood = '${activity['checkout_mood_detected'] ?? ''}'.trim();
    final suggestion = '${activity['checkout_suggestion'] ?? ''}'.trim();
    final recommendedTactic = _jsonMap(activity['recommended_tactic']);
    final crisis = activity['checkout_crisis_flag'] == true;
    final burnoutDimensions =
        (activity['checkout_auto_burnout_tags'] as List? ?? [])
            .map((item) => '$item')
            .where((item) => item.isNotEmpty)
            .toList();
    final hasAiReview = suggestion.isNotEmpty || recommendedTactic.isNotEmpty;

    void openActivityAnalysis() {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('${activity['title'] ?? 'Review AI'}'),
          scrollable: true,
          content: _ActivityAnalysisDialogContent(
            activity: activity,
            suggestion: suggestion,
            recommendedTactic: recommendedTactic,
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Tutup'),
            ),
            if (recommendedTactic.isNotEmpty)
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => KabatZinnPracticeScreen(
                        snapshot: {
                          'source': 'activity_review',
                          'category': _categoryFromActivity(activity),
                          'recommendation_summary': {
                            'practice_code': recommendedTactic['code'],
                            'practice_title': recommendedTactic['title'],
                            'practice':
                                recommendedTactic['description'] ??
                                recommendedTactic['practice'],
                            'recommended_movement':
                                recommendedTactic['recommended_movement'],
                            'why_this_tactic':
                                recommendedTactic['why_this_tactic'],
                            'tactic': recommendedTactic,
                          },
                          'tactic': recommendedTactic,
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.self_improvement),
                label: const Text('Buka Teknik'),
              ),
          ],
        ),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: role.accent.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event_note_outlined, color: role.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${activity['title'] ?? 'Aktivitas'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${kindText.isEmpty ? 'Kegiatan' : kindText} - ${timeText.isEmpty ? 'Sepanjang hari' : timeText}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (!hasServerId && value != 'cancel') return;
                  if (value == 'edit') onEdit();
                  if (value == 'duplicate') onDuplicate();
                  if (value == 'cancel') onCancel();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    enabled: hasServerId,
                    child: const Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    enabled: hasServerId,
                    child: const Text('Duplicate'),
                  ),
                  const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: _statusLabel(status),
                color: status == 'planned'
                    ? role.primary
                    : _statusColor(status),
              ),
              StatusPill(
                label: '${activity['planned_hours'] ?? 0} planned h',
                color: AppTheme.muted,
              ),
              if (activity['actual_hours'] != null)
                StatusPill(
                  label: '${activity['actual_hours']} actual h',
                  color: const Color(0xFF24718E),
                ),
              if (isStudentClassroom && gateMessage.isNotEmpty)
                StatusPill(
                  label: teacherCheckoutReady
                      ? 'Guru selesai'
                      : teacherCheckinReady
                      ? 'Guru sudah check-in'
                      : 'Menunggu guru',
                  color: teacherCheckinReady ? role.primary : AppTheme.muted,
                ),
              if (detectedMood.isNotEmpty)
                StatusPill(
                  label: 'Terdeteksi: $detectedMood',
                  color: role.primary,
                ),
              if (crisis)
                StatusPill(
                  label: 'Perlu dukungan segera',
                  color: const Color(0xFFC65A4A),
                ),
              ...burnoutDimensions.map(
                (dimension) => StatusPill(
                  label: _burnoutDimensionLabel(dimension),
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
          if (hasAiReview) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: openActivityAnalysis,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Review AI'),
            ),
          ],
          if (isStudentClassroom &&
              ((!teacherCheckinReady && activity['checkin_at'] == null) ||
                  (!teacherCheckoutReady &&
                      activity['checkin_at'] != null))) ...[
            const SizedBox(height: 10),
            Text(
              !teacherCheckinReady
                  ? 'Check-in siswa akan terbuka setelah guru check-in.'
                  : 'Check-out siswa akan terbuka setelah guru check-out.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
            ),
          ],
          const SizedBox(height: 14),
          if (onObserve != null) ...[
            OutlinedButton.icon(
              onPressed: onObserve,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Observasi siswa'),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canCheckIn ? onCheckIn : null,
                  icon: const Icon(Icons.login),
                  label: const Text('Check-in'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canCheckOut ? onCheckOut : null,
                  icon: const Icon(Icons.logout),
                  label: const Text('Check-out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityAnalysisDialogContent extends StatelessWidget {
  const _ActivityAnalysisDialogContent({
    required this.activity,
    required this.suggestion,
    required this.recommendedTactic,
  });

  final Map<String, dynamic> activity;
  final String suggestion;
  final Map<String, dynamic> recommendedTactic;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    final tacticTitle = '${recommendedTactic['title'] ?? ''}'.trim();
    final tacticDescription =
        '${recommendedTactic['description'] ?? recommendedTactic['practice'] ?? ''}'
            .trim();
    final tacticReason = '${recommendedTactic['why_this_tactic'] ?? ''}'.trim();
    final movement = '${recommendedTactic['recommended_movement'] ?? ''}'
        .trim();
    final source = '${activity['checkout_analysis_source'] ?? ''}'.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if ('${activity['checkout_mood_detected'] ?? ''}'.isNotEmpty)
              StatusPill(
                label: 'Mood: ${activity['checkout_mood_detected']}',
                color: primary,
              ),
            if (source.isNotEmpty)
              StatusPill(
                label: source == 'gemini' ? 'Berbasis AI' : 'Lokal',
                color: source == 'gemini'
                    ? const Color(0xFF24718E)
                    : AppTheme.muted,
              ),
          ],
        ),
        if (suggestion.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(suggestion),
        ],
        if (recommendedTactic.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.self_improvement, color: primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tacticTitle.isNotEmpty)
                        Text(
                          tacticTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      if (tacticDescription.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(tacticDescription),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (tacticReason.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ActivityDialogLine(
              icon: Icons.lightbulb_outline,
              text: tacticReason,
            ),
          ],
          if (movement.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ActivityDialogLine(icon: Icons.accessibility_new, text: movement),
          ],
        ],
      ],
    );
  }
}

class _ActivityDialogLine extends StatelessWidget {
  const _ActivityDialogLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

String _burnoutDimensionLabel(String dimension) {
  return _burnoutDimensionLabels[dimension] ?? dimension;
}

String _categoryFromActivity(Map<String, dynamic> activity) {
  if (activity['checkout_crisis_flag'] == true) return 'merah';

  final mood =
      '${activity['checkout_mood_detected'] ?? activity['checkout_mood'] ?? ''}';
  if (const {'cemas', 'sedih', 'marah', 'lelah'}.contains(mood)) {
    return 'kuning';
  }

  return 'hijau';
}

String _conditionLabel(String category) {
  return switch (category) {
    'hijau' => 'Stabil',
    'kuning' => 'Perlu jeda',
    'merah' => 'Butuh dukungan',
    _ => 'Belum ada',
  };
}

String _categoryLabel(String category) {
  return switch (category) {
    'hijau' => 'Hijau',
    'kuning' => 'Kuning',
    'merah' => 'Merah',
    _ => 'Belum',
  };
}

bool _isStudentClassroomActivity(Map<String, dynamic> activity) {
  return activity['teacher_activity_id'] != null ||
      activity['activity_type'] == 'classroom_student';
}

class _JoinClassroomSheet extends StatefulWidget {
  const _JoinClassroomSheet({required this.date});

  final String date;

  @override
  State<_JoinClassroomSheet> createState() => _JoinClassroomSheetState();
}

class _JoinClassroomSheetState extends State<_JoinClassroomSheet> {
  late Future<Map<String, dynamic>> _future;
  int? _joiningId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = Api.availableClassroomActivities(date: widget.date);
  }

  Future<void> _join(int id) async {
    setState(() {
      _joiningId = id;
      _error = null;
    });

    try {
      final result = await Api.joinClassroomActivity(id);
      if (mounted) Navigator.of(context).pop(result);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _joiningId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = AccountRole.byId(context.watch<Session>().role);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          final activities =
              (_jsonMap(snapshot.data)['activities'] as List? ?? [])
                  .cast<dynamic>();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Cari Kelas', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text(
                  snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                )
              else if (activities.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada kelas terbuka pada tanggal ini.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: activities.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final activity = _jsonMap(activities[index]);
                      final teacher = _jsonMap(activity['teacher']);
                      final schoolClass = _jsonMap(activity['class']);
                      final id = _intId(activity['id']);
                      final joining = _joiningId == id;
                      final className =
                          '${schoolClass['name'] ?? 'Semua siswa sekolah'}';

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: role.accent.withValues(
                              alpha: 0.30,
                            ),
                            child: Icon(Icons.groups, color: role.primary),
                          ),
                          title: Text('${activity['title'] ?? 'Kelas'}'),
                          subtitle: Text(
                            '${teacher['name'] ?? '-'} - $className',
                          ),
                          trailing: joining
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_circle_outline),
                          onTap: joining ? null : () => _join(id),
                        ),
                      );
                    },
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ClassroomObservationSheet extends StatelessWidget {
  const _ClassroomObservationSheet({required this.activityId});

  final int activityId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: Api.classroomObservations(activityId),
        builder: (context, snapshot) {
          final students = (_jsonMap(snapshot.data)['students'] as List? ?? [])
              .cast<dynamic>();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Observasi Siswa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text(
                  snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                )
              else if (students.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada siswa yang join activity ini.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: students.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final row = _jsonMap(students[index]);
                      final student = _jsonMap(row['student']);
                      final checkin = _jsonMap(row['checkin']);
                      final checkout = _jsonMap(row['checkout']);
                      final analysis = _jsonMap(row['burnout_analysis']);
                      final recommendation = _jsonMap(
                        analysis['recommendation'] ??
                            analysis['recommendation_summary'],
                      );
                      final category = '${analysis['category'] ?? 'belum'}';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${student['name'] ?? 'Siswa'}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  StatusPill(
                                    label: _categoryLabel(category),
                                    color: _categoryColor(category),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  StatusPill(
                                    label: 'In: ${checkin['mood'] ?? '-'}',
                                    color: AppTheme.olive,
                                  ),
                                  StatusPill(
                                    label: 'Out: ${checkout['mood'] ?? '-'}',
                                    color: AppTheme.muted,
                                  ),
                                  if (checkout['mood_detected'] != null)
                                    StatusPill(
                                      label: 'AI: ${checkout['mood_detected']}',
                                      color: const Color(0xFF24718E),
                                    ),
                                ],
                              ),
                              if ('${recommendation['headline'] ?? ''}'
                                  .isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  '${recommendation['headline']}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${recommendation['action'] ?? ''}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.muted),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityFormSheet extends StatefulWidget {
  const _ActivityFormSheet({
    required this.selectedDate,
    required this.nextOptimisticId,
    this.activity,
  });

  final DateTime selectedDate;
  final int Function() nextOptimisticId;
  final Map<String, dynamic>? activity;

  @override
  State<_ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<_ActivityFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _customKindController;
  late final TextEditingController _schoolClassController;
  final List<Map<String, dynamic>> _teacherClasses = [];
  late DateTime _date;
  late DateTime _repeatUntil;
  TimeOfDay? _start;
  TimeOfDay? _end;
  int? _schoolClassId;
  String _activityKind = '';
  String _repeatType = 'none';
  bool _loadingTeacherClasses = false;
  bool _saving = false;

  bool get _editing => widget.activity != null;
  bool get _repeating => !_editing && _repeatType != 'none';

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _titleController = TextEditingController(
      text: '${activity?['title'] ?? ''}',
    );
    final initialKind = '${activity?['activity_kind'] ?? ''}';
    _activityKind = initialKind.isEmpty ? '' : _knownOrOtherKind(initialKind);
    _customKindController = TextEditingController(
      text: _activityKind == 'other' ? initialKind : '',
    );
    _schoolClassController = TextEditingController(
      text: '${(activity?['class'] as Map?)?['name'] ?? ''}',
    );
    _schoolClassId = (activity?['class'] as Map?)?['id'] as int?;
    _date = activity == null
        ? widget.selectedDate
        : DateTime.parse('${activity['activity_date']}');
    _repeatUntil = _defaultRepeatUntil(_date, _repeatType);
    _start = _parseOptionalTime(activity?['start_at']);
    _end = _parseOptionalTime(activity?['end_at']);
    Future.microtask(_loadTeacherClasses);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customKindController.dispose();
    _schoolClassController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    if (_activityKind == 'other' && _customKindController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi jenis aktivitas lainnya.')),
      );
      return;
    }
    if (_start != null &&
        _end != null &&
        _minutes(_end!) <= _minutes(_start!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam selesai harus setelah jam mulai.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      if (_editing) {
        final optimistic = _optimisticEditedActivity();
        final request = Api.updateActivity(
          activityId: _intId(widget.activity!['id']),
          title: optimistic['title'] as String,
          activityDate: optimistic['activity_date'] as String,
          startTime: _apiTime(_start),
          endTime: _apiTime(_end),
          category: null,
          activityKind: _selectedActivityKindLabel(),
          activityType: _selectedActivityType(),
          schoolClassId: _selectedActivityType() == 'classroom'
              ? _schoolClassId
              : null,
          schoolClassName: _schoolClassId == null ? _classroomClassName() : null,
        );
        if (mounted) {
          Navigator.of(context).pop(
            _ActivitySaveResult(
              optimisticResponse: {'activity': optimistic},
              request: request,
              optimisticActivities: [optimistic],
              rollbackActivities: [_jsonMap(widget.activity)],
              savingMessage: 'Perubahan ditampilkan. Menyimpan ke server...',
            ),
          );
        }
      } else {
        final optimisticActivities = _optimisticNewActivities();
        final request = Api.createActivity(
          title: _titleController.text.trim(),
          activityDate: DateFormat('yyyy-MM-dd').format(_date),
          startTime: _apiTime(_start),
          endTime: _apiTime(_end),
          category: null,
          activityKind: _selectedActivityKindLabel(),
          activityType: _selectedActivityType(),
          schoolClassId: _selectedActivityType() == 'classroom'
              ? _schoolClassId
              : null,
          schoolClassName: _schoolClassId == null ? _classroomClassName() : null,
          repeatType: _repeatType,
          repeatUntil: _repeating
              ? DateFormat('yyyy-MM-dd').format(_repeatUntil)
              : null,
        );
        if (mounted) {
          Navigator.of(context).pop(
            _ActivitySaveResult(
              optimisticResponse: {
                'activity': optimisticActivities.first,
                'activities': optimisticActivities,
                'created_count': optimisticActivities.length,
              },
              request: request,
              optimisticActivities: optimisticActivities,
              savingMessage: 'Aktivitas ditampilkan. Menyimpan ke server...',
              scheduleReminders: true,
            ),
          );
        }
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

  Map<String, dynamic> _optimisticEditedActivity() {
    return {..._jsonMap(widget.activity), ..._baseActivityFields()};
  }

  List<Map<String, dynamic>> _optimisticNewActivities() {
    return _recurrenceDates().map((date) {
      return {
        'id': widget.nextOptimisticId(),
        ..._baseActivityFields(dateOverride: date),
        'status': 'planned',
        'checkin_at': null,
        'checkout_at': null,
        'actual_hours': null,
      };
    }).toList();
  }

  Map<String, dynamic> _baseActivityFields({DateTime? dateOverride}) {
    final date = dateOverride ?? _date;
    final dateText = DateFormat('yyyy-MM-dd').format(date);
    final startAt = _dateTimeFor(date, _start);
    final endAt = _dateTimeFor(date, _end);
    final category = null;
    final kind = _selectedActivityKindLabel();
    final type = _selectedActivityType();
    final schoolClassName = _classroomClassName();

    return {
      'title': _titleController.text.trim(),
      'category': category,
      'activity_kind': kind,
      'activity_type': type,
      'class': schoolClassName == null ? null : {'name': schoolClassName},
      'activity_date': dateText,
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'planned_hours': startAt != null && endAt != null
          ? double.parse(
              (endAt.difference(startAt).inMinutes / 60).toStringAsFixed(2),
            )
          : 0,
      'intensity_factor': _activityIntensityFactor(
        _titleController.text,
        category,
      ),
    };
  }

  String? _selectedActivityKindLabel() {
    final role = context.read<Session>().role;
    if (_activityKind == 'other') {
      return _emptyToNull(_customKindController.text);
    }

    final options = _activityKindOptions(role);
    return options
        .where((option) => option.value == _activityKind)
        .map((option) => option.label)
        .firstOrNull;
  }

  String _selectedActivityType() {
    final isTeacher = context.read<Session>().isTeacher;
    return isTeacher && _activityKind == 'teaching' ? 'classroom' : 'personal';
  }

  String? _classroomClassName() {
    if (_selectedActivityType() != 'classroom') return null;

    if (_schoolClassId != null) {
      final selected = _teacherClasses
          .where((item) => item['id'] == _schoolClassId)
          .map((item) => '${item['name'] ?? ''}'.trim())
          .firstOrNull;

      return _emptyToNull(selected ?? '');
    }

    return _teacherClasses.isEmpty ? _emptyToNull(_schoolClassController.text) : null;
  }

  Future<void> _loadTeacherClasses() async {
    final session = context.read<Session>();
    if (!session.isTeacher) return;

    final schoolId = session.user?['school_id'] as int?;
    if (schoolId == null) return;

    if (mounted) setState(() => _loadingTeacherClasses = true);
    try {
      final classes = await Api.publicSchoolClasses(schoolId);
      if (!mounted) return;
      setState(() {
        _teacherClasses
          ..clear()
          ..addAll(classes.map((item) => Map<String, dynamic>.from(item as Map)));
      });
    } catch (_) {
      // Legacy activities can still use their existing class text if class fetch fails.
    } finally {
      if (mounted) setState(() => _loadingTeacherClasses = false);
    }
  }

  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (start ? _start : _end) ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _pickDate({required bool repeatUntil}) async {
    final initialDate = repeatUntil ? _repeatUntil : _date;
    final firstDate = repeatUntil ? _date : DateTime(2020);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2035),
    );
    if (picked == null) return;

    setState(() {
      if (repeatUntil) {
        _repeatUntil = picked;
      } else {
        _date = picked;
        if (_repeatUntil.isBefore(_date) || !_repeating) {
          _repeatUntil = _defaultRepeatUntil(_date, _repeatType);
        }
      }
    });
  }

  List<DateTime> _recurrenceDates() {
    if (_repeatType == 'none') return [_date];

    final dates = <DateTime>[];
    var cursor = DateTime(_date.year, _date.month, _date.day);
    final until = DateTime(
      _repeatUntil.year,
      _repeatUntil.month,
      _repeatUntil.day,
    );

    while (!cursor.isAfter(until) && dates.length < 31) {
      dates.add(cursor);
      cursor = _repeatType == 'weekly'
          ? cursor.add(const Duration(days: 7))
          : _addMonthNoOverflow(cursor);
    }

    return dates.isEmpty ? [_date] : dates;
  }

  void _setRepeatType(String value) {
    setState(() {
      _repeatType = value;
      _repeatUntil = _defaultRepeatUntil(_date, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final isTeacher = session.isTeacher;
    final kindOptions = _activityKindOptions(session.role);
    final role = AccountRole.byId(session.role);
    final selectedClassInOptions = _teacherClasses.any(
      (item) => item['id'] == _schoolClassId,
    );
    final hasSelectedClass = _schoolClassId == null ||
        selectedClassInOptions ||
        _schoolClassController.text.trim().isNotEmpty;
    if (_activityKind.isEmpty && kindOptions.isNotEmpty) {
      _activityKind = kindOptions.first.value;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editing ? 'Edit Aktivitas' : 'Tambah Aktivitas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nama kegiatan',
                hintText: 'Contoh: Belajar matematika',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _pickDate(repeatUntil: false),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Tanggal mulai: ${DateFormat('d MMM yyyy', 'id_ID').format(_date)}',
              ),
            ),
            if (!_editing) ...[
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'none',
                    label: Text('Sekali'),
                    icon: Icon(Icons.event),
                  ),
                  ButtonSegment(
                    value: 'weekly',
                    label: Text('Mingguan'),
                    icon: Icon(Icons.date_range),
                  ),
                  ButtonSegment(
                    value: 'monthly',
                    label: Text('Bulanan'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_repeatType},
                onSelectionChanged: (selection) =>
                    _setRepeatType(selection.first),
              ),
              if (_repeating) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(repeatUntil: true),
                  icon: const Icon(Icons.event_repeat),
                  label: Text(
                    'Ulang sampai: ${DateFormat('d MMM yyyy', 'id_ID').format(_repeatUntil)}',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_recurrenceDates().length} aktivitas akan dibuat otomatis.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                ),
              ],
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _OptionalTimeButton(
                    label: 'Jam Mulai',
                    value: _start,
                    icon: Icons.schedule,
                    onPick: () => _pickTime(true),
                    onClear: _start == null
                        ? null
                        : () => setState(() => _start = null),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OptionalTimeButton(
                    label: 'Jam Selesai',
                    value: _end,
                    icon: Icons.schedule_send,
                    onPick: () => _pickTime(false),
                    onClear: _end == null
                        ? null
                        : () => setState(() => _end = null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _activityKind,
              decoration: const InputDecoration(labelText: 'Jenis aktivitas'),
              items: kindOptions
                  .map(
                    (option) => DropdownMenuItem(
                      value: option.value,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _activityKind = value);
              },
            ),
            if (_activityKind == 'other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customKindController,
                decoration: const InputDecoration(
                  labelText: 'Jenis aktivitas lainnya',
                  hintText: 'Tulis aktivitasmu',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
            if (isTeacher && _activityKind == 'teaching') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: hasSelectedClass ? _schoolClassId : null,
                decoration: const InputDecoration(
                  labelText: 'Target kelas',
                  hintText: 'Pilih kelas tujuan',
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Semua Kelas'),
                  ),
                  if (_schoolClassId != null && !selectedClassInOptions)
                    DropdownMenuItem<int?>(
                      value: _schoolClassId,
                      child: Text(
                        _schoolClassController.text.trim().isEmpty
                            ? 'Kelas saat ini'
                            : _schoolClassController.text.trim(),
                      ),
                    ),
                  ..._teacherClasses.map(
                    (item) => DropdownMenuItem<int?>(
                      value: item['id'] as int?,
                      child: Text('${item['name'] ?? '-'}'),
                    ),
                  ),
                ],
                onChanged: _loadingTeacherClasses
                    ? null
                    : (value) {
                        setState(() {
                          _schoolClassId = value;
                          _schoolClassController.text = _classroomClassName() ?? '';
                        });
                      },
              ),
              const SizedBox(height: 8),
              Text(
                _schoolClassId == null
                    ? 'Kelas terbuka untuk semua siswa di sekolah Anda.'
                    : 'Hanya siswa di kelas ini yang bisa join.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: role.primary),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionalTimeButton extends StatelessWidget {
  const _OptionalTimeButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final TimeOfDay? value;
  final IconData icon;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final currentValue = value;

    return OutlinedButton(
      onPressed: onPick,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: SizedBox(
        height: 46,
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                currentValue == null ? label : _apiTime(currentValue)!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Kosongkan',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _JournalMode { checkIn, checkOut }

const _checkinMoodOptions = [
  _CheckinMoodOption('senang', 'Senang', '😊'),
  _CheckinMoodOption('tenang', 'Tenang', '😌'),
  _CheckinMoodOption('cemas', 'Cemas', '😟'),
  _CheckinMoodOption('sedih', 'Sedih', '😢'),
  _CheckinMoodOption('marah', 'Marah', '😠'),
];

const _burnoutDimensionLabels = {
  'kelelahan_emosional': 'Kelelahan emosional',
  'depersonalisasi': 'Depersonalisasi',
  'rendah_pencapaian_diri': 'Rendah pencapaian diri',
};

class _CheckinMoodOption {
  const _CheckinMoodOption(this.key, this.label, this.symbol);

  final String key;
  final String label;
  final String symbol;
}

class _WellbeingSheet extends StatefulWidget {
  const _WellbeingSheet({required this.activity, required this.mode});

  final Map<String, dynamic> activity;
  final _JournalMode mode;

  @override
  State<_WellbeingSheet> createState() => _WellbeingSheetState();
}

class _WellbeingSheetState extends State<_WellbeingSheet> {
  late final TextEditingController _triggerController;
  late final TextEditingController _factController;
  late final TextEditingController _feelingController;
  late final TextEditingController _patternController;
  late final TextEditingController _planController;
  final Set<String> _burnoutTags = {};
  String? _checkinMood;
  String? _checkoutMood;
  double _checkinIntensity = 5;
  bool _saving = false;

  bool get _isCheckout => widget.mode == _JournalMode.checkOut;

  @override
  void initState() {
    super.initState();
    final savedMood = '${widget.activity['checkin_mood'] ?? ''}';
    _checkinMood = _checkinMoodOptions.any((option) => option.key == savedMood)
        ? savedMood
        : null;
    final savedCheckoutMood = '${widget.activity['checkout_mood'] ?? ''}';
    _checkoutMood =
        _checkinMoodOptions.any((option) => option.key == savedCheckoutMood)
        ? savedCheckoutMood
        : null;
    final savedIntensity = _numValue(
      widget.activity['checkin_intensity'],
      fallback: 5,
    );
    _checkinIntensity = savedIntensity.clamp(1, 10).toDouble();
    _triggerController = TextEditingController(
      text: '${widget.activity['checkin_trigger'] ?? ''}',
    );
    _factController = TextEditingController(
      text: '${widget.activity['checkout_fact'] ?? ''}',
    );
    _feelingController = TextEditingController(
      text: '${widget.activity['checkout_feeling'] ?? ''}',
    );
    _patternController = TextEditingController(
      text: '${widget.activity['checkout_pattern'] ?? ''}',
    );
    _planController = TextEditingController(
      text: '${widget.activity['checkout_plan'] ?? ''}',
    );
    _burnoutTags.addAll(
      (widget.activity['checkout_burnout_tags'] as List? ?? [])
          .map((item) => '$item')
          .where((item) => _burnoutDimensionLabels.containsKey(item)),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (_isCheckout) {
        final fact = _factController.text.trim();
        final feeling = _feelingController.text.trim();
        final pattern = _patternController.text.trim();
        final plan = _planController.text.trim();
        if (fact.isEmpty && feeling.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Isi minimal fakta atau perasaan sebelum check-out.',
                ),
              ),
            );
          }
          return;
        }

        final request = Api.checkOutActivity(
          activityId: _intId(widget.activity['id']),
          mood: _checkoutMood,
          fact: fact.isEmpty ? null : fact,
          feeling: feeling.isEmpty ? null : feeling,
          pattern: pattern.isEmpty ? null : pattern,
          plan: plan.isEmpty ? null : plan,
          burnoutTags: _burnoutTags.isEmpty ? null : _burnoutTags.toList(),
        );
        if (mounted) {
          Navigator.of(context).pop(
            _JournalSaveResult(
              optimisticActivity: _optimisticCheckoutActivity(),
              previousActivity: _jsonMap(widget.activity),
              request: request,
              mode: widget.mode,
            ),
          );
        }
      } else {
        final trigger = _triggerController.text.trim();
        final request = Api.checkInActivity(
          activityId: _intId(widget.activity['id']),
          mood: _checkinMood,
          intensity: _checkinMood == null ? null : _checkinIntensity.round(),
          trigger: trigger.isEmpty ? null : trigger,
        );
        if (mounted) {
          Navigator.of(context).pop(
            _JournalSaveResult(
              optimisticActivity: _optimisticCheckinActivity(),
              previousActivity: _jsonMap(widget.activity),
              request: request,
              mode: widget.mode,
            ),
          );
        }
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

  Map<String, dynamic> _optimisticCheckinActivity() {
    return {
      ..._jsonMap(widget.activity),
      'status': 'checked_in',
      'checkin_at': DateTime.now().toIso8601String(),
      'checkin_mood': _checkinMood,
      'checkin_intensity': _checkinMood == null
          ? null
          : _checkinIntensity.round(),
      'checkin_trigger': _triggerController.text.trim().isEmpty
          ? null
          : _triggerController.text.trim(),
    };
  }

  Map<String, dynamic> _optimisticCheckoutActivity() {
    return {
      ..._jsonMap(widget.activity),
      'status': 'completed',
      'checkout_at': DateTime.now().toIso8601String(),
      'actual_hours': _optimisticActualHours(widget.activity),
      'checkout_mood': _checkoutMood,
      'checkout_fact': _factController.text.trim().isEmpty
          ? null
          : _factController.text.trim(),
      'checkout_feeling': _feelingController.text.trim().isEmpty
          ? null
          : _feelingController.text.trim(),
      'checkout_pattern': _patternController.text.trim().isEmpty
          ? null
          : _patternController.text.trim(),
      'checkout_plan': _planController.text.trim().isEmpty
          ? null
          : _planController.text.trim(),
      'checkout_burnout_tags': _burnoutTags.toList(),
    };
  }

  @override
  void dispose() {
    _triggerController.dispose();
    _factController.dispose();
    _feelingController.dispose();
    _patternController.dispose();
    _planController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<Session>().isTeacher;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isCheckout ? 'Check-out + Jurnal Pasca' : 'Check-in Mood',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.activity['title']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            Text(
              'Bagaimana perasaanmu sekarang? (opsional)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _MoodChoiceGrid(
              selected: _isCheckout ? _checkoutMood : _checkinMood,
              onSelected: (value) {
                setState(() {
                  if (_isCheckout) {
                    _checkoutMood = value;
                  } else {
                    _checkinMood = value;
                  }
                });
              },
            ),
            if (!_isCheckout) ...[
              const SizedBox(height: 16),
              Text(
                'Seberapa kuat? (${_checkinIntensity.round()}/10)',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: _checkinIntensity,
                min: 1,
                max: 10,
                divisions: 9,
                label: '${_checkinIntensity.round()}',
                onChanged: (v) => setState(() => _checkinIntensity = v),
              ),
            ],
            const SizedBox(height: 10),
            if (_isCheckout) ...[
              TextField(
                controller: _factController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Apa yang terjadi tadi?',
                  hintText: 'Ceritakan apa yang terjadi selama kegiatan ini...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _feelingController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bagaimana perasaanmu soal itu?',
                  hintText: 'Aku merasa...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _patternController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Pola yang kamu sadari (opsional)',
                  hintText: 'Contoh: mulai tegang saat tugas menumpuk',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _planController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Rencana ke depan (opsional)',
                  hintText: 'Contoh: besok akan...',
                ),
              ),
              if (isTeacher) ...[
                const SizedBox(height: 12),
                Text(
                  'Tandai jika terasa (opsional)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _burnoutDimensionLabels.entries.map((entry) {
                    final selected = _burnoutTags.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _burnoutTags.add(entry.key);
                          } else {
                            _burnoutTags.remove(entry.key);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
            ] else ...[
              TextField(
                controller: _triggerController,
                decoration: const InputDecoration(
                  labelText: 'Kenapa? (opsional)',
                  hintText: 'Contoh: deg-degan sebelum ulangan',
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'Menyimpan...'
                    : _isCheckout
                    ? 'Simpan Check-out'
                    : 'Mulai Sekarang',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodChoiceGrid extends StatelessWidget {
  const _MoodChoiceGrid({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _checkinMoodOptions.map((option) {
        final isSelected = selected == option.key;
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSelected(option.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 76,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: 0.12)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primary : AppTheme.line,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(option.symbol, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: isSelected ? primary : AppTheme.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SoftCard(
        child: Row(
          children: [
            Icon(Icons.info_outline, color: primary),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _ActivityBundle {
  _ActivityBundle({required this.data});

  final Map<String, dynamic> data;
}

class _ActivitySaveResult {
  const _ActivitySaveResult({
    required this.optimisticResponse,
    required this.request,
    required this.optimisticActivities,
    required this.savingMessage,
    this.rollbackActivities = const [],
    this.scheduleReminders = false,
  });

  final Map<String, dynamic> optimisticResponse;
  final Future<Map<String, dynamic>> request;
  final List<Map<String, dynamic>> optimisticActivities;
  final List<Map<String, dynamic>> rollbackActivities;
  final String savingMessage;
  final bool scheduleReminders;
}

class _JournalSaveResult {
  const _JournalSaveResult({
    required this.optimisticActivity,
    required this.previousActivity,
    required this.request,
    required this.mode,
  });

  final Map<String, dynamic> optimisticActivity;
  final Map<String, dynamic> previousActivity;
  final Future<Map<String, dynamic>> request;
  final _JournalMode mode;
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

Map<String, dynamic> _summaryFromActivities(
  List<Map<String, dynamic>> activities,
) {
  final active = activities
      .where((activity) => '${activity['status'] ?? 'planned'}' != 'cancelled')
      .toList();
  final completed = active
      .where((activity) => '${activity['status'] ?? ''}' == 'completed')
      .toList();

  return {
    'planned': active.length,
    'completed': completed.length,
    'checkin_pending': active
        .where((activity) => activity['checkin_at'] == null)
        .length,
    'weighted_planned_hours': _weightedHours(active, 'planned_hours'),
    'weighted_actual_hours': _weightedHours(completed, 'actual_hours'),
  };
}

double _weightedHours(List<Map<String, dynamic>> activities, String field) {
  final total = activities.fold<double>(0, (sum, activity) {
    return sum +
        _numValue(activity[field]) *
            _numValue(activity['intensity_factor'], fallback: 1);
  });

  return double.parse(total.toStringAsFixed(2));
}

double _numValue(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

String _activityIdKey(Object? id) => '$id';

bool _sameActivityId(Object? left, Object? right) {
  return left != null &&
      right != null &&
      _activityIdKey(left) == _activityIdKey(right);
}

bool _matchesActivityIdentity(
  Map<String, dynamic> activity,
  Map<String, dynamic> target,
) {
  return _sameActivityId(activity['id'], target['id']) ||
      _activityFingerprint(activity) == _activityFingerprint(target);
}

bool _isCancelledActivity(Map<String, dynamic> activity) {
  return '${activity['status'] ?? ''}' == 'cancelled';
}

int _intId(Object? id) {
  if (id is int) return id;
  final parsed = int.tryParse('$id');
  if (parsed == null) {
    throw ApiException('ID aktivitas tidak valid.');
  }
  return parsed;
}

bool _isTemporaryId(Object? id) {
  if (id is int) return id < 0;
  return int.tryParse('$id')?.isNegative ?? false;
}

String _activityFingerprint(Map<String, dynamic> activity) {
  return [
    _activityDateKey(activity['activity_date']),
    '${activity['title'] ?? ''}'.trim().toLowerCase(),
    '${activity['activity_kind'] ?? ''}'.trim().toLowerCase(),
    _timeFingerprint(activity['start_at']),
    _timeFingerprint(activity['end_at']),
  ].join('|');
}

String _timeFingerprint(dynamic value) {
  if (value == null) return '';
  final parsed = DateTime.tryParse('$value');
  if (parsed != null) return DateFormat('HH:mm').format(parsed.toLocal());
  final raw = '$value';
  return raw.length >= 5 ? raw.substring(0, 5) : raw;
}

String _activityDateKey(dynamic value) {
  final raw = '$value';
  if (raw.contains('T')) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return DateFormat('yyyy-MM-dd').format(parsed.toLocal());
    }
  }
  if (raw.length >= 10) return raw.substring(0, 10);
  return raw;
}

String _errorMessage(Object? error) {
  if (error is ApiException) return error.message;
  return 'Gagal memuat data aktivitas.';
}

String _savedMessage(Map<String, dynamic> response) {
  final count = _numValue(response['created_count']).round();
  final skipped = _numValue(response['skipped_count']).round();
  if (count == 0 && skipped > 0) return 'Aktivitas tersebut sudah ada.';
  if (count > 1 && skipped > 0) {
    return '$count aktivitas tersimpan, $skipped sudah ada.';
  }
  if (count > 1) return '$count aktivitas tersimpan.';
  return 'Aktivitas tersimpan.';
}

String _time(dynamic value) {
  if (value == null) return '--:--';
  return DateFormat('HH:mm').format(DateTime.parse('$value').toLocal());
}

String _activityTimeRange(Map<String, dynamic> activity) {
  final startAt = activity['start_at'];
  final endAt = activity['end_at'];
  if (startAt != null && endAt != null) {
    return '${_time(startAt)}-${_time(endAt)}';
  }
  if (startAt != null) return _time(startAt);
  if (endAt != null) return _time(endAt);
  return '';
}

TimeOfDay? _parseOptionalTime(dynamic value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse('$value');
  if (parsed == null) return null;
  return TimeOfDay(
    hour: parsed.toLocal().hour,
    minute: parsed.toLocal().minute,
  );
}

String? _apiTime(TimeOfDay? value) {
  if (value == null) return null;
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

int _minutes(TimeOfDay value) => value.hour * 60 + value.minute;

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _knownOrOtherKind(String value) {
  final normalized = value.trim().toLowerCase();
  for (final option in [..._teacherActivityKinds, ..._studentActivityKinds]) {
    if (option.label.toLowerCase() == normalized) {
      return option.value;
    }
  }
  return 'other';
}

String _activityKindLabel(String value) {
  if (value.isEmpty) return '';
  final kind = _knownOrOtherKind(value);
  if (kind == 'other') return value;
  for (final option in [..._teacherActivityKinds, ..._studentActivityKinds]) {
    if (option.value == kind) return option.label;
  }
  return value;
}

List<_ActivityKindOption> _activityKindOptions(String? role) {
  return role == 'student' ? _studentActivityKinds : _teacherActivityKinds;
}

const _teacherActivityKinds = [
  _ActivityKindOption('teaching', 'Mengajar'),
  _ActivityKindOption('meeting', 'Rapat'),
  _ActivityKindOption('administration', 'Administrasi'),
  _ActivityKindOption('grading', 'Koreksi'),
  _ActivityKindOption('preparation', 'Persiapan materi'),
  _ActivityKindOption('break', 'Istirahat'),
  _ActivityKindOption('other', 'Lainnya'),
];

const _studentActivityKinds = [
  _ActivityKindOption('class_learning', 'Belajar di kelas'),
  _ActivityKindOption('group_study', 'Belajar bersama'),
  _ActivityKindOption('assignment', 'Tugas/PR'),
  _ActivityKindOption('exam', 'Ujian/Ulangan'),
  _ActivityKindOption('extracurricular', 'Ekstrakurikuler'),
  _ActivityKindOption('break', 'Istirahat'),
  _ActivityKindOption('other', 'Lainnya'),
];

class _ActivityKindOption {
  const _ActivityKindOption(this.value, this.label);

  final String value;
  final String label;
}

DateTime? _dateTimeFor(DateTime date, TimeOfDay? time) {
  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

DateTime _defaultRepeatUntil(DateTime date, String repeatType) {
  return switch (repeatType) {
    'weekly' => DateTime(date.year, date.month + 1, 0),
    'monthly' => _addMonthNoOverflow(date, months: 5),
    _ => date,
  };
}

DateTime _addMonthNoOverflow(DateTime date, {int months = 1}) {
  final targetMonth = date.month + months;
  final lastDay = DateTime(date.year, targetMonth + 1, 0).day;
  return DateTime(
    date.year,
    targetMonth,
    date.day > lastDay ? lastDay : date.day,
  );
}

double _activityIntensityFactor(String title, String? category) {
  final text = '${title.toLowerCase()} ${(category ?? '').toLowerCase()}';
  final rules = <({List<String> keywords, double factor})>[
    (keywords: ['ulangan', 'ujian'], factor: 1.6),
    (keywords: ['matematika', 'mtk'], factor: 1.5),
    (keywords: ['mengajar', 'rapat', 'koreksi'], factor: 1.4),
    (keywords: ['olahraga'], factor: 1.2),
    (keywords: ['istirahat', 'santai'], factor: 0.5),
    (keywords: ['tidur'], factor: 0.4),
  ];

  for (final rule in rules) {
    if (rule.keywords.any(text.contains)) return rule.factor;
  }

  return 1;
}

Future<void> _scheduleReminderFromActivity(
  Map<String, dynamic> activity,
) async {
  final id = activity['id'];
  final startAt = DateTime.tryParse('${activity['start_at']}');
  final endAt = DateTime.tryParse('${activity['end_at']}');
  if (id is! int || startAt == null || endAt == null) {
    return;
  }

  await ReminderService.scheduleActivityReminders(
    activityId: id,
    title: '${activity['title'] ?? 'Aktivitas'}',
    startAt: startAt.toLocal(),
    endAt: endAt.toLocal(),
  );
}

Future<void> _scheduleRemindersFromResponse(
  Map<String, dynamic> response,
) async {
  final activities = response['activities'];
  if (activities is List && activities.isNotEmpty) {
    for (final item in activities.take(24)) {
      await _scheduleReminderFromActivity(_jsonMap(item));
    }
    return;
  }

  await _scheduleReminderFromActivity(_jsonMap(response['activity']));
}

Color _statusColor(String status) {
  return switch (status) {
    'completed' => const Color(0xFF24718E),
    'checked_in' => const Color(0xFFD99B3D),
    'cancelled' => AppTheme.muted,
    _ => AppTheme.olive,
  };
}

Color _categoryColor(String category) {
  return switch (category) {
    'merah' => const Color(0xFFC65A4A),
    'kuning' => const Color(0xFFD99B3D),
    'hijau' => AppTheme.olive,
    _ => AppTheme.muted,
  };
}

String _statusLabel(String status) {
  return switch (status) {
    'completed' => 'COMPLETED',
    'checked_in' => 'CHECKED IN',
    'cancelled' => 'CANCELLED',
    _ => 'PLANNED',
  };
}

double _optimisticActualHours(Map<String, dynamic> activity) {
  final checkinAt = DateTime.tryParse('${activity['checkin_at']}');
  if (checkinAt == null) {
    return _numValue(activity['planned_hours']);
  }

  final hours = DateTime.now().difference(checkinAt.toLocal()).inMinutes / 60;
  if (hours <= 0) {
    return _numValue(activity['planned_hours']);
  }

  return double.parse(hours.toStringAsFixed(2));
}
