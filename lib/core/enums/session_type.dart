enum SessionType {
  theory,
  practice,
  unknown;

  String get displayName {
    switch (this) {
      case SessionType.theory:
        return 'Lý thuyết';
      case SessionType.practice:
        return 'Thực hành';
      case SessionType.unknown:
        return 'Không xác định';
    }
  }

  static SessionType fromString(String? value) {
    if (value == null || value.isEmpty) return SessionType.unknown;
    
    switch (value.toUpperCase()) {
      case 'THEORY':
        return SessionType.theory;
      case 'PRACTICE':
        return SessionType.practice;
      default:
        return SessionType.unknown;
    }
  }

  String toApiString() {
    switch (this) {
      case SessionType.theory:
        return 'THEORY';
      case SessionType.practice:
        return 'PRACTICE';
      case SessionType.unknown:
        return 'UNKNOWN';
    }
  }
}
