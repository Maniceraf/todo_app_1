extension DateHelper on DateTime {
  String formatDate() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} - ${_monthName(month)} $day, $year';
  }

  DateTime dateOnly() {
    return DateTime(year, month, day);
  }

  bool isLate(DateTime date) {
    return dateOnly().isBefore(date.dateOnly());
  }

  bool isToday(DateTime date) {
    return dateOnly().isAtSameMomentAs(date.dateOnly());
  }

  bool isFuture(DateTime date) {
    return dateOnly().isAfter(date.dateOnly());
  }

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}
