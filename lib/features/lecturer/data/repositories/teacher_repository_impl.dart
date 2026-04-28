import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/teacher_home_data_entity.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_remote_datasource.dart';
import '../models/schedule_model.dart';
import '../models/teacher_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;

  TeacherRepositoryImpl({required this.remoteDataSource});

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _mondayOfWeek(DateTime d) {
    final weekday = d.weekday;
    return DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: weekday - 1));
  }

  DateTime _sundayOfWeek(DateTime d) {
    final monday = _mondayOfWeek(d);
    return monday.add(const Duration(days: 6));
  }

  int _sumPeriods(List<ScheduleModel> xs) =>
      xs.fold(0, (acc, s) => acc + s.periodsCount);

  Future<int?> _getTeacherId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('teacherId');
  }

  @override
  Future<TeacherHomeDataEntity> fetchHomeData() async {
    final teacherId = await _getTeacherId();
    if (teacherId == null) {
      throw Exception('Không tìm thấy teacherId. Hãy đăng nhập lại.');
    }

    try {
      final data = await remoteDataSource.fetchHomeData(teacherId);
      final root = data['items'] ?? [];

      final List<ScheduleModel> allSchedules = [];
      for (final item in (root as List).whereType<Map<String, dynamic>>()) {
        final section = (item['classSection'] ?? {}) as Map<String, dynamic>;
        final details = (item['details'] ?? []) as List;
        for (final d in details.whereType<Map<String, dynamic>>()) {
          allSchedules.add(
            ScheduleModel.fromSectionDetail(section: section, detail: d),
          );
        }
      }

      final now = DateTime.now();
      final today =
          allSchedules.where((s) {
            if (s.teachingDate == null) return false;
            return _sameDate(s.teachingDate!, now);
          }).toList();

      final monday = _mondayOfWeek(now);
      final sunday = _sundayOfWeek(now);
      bool inWeek(DateTime d) => !d.isBefore(monday) && !d.isAfter(sunday);

      final thisWeek =
          allSchedules.where((s) {
            if (s.teachingDate == null) return false;
            final d = DateTime(
              s.teachingDate!.year,
              s.teachingDate!.month,
              s.teachingDate!.day,
            );
            return inWeek(d);
          }).toList();

      final periodsToday = _sumPeriods(today);
      final periodsThisWeek = _sumPeriods(thisWeek);
      final doneCount =
          today.where((s) => s.status == ScheduleStatus.done).length;
      final percentCompleted =
          today.isEmpty ? 0 : ((doneCount / today.length) * 100).round();
      final prefs = await SharedPreferences.getInstance();
      final teacherName = prefs.getString('fullName') ?? 'Giảng viên';
      final teacherFaculty = prefs.getString('faculty') ?? '';

      final teacher = TeacherModel(
        id: teacherId,
        name: teacherName,
        faculty: teacherFaculty,
      );

      return TeacherHomeDataEntity(
        teacher: teacher,
        periodsToday: periodsToday,
        periodsThisWeek: periodsThisWeek,
        percentCompleted: percentCompleted,
        todaySchedules: today,
      );
    } catch (e) {
      throw Exception('Không thể tải dữ liệu: $e');
    }
  }

  @override
  Future<void> markScheduleAsDone(int scheduleDetailId) {
    return remoteDataSource.markScheduleAsDone(scheduleDetailId);
  }

  @override
  Future<void> requestClassCancel({
    required int detailId,
    required String reason,
    String? fileUrl,
  }) {
    return remoteDataSource.requestClassCancel(
      detailId: detailId,
      reason: reason,
      fileUrl: fileUrl,
    );
  }
}
