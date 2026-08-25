import 'package:flutter/foundation.dart';

final dashboardRefreshTick = ValueNotifier<int>(0);
final teacherTabRequest = ValueNotifier<int?>(null);

void requestDashboardRefresh() {
  dashboardRefreshTick.value++;
}

void requestTeacherTab(int index) {
  teacherTabRequest.value = index;
}
