import 'api_client.dart';

/// Thin wrapper around the MindfulEdu REST API endpoints.
class Api {
  static ApiClient get _api => ApiClient.instance;

  static Future<Map<String, dynamic>> dashboard() async {
    final res = await _api.get('/dashboard');
    return res.data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> classes() async {
    final res = await _api.get('/classes');
    return res.data as List<dynamic>;
  }

  static Future<List<dynamic>> studentsInClass(int classId) async {
    final res = await _api.get('/classes/$classId/students');
    return res.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> startSession() async {
    final res = await _api.post('/mindfulness-sessions');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> finishSession({
    required int sessionId,
    required int durationSeconds,
    required int distractionScore,
    required int calmnessBefore,
    required int calmnessAfter,
    String? reflection,
    String? bodyNote,
    String? helpfulNote,
    Map<String, int>? logbookAnswers,
  }) async {
    final res = await _api.put(
      '/mindfulness-sessions/$sessionId',
      data: {
        'duration_seconds': durationSeconds,
        'distraction_score': distractionScore,
        'calmness_before': calmnessBefore,
        'calmness_after': calmnessAfter,
        'reflection': reflection,
        'body_note': bodyNote,
        'helpful_note': helpfulNote,
        'logbook_answers': logbookAnswers,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> sessionHistory({int page = 1}) async {
    final res = await _api.get('/mindfulness-sessions', query: {'page': page});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> saveObservation({
    required int studentId,
    required int classId,
    required String perasaan,
    required String perilaku,
    required String tubuh,
    required String teman,
    required String belajar,
    String? notes,
  }) async {
    final res = await _api.post(
      '/observations',
      data: {
        'student_id': studentId,
        'class_id': classId,
        'perasaan': perasaan,
        'perilaku': perilaku,
        'tubuh': tubuh,
        'teman': teman,
        'belajar': belajar,
        'notes': notes,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> flaggedObservations() async {
    final res = await _api.get('/observations/flagged');
    return res.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> studentObservationHistory(
    int studentId,
  ) async {
    final res = await _api.get('/students/$studentId/observations');
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

  static Future<Map<String, dynamic>?> latestQuestionnaire() async {
    final res = await _api.get('/questionnaire/latest');
    return (res.data as Map<String, dynamic>)['response']
        as Map<String, dynamic>?;
  }

  static Future<Map<String, dynamic>> submitQuestionnaire({
    required Map<String, String> respondentProfile,
    required Map<String, int> answers,
    String? comment,
  }) async {
    final res = await _api.post(
      '/questionnaire/responses',
      data: {
        'respondent_profile': respondentProfile,
        'answers': answers,
        'comment': comment,
      },
    );
    return res.data as Map<String, dynamic>;
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
