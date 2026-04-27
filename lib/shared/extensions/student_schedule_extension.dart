import '../../features/student/models/student_schedule_model.dart';

extension StudentScheduleExtension on StudentScheduleModel {
  String get vietnameseType {
    switch (type) {
      case "LY_THUYET":
        return "Lý thuyết";
      case "THUC_HANH":
        return "Thực hành";
      default:
        return "Khác";
    }
  }
}