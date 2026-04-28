import '../../../../config/constants/constants.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.username,
    required super.token,
    required super.role,
    required super.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json[Constants.userName] as String,
      token: json[Constants.token] as String,
      role: json[Constants.role] as String,
      id: json[Constants.id] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constants.userName: username,
      Constants.token: token,
      Constants.role: role,
      Constants.id: id
    };
  }
}
