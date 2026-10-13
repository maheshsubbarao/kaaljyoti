import 'package:flutter/services.dart';

class JyotishChart {
  final String name;
  final int day;
  final int month; // 1-12 FIXED
  final int monthZero; // 0-11 original
  final int year;
  final int hour;
  final int minute;
  final int second;
  final String place;
  final double longitude;
  final double latitude;
  final int tzOffsetMinutes; // 330 for IST
  final DateTime birthDateTimeLocal;

  JyotishChart({
    required this.name,
    required this.day,
    required this.month,
    required this.monthZero,
    required this.year,
    required this.hour,
    required this.minute,
    required this.second,
    required this.place,
    required this.longitude,
    required this.latitude,
    required this.tzOffsetMinutes,
    required this.birthDateTimeLocal,
  });

  DateTime get birthUtc {
    final utc = DateTime.utc(year, month, day, hour, minute, second);
    return utc.subtract(Duration(minutes: tzOffsetMinutes));
  }
}

class JyotishImportService {
  static Future<List<JyotishChart>> loadFromAssets() async {
    final content = await rootBundle.loadString('assets/JyotishAppCharts.txt');
    return parseContent(content);
  }

  static List<JyotishChart> parseContent(String content) {
    List<JyotishChart> list = [];
    final lines = content.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty ||!line.contains(':::')) continue;
      try {
        final nameParts = line.split(':::');
        String name = nameParts[0].trim();
        String data = nameParts[1].trim();
        final p = data.split('#');
        if (p.length < 16) continue;

        int day = int.parse(p[0]);
        int monthZero = int.parse(p[1]); // Jan=0 YOUR NOTE
        int month = monthZero + 1; // FIX
        int year = int.parse(p[2]);
        int hour = int.parse(p[3]);
        int minute = int.parse(p[4]);
        int second = int.parse(p[5]);
        int tzH = int.parse(p[6]); // 5
        int tzM = int.parse(p[7]); // 30
        int tzOffset = tzH * 60 + tzM; // 330
        String place = p[9];

        double lonDeg = double.parse(p[10]);
        double lonMin = double.parse(p[11]);
        double longitude = lonDeg + lonMin / 60;

        double latDeg = double.parse(p[13]);
        double latMin = double.parse(p[14]);
        double latitude = latDeg + latMin / 60;

        if (month < 1 || month > 12) continue;

        DateTime localDt = DateTime(year, month, day, hour, minute, second);

        list.add(JyotishChart(
          name: name, day: day, month: month, monthZero: monthZero,
          year: year, hour: hour, minute: minute, second: second,
          place: place, longitude: longitude, latitude: latitude,
          tzOffsetMinutes: tzOffset, birthDateTimeLocal: localDt,
        ));
      } catch (e) { continue; }
    }
    return list;
  }
}