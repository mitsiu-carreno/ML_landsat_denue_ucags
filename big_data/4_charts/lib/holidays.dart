class Holidays {
  final int day;
  final String locations;
  final int month;
  final String name;
  final int year;

  Holidays(
      {required this.day,
      required this.locations,
      required this.month,
      required this.name,
      required this.year});

  factory Holidays.fromJson(Map<String, dynamic> json) {
    return Holidays(
      day: json['day'],
      locations: json['locations'],
      month: json['month'],
      name: json['name'],
      year: json['year'],
    );
  }
}
