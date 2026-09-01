import 'package:flutter/foundation.dart';

final dashboardRefreshTick = ValueNotifier<int>(0);
final activityRefreshTick = ValueNotifier<int>(0);
final analysisRefreshTick = ValueNotifier<int>(0);
final teacherTabRequest = ValueNotifier<int?>(null);
final studentTabRequest = ValueNotifier<int?>(null);
final parentTabRequest = ValueNotifier<int?>(null);
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

void requestStudentTab(int index) {
  studentTabRequest.value = index;
}

void requestParentTab(int index) {
  parentTabRequest.value = index;
}

void requestProfileTab(String? role) {
  if (role == 'teacher') {
    requestTeacherTab(4);
  } else if (role == 'parent') {
    requestParentTab(1);
  } else {
    requestStudentTab(4);
  }
}

void requestTeacherActivityDate(DateTime date) {
  teacherActivityDateRequest.value = date;
  requestTeacherTab(1);
}
