import '../../domain/entities/teacher_profile_entity.dart';

class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({required super.name});
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(name: json['name'] ?? '');
  }
}

class FacultyModel extends FacultyEntity {
  const FacultyModel({required super.name});
  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(name: json['name'] ?? '');
  }
}

class TeacherProfileModel extends TeacherProfileEntity {
  const TeacherProfileModel({
    required super.teacherCode,
    required super.fullName,
    required super.gender,
    required super.email,
    required super.dateOfBirth,
    required super.phoneNumber,
    super.department,
    super.faculty,
    required super.status,
  });

  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    return TeacherProfileModel(
      teacherCode: json['teacherCode'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] ?? DateTime.now().toString()) ?? DateTime.now(),
      phoneNumber: json['phoneNumber'] ?? '',
      department: json['department'] != null ? DepartmentModel.fromJson(json['department']) : null,
      faculty: json['faculty'] != null ? FacultyModel.fromJson(json['faculty']) : null,
      status: json['status'] ?? '',
    );
  }
}
