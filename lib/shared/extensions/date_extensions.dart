extension DateX on DateTime {
  String toYMD() {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    return '$year-$mm-$dd';
  }

  String toDdMMyyyy() {
    final dd = day.toString().padLeft(2, '0');
    final mm = month.toString().padLeft(2, '0');
    return '$dd/$mm/$year';
  }
}