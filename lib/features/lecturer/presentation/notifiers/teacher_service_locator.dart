import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../notifiers/teacher_home_notifier.dart';
import '../notifiers/teacher_schedule_notifier.dart';
import '../notifiers/teacher_notification_notifier.dart';
import '../notifiers/teacher_profile_notifier.dart';
import '../notifiers/teacher_stats_notifier.dart';
import '../notifiers/avatar_notifier.dart';
import '../../domain/usecases/fetch_teacher_home_data_usecase.dart';
import '../../domain/usecases/fetch_all_schedules_usecase.dart';
import '../../domain/usecases/mark_schedule_as_done_usecase.dart';
import '../../domain/usecases/request_class_cancel_usecase.dart';
import '../../domain/usecases/fetch_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../domain/usecases/fetch_teacher_profile_usecase.dart';
import '../../domain/usecases/fetch_teacher_stats_usecase.dart';
import '../../data/datasources/teacher_remote_datasource.dart';
import '../../data/datasources/teacher_notification_remote_datasource.dart';
import '../../data/datasources/teacher_profile_remote_datasource.dart';
import '../../data/datasources/teacher_stats_remote_datasource.dart';
import '../../data/repositories/teacher_repository_impl.dart';
import '../../data/repositories/teacher_notification_repository_impl.dart';
import '../../data/repositories/teacher_profile_repository_impl.dart';
import '../../data/repositories/teacher_stats_repository_impl.dart';

class TeacherServiceLocator {
  static Future<Map<String, dynamic>> setup(SharedPreferences prefs) async {
    final sharedClient = http.Client();
    
    final teacherRemoteDataSource = TeacherRemoteDataSource(
      client: sharedClient,
    );
    final notificationRemoteDataSource = TeacherNotificationRemoteDataSource(
      client: sharedClient,
    );
    final profileRemoteDataSource = TeacherProfileRemoteDataSource(
      client: sharedClient,
    );
    final statsRemoteDataSource = TeacherStatsRemoteDataSource(
      client: sharedClient,
    );

    final teacherRepository = TeacherRepositoryImpl(
      remoteDataSource: teacherRemoteDataSource,
    );
    final notificationRepository = TeacherNotificationRepositoryImpl(
      remoteDataSource: notificationRemoteDataSource,
    );
    final profileRepository = TeacherProfileRepositoryImpl(
      remoteDataSource: profileRemoteDataSource,
    );
    final statsRepository = TeacherStatsRepositoryImpl(
      remoteDataSource: statsRemoteDataSource,
    );

    final fetchHomeDataUseCase = FetchTeacherHomeDataUseCase(
      repository: teacherRepository,
    );
    final fetchAllSchedulesUseCase = FetchAllSchedulesUseCase(
      repository: teacherRepository,
    );
    final markScheduleAsDoneUseCase = MarkScheduleAsDoneUseCase(
      repository: teacherRepository,
    );
    final requestClassCancelUseCase = RequestClassCancelUseCase(
      repository: teacherRepository,
    );
    final fetchNotificationsUseCase = FetchNotificationsUseCase(
      repository: notificationRepository,
    );
    final markNotificationAsReadUseCase = MarkNotificationAsReadUseCase(
      repository: notificationRepository,
    );
    final fetchProfileUseCase = FetchTeacherProfileUseCase(
      repository: profileRepository,
    );
    final fetchStatsUseCase = FetchTeacherStatsUseCase(
      repository: statsRepository,
    );

    final homeNotifier = TeacherHomeNotifier(
      fetchHomeDataUseCase: fetchHomeDataUseCase,
      markScheduleAsDoneUseCase: markScheduleAsDoneUseCase,
      requestClassCancelUseCase: requestClassCancelUseCase,
    );

    final scheduleNotifier = TeacherScheduleNotifier(
      fetchAllSchedulesUseCase: fetchAllSchedulesUseCase,
      markScheduleAsDoneUseCase: markScheduleAsDoneUseCase,
      requestClassCancelUseCase: requestClassCancelUseCase,
    );

    final notificationNotifier = TeacherNotificationNotifier(
      fetchNotificationsUseCase: fetchNotificationsUseCase,
      markNotificationAsReadUseCase: markNotificationAsReadUseCase,
    );

    final profileNotifier = TeacherProfileNotifier(
      fetchProfileUseCase: fetchProfileUseCase,
    );

    final statsNotifier = TeacherStatsNotifier(
      fetchStatsUseCase: fetchStatsUseCase,
    );

    final avatarNotifier = AvatarNotifier();

    return {
      'homeNotifier': homeNotifier,
      'scheduleNotifier': scheduleNotifier,
      'notificationNotifier': notificationNotifier,
      'profileNotifier': profileNotifier,
      'statsNotifier': statsNotifier,
      'avatarNotifier': avatarNotifier,
    };
  }
}
