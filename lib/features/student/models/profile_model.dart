class ProfileModel {
  final int id;
  final String studentCode;
  final String fullName;
  final String gender;
  final String className;
  final int enrollmentYear;
  final String majorName;
  final String facultyName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;

  ProfileModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.gender,
    required this.className,
    required this.enrollmentYear,
    required this.majorName,
    required this.facultyName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      studentCode: json['studentCode'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      className: json['className'] ?? '',
      enrollmentYear: json['enrollmentYear'] ?? 0,
      majorName: json['major']?['name'] ?? '',
      facultyName: json['faculty']?['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
    );
  }
}
