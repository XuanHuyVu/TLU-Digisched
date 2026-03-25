import 'package:flutter/foundation.dart';
import '../models/teacher_profile_model.dart';
import '../services/teacher_profile_service.dart';

class TeacherProfileViewModel extends ChangeNotifier {
  final TeacherProfileService _service = TeacherProfileService();

  TeacherProfile? profile;
  bool isLoading = false;
  String? error;

  Future<void> fetchProfile() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      profile = await _service.getProfile();
    } catch (e) {
      error = e.toString();
      profile = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
