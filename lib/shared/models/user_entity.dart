// lib/shared/models/user_entity.dart
class UserEntity {
  final String username;
  final String token;
  final String role;
  final int id;              // <-- thêm
  final int? teacherId;
  final int? studentId;
  final String? fullName;

  UserEntity({
    required this.username,
    required this.token,
    required this.role,
    required this.id,        // <-- thêm
    this.teacherId,
    this.studentId,
    this.fullName,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] ?? {}) as Map<String, dynamic>;
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse('$v');
    }

    return UserEntity(
      username: (user['username'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      role: (user['role'] ?? '').toString(),
      id: toInt(user['id']) ?? 0,
      teacherId: toInt(user['teacherId']),
      studentId: toInt(user['studentId']),
      fullName: user['fullName']?.toString(),
    );
  }
}
