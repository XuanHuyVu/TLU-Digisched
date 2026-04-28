import 'package:flutter/foundation.dart';
import '../../domain/entities/teacher_profile_entity.dart';
import '../../domain/usecases/fetch_teacher_profile_usecase.dart';

class TeacherProfileNotifier extends ChangeNotifier {
  final FetchTeacherProfileUseCase fetchProfileUseCase;

  TeacherProfileNotifier({required this.fetchProfileUseCase});

  bool _loading = false;
  String? _error;
  TeacherProfileEntity? _profile;

  bool get loading => _loading;
  String? get error => _error;
  TeacherProfileEntity? get profile => _profile;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await fetchProfileUseCase();
    } catch (e) {
      _error = e.toString();
      _profile = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
