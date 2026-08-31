import 'package:flutter/foundation.dart';

final dashboardRefreshTick = ValueNotifier<int>(0);
final activityRefreshTick = ValueNotifier<int>(0);
final analysisRefreshTick = ValueNotifier<int>(0);
final teacherTabRequest = ValueNotifier<int?>(null);
final teacherActivityDateRequest = ValueNotifier<DateTime?>(null);

void requestDashboardRefresh() {
  dashboardRefreshTick.value++;
}

void requestActivityRefresh() {
  activityRefreshTick.value++;
}

void requestAnalysisRefresh() {
  analysisRefreshTick.value++;
}

void requestTeacherTab(int index) {
  teacherTabRequest.value = index;
}

void requestTeacherActivityDate(DateTime date) {
  teacherActivityDateRequest.value = date;
  requestTeacherTab(1);
}
