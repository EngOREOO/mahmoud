class DateDiffDuration {
  int seconds;
  int minutes;
  int hours;

  int days;
  int months;
  int years;

  DateDiffDuration({
    this.seconds = 0,
    this.minutes = 0,
    this.hours = 0,
    this.days = 0,
    this.months = 0,
    this.years = 0,
  });

  String toHourMinutesSeconds() {
    return '$years h, $months m, $days s';
  }

  @override
  String toString() {
    return 'Years: $years, Months: $months, Days: $days';
  }
}

/// Age Class
class DateTimeDifferenceCalculator {
  /// _daysInMonth cost contains days per months; daysInMonth method to be used instead.
  static const List<int> _daysInMonth = [
    31, // Jan
    28, // Feb, it varies from 28 to 29
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31 // Dec
  ];

  /// isLeapYear method
  static bool isLeapYear(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));

  /// daysInMonth method
  static int daysInMonth(int year, int month) =>
      (month == DateTime.february && isLeapYear(year))
          ? 29
          : _daysInMonth[month - 1];

  /// dateDifference method
  static DateDiffDuration dateDifference({
    required DateTime fromDate,
    required DateTime toDate,
    bool includeToDate = false,
  }) {
    // Check if toDate to be included in the calculation
    DateTime endDate =
        (includeToDate) ? toDate.add(const Duration(days: 1)) : toDate;

    int years = endDate.year - fromDate.year;
    int months = 0;
    int days = 0;

    if (fromDate.month > endDate.month) {
      years--;
      months = (DateTime.monthsPerYear + endDate.month - fromDate.month);

      if (fromDate.day > endDate.day) {
        months--;
        days = daysInMonth(fromDate.year + years,
                ((fromDate.month + months - 1) % DateTime.monthsPerYear) + 1) +
            endDate.day -
            fromDate.day;
      } else {
        days = endDate.day - fromDate.day;
      }
    } else if (endDate.month == fromDate.month) {
      if (fromDate.day > endDate.day) {
        years--;
        months = DateTime.monthsPerYear - 1;
        days = daysInMonth(fromDate.year + years,
                ((fromDate.month + months - 1) % DateTime.monthsPerYear) + 1) +
            endDate.day -
            fromDate.day;
      } else {
        days = endDate.day - fromDate.day;
      }
    } else {
      months = (endDate.month - fromDate.month);

      if (fromDate.day > endDate.day) {
        months--;
        days = daysInMonth(fromDate.year + years, (fromDate.month + months)) +
            endDate.day -
            fromDate.day;
      } else {
        days = endDate.day - fromDate.day;
      }
    }

    return DateDiffDuration(days: days, months: months, years: years);
  }

  /// add method
  static DateTime add({
    required DateTime date,
    required DateDiffDuration duration,
  }) {
    int years = date.year + duration.years;
    years += (date.month + duration.months) ~/ DateTime.monthsPerYear;

    int months = ((date.month + duration.months) % DateTime.monthsPerYear);

    int days = date.day + duration.days - 1;

    return DateTime(years, months, 1).add(Duration(days: days));
  }

  /// subtract methos
  static DateTime subtract({
    required DateTime date,
    required DateDiffDuration duration,
  }) {
    duration.days *= -1;
    duration.months *= -1;
    duration.years *= -1;

    return add(date: date, duration: duration);
  }
}