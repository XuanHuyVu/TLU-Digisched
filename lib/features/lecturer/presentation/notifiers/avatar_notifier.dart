import 'package:flutter/foundation.dart';
import '../../../../../services/avatar_service.dart';

class AvatarNotifier extends ChangeNotifier {
  String? _avatarBase64;
  String? get avatarBase64 => _avatarBase64;
  
  Future<void> loadAvatar() async {
    _avatarBase64 = await AvatarService.loadAvatar();
    notifyListeners();
  }
  
  Future<void> pickAvatar() async {
    final newAvatar = await AvatarService.pickAvatar();
    if (newAvatar != null) {
      _avatarBase64 = newAvatar;
      notifyListeners();
    }
  }
  
  Future<void> removeAvatar() async {
    await AvatarService.removeAvatar();
    _avatarBase64 = null;
    notifyListeners();
  }
}
