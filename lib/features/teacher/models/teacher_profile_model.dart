// lib/features/teacher/models/teacher_profile_model.dart
class TeacherProfile {
  final String teacherCode;
  final String fullName;
  final String gender;
  final String email;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final Department? department;
  final Faculty? faculty;
  final String status;

  TeacherProfile({
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

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      teacherCode: json['teacherCode'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? DateTime.now().toString()),
      phoneNumber: json['phoneNumber'] ?? '',
      department: json['department'] != null ? Department.fromJson(json['department']) : null,
      faculty: json['faculty'] != null ? Faculty.fromJson(json['faculty']) : null,
      status: json['status'] ?? '',
    );
  }
}

class Department {
  final String name;

  Department({required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      name: json['name'] ?? '',
    );
  }
}

class Faculty {
  final String name;

  Faculty({required this.name});

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      name: json['name'] ?? '',
    );
  }
}