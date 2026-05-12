import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/teacher_home_data_entity.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_remote_datasource.dart';
import '../models/schedule_model.dart';
import '../models/teacher_model.dart';
import '../../../../config/constants/api_endpoints.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;

  TeacherRepositoryImpl({required this.remoteDataSource});

  Future<int?> _getTeacherId() async {
    final prefs = await SharedPreferences.getInstance();
    int? teacherId = prefs.getInt('teacherId');
    teacherId ??= prefs.getInt('id');
    return teacherId;
  }

  @override
  Future<TeacherHomeDataEntity> fetchHomeData() async {
    final teacherId = await _getTeacherId();
    if (teacherId == null) {
      throw Exception('Không tìm thấy teacherId. Hãy đăng nhập lại.');
    }
    final prefs = await SharedPreferences.getInstance();
    final teacherName = prefs.getString('fullName') ?? 'Giảng viên';
    final teacherFaculty = prefs.getString('faculty') ?? '';
    final teacher = TeacherModel(
      id: teacherId,
      name: teacherName,
      faculty: teacherFaculty,
    );

    // Fetch all schedules and filter for today
    List<ScheduleEntity> allSchedules = [];
    List<ScheduleEntity> todaySchedules = [];
    int periodsToday = 0;
    int periodsThisWeek = 0;
    int percentCompleted = 0;
    
    try {
      allSchedules = await fetchAllSchedules();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Filter today's schedules
      todaySchedules = allSchedules.where((s) {
        final scheduleDate = s.sessionDate;
        if (scheduleDate == null) return false;
        final sameDay =
            scheduleDate.year == today.year &&
            scheduleDate.month == today.month &&
            scheduleDate.day == today.day;
        return sameDay;
      }).toList();
      
      // Calculate periods today
      periodsToday = todaySchedules.fold(0, (sum, s) => sum + s.periodsCount);
      
      // Calculate periods this week
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      
      final thisWeekSchedules = allSchedules.where((s) {
        final scheduleDate = s.sessionDate;
        if (scheduleDate == null) return false;
        final dateOnly = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day);
        return !dateOnly.isBefore(monday) && !dateOnly.isAfter(sunday);
      }).toList();
      
      periodsThisWeek = thisWeekSchedules.fold(0, (sum, s) => sum + s.periodsCount);
      
      // Calculate completion percentage
      final completedSchedules = allSchedules.where((s) => s.status == ScheduleStatus.done).length;
      final totalSchedules = allSchedules.length;
      percentCompleted = totalSchedules > 0 ? ((completedSchedules / totalSchedules) * 100).round() : 0;
      
    } catch (e) {
      // If error, return empty data
      print('Error fetching schedules for home: $e');
    }

    return TeacherHomeDataEntity(
      teacher: teacher,
      periodsToday: periodsToday,
      periodsThisWeek: periodsThisWeek,
      percentCompleted: percentCompleted,
      todaySchedules: todaySchedules,
    );
  }

  @override
  Future<List<ScheduleEntity>> fetchAllSchedules() async {
    final teacherId = await _getTeacherId();
    if (teacherId == null) {
      throw Exception('Không tìm thấy teacherId. Hãy đăng nhập lại.');
    }

    try {
      final List<ScheduleEntity> allSchedules = [];
      final headers = await _getHeaders();
      final schedulesUri = Uri.parse('${ApiEndpoints.baseUrl}/lecturer/schedules?page=0&size=1000');
      final schedulesResponse = await http.get(schedulesUri, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (schedulesResponse.statusCode != 200) {
        throw Exception('Failed to load schedules: ${schedulesResponse.statusCode}');
      }
      final schedulesData = jsonDecode(schedulesResponse.body);
      final schedules = schedulesData['data']?['items'] ?? [];
      for (final schedule in (schedules as List).whereType<Map<String, dynamic>>()) {
        final scheduleId = schedule['id'] as int?;
        if (scheduleId == null) continue;
        final status = schedule['status'] as String?;
        if (status != 'OFFICIAL') continue;
        
        try {
          final entries = await remoteDataSource.fetchScheduleEntries(scheduleId);
          for (final entry in entries) {
            final entryId = entry['id'] as int?;
            if (entryId == null) continue;
            try {
              final scheduleDetails = await remoteDataSource.fetchScheduleDetails(entryId);
              for (final detail in scheduleDetails) {
                final detailWithEntry = {
                  ...detail,
                  'subjectName': entry['courseName'],
                  'classCode': entry['sectionClassCode'],
                };
                
                final scheduleEntity = ScheduleModel.fromJson(detailWithEntry);
                allSchedules.add(scheduleEntity);
              }
            } catch (e) {
              // Continue processing other entries
            }
          }
        } catch (e) {
          // Continue processing other schedules
        }
      }
      
      return allSchedules;
    } catch (e) {
      throw Exception('Không thể tải lịch dạy: $e');
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();
    if (token == null) {
      throw Exception('Không tìm thấy token, vui lòng đăng nhập lại');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
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
