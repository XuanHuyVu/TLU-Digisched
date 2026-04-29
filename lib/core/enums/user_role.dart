/// Enum định nghĩa các vai trò người dùng trong hệ thống
enum UserRole {
  systemAdministrator('SYSTEM_ADMINISTRATOR'),
  academicAffairsOfficer('ACADEMIC_AFFAIRS_OFFICER'),
  department('DEPARTMENT'),
  lecturer('LECTURER'),
  student('STUDENT');

  final String value;

  const UserRole(this.value);

  /// Chuyển đổi từ string sang UserRole enum
  /// Trả về null nếu không tìm thấy role tương ứng
  static UserRole? fromString(String? role) {
    if (role == null || role.isEmpty) return null;
    
    try {
      return UserRole.values.firstWhere(
        (e) => e.value == role.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra xem role có phải là lecturer không
  bool get isLecturer => this == UserRole.lecturer;

  /// Kiểm tra xem role có phải là student không
  bool get isStudent => this == UserRole.student;

  /// Kiểm tra xem role có phải là admin không
  bool get isAdmin => this == UserRole.systemAdministrator;

  /// Kiểm tra xem role có phải là academic affairs officer không
  bool get isAcademicAffairsOfficer => this == UserRole.academicAffairsOfficer;

  /// Kiểm tra xem role có phải là department không
  bool get isDepartment => this == UserRole.department;
}
