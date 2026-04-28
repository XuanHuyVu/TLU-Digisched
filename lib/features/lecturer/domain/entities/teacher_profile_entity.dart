class DepartmentEntity {
  final String name;

  const DepartmentEntity({required this.name});
}

class FacultyEntity {
  final String name;

  const FacultyEntity({required this.name});
}

class TeacherProfileEntity {
  final String teacherCode;
  final String fullName;
  final String gender;
  final String email;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final DepartmentEntity? department;
  final FacultyEntity? faculty;
  final String status;

  const TeacherProfileEntity({
    required this.teacherCode,
    required this.fullName,
    required this.gender,
    required this.email,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.department,
    this.faculty,
    required this.status,
  });
}
