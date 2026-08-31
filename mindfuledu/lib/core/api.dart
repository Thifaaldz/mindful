import 'api_client.dart';

/// Thin wrapper around the MindfulEdu REST API endpoints.
class Api {
  static ApiClient get _api => ApiClient.instance;

  static Future<Map<String, dynamic>> dashboard() async {
    final res = await _api.get('/dashboard');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> activities({required String date}) async {
    final res = await _api.get('/activities', query: {'date': date});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createActivity({
    required String title,
    String? activityDate,
    String? startTime,
    String? endTime,
    String? category,
    String? repeatType,
    String? repeatUntil,
  }) async {
    final res = await _api.post(
      '/activities',
      data: {
        'title': title,
        'activity_date': activityDate,
        'start_time': startTime,
        'end_time': endTime,
        'category': category,
        'repeat_type': repeatType,
        'repeat_until': repeatUntil,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateActivity({
    required int activityId,
    required String title,
    String? activityDate,
    String? startTime,
    String? endTime,
    String? category,
  }) async {
    final res = await _api.put(
      '/activities/$activityId',
      data: {
        'title': title,
        'activity_date': activityDate,
        'start_time': startTime,
        'end_time': endTime,
        'category': category,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> cancelActivity(int activityId) async {
    final res = await _api.post('/activities/$activityId/cancel');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> duplicateActivity(
    int activityId, {
    String? activityDate,
  }) async {
    final res = await _api.post(
      '/activities/$activityId/duplicate',
      data: {'activity_date': activityDate},
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> checkInActivity({
    required int activityId,
    String? mood,
    int? intensity,
    String? trigger,
  }) async {
    final res = await _api.post(
      '/activities/$activityId/check-in',
      data: {'mood': mood, 'intensity': intensity, 'trigger': trigger},
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> checkOutActivity({
    required int activityId,
    String? mood,
    String? fact,
    String? feeling,
    String? pattern,
    String? plan,
    List<String>? burnoutTags,
  }) async {
    final res = await _api.post(
      '/activities/$activityId/check-out',
      data: {
        'mood': mood,
        'fact': fact,
        'feeling': feeling,
        'pattern': pattern,
        'plan': plan,
        'burnout_tags': burnoutTags,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createBurnoutAnalysis({
    required String periodType,
    required String date,
  }) async {
    final res = await _api.post(
      '/burnout-analyses',
      data: {'period_type': periodType, 'date': date},
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> burnoutAnalyses({int page = 1}) async {
    final res = await _api.get('/burnout-analyses', query: {'page': page});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> burnoutOverview() async {
    final res = await _api.get('/burnout-analyses/overview');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> saveBurnoutSelfReport({
    required int level,
  }) async {
    final res = await _api.post(
      '/burnout-self-reports',
      data: {'level': level},
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> tactics() async {
    final res = await _api.get('/toolkit/tactics');
    return res.data as List<dynamic>;
  }

  static Future<bool> toggleBookmark(int tacticId) async {
    final res = await _api.post('/toolkit/tactics/$tacticId/bookmark');
    return (res.data as Map<String, dynamic>)['is_bookmarked'] as bool;
  }

  static Future<Map<String, dynamic>> reminderPreference() async {
    final res = await _api.get('/reminder-preference');
    return (res.data as Map<String, dynamic>)['reminder']
        as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateReminderPreference({
    required bool enabled,
    required String time,
    required String channel,
    required String timezone,
  }) async {
    final res = await _api.put(
      '/reminder-preference',
      data: {
        'enabled': enabled,
        'time': time,
        'channel': channel,
        'timezone': timezone,
      },
    );
    return (res.data as Map<String, dynamic>)['reminder']
        as Map<String, dynamic>;
  }
}
