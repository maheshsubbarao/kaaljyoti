import 'package:flutter/services.dart';

class JyotishChart {
  final String name;
  final int day;
  final int month; // 1-12 FIXED
  final int monthZero; // 0-11 original
  final int year;
  final int hour; // 24hr fixed
  final int hour12; // original 12hr
  final int minute;
  final int second;
  final int amPmFlag; // 0=AM, 1=PM - BOSS FIX
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
    required this.hour12,
    required this.minute,
    required this.second,
    required this.amPmFlag,
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
        if (p.length < 17) continue;

        int day = int.parse(p[0]);
        int monthZero = int.parse(p[1]);
        int month = monthZero + 1;
        int year = int.parse(p[2]);

        // BOSS FIX - CORRECT PARSING - EXACT AS PER JYOTISH APP
        int hour12 = int.parse(p[3]); // 1-12 original
        int minute = int.parse(p[4]);
        int amPmFlag = int.parse(p[5]); // 0=AM,1=PM

        int tzH = int.parse(p[6]);
        int tzM = int.parse(p[7]);
        int tzOffset = tzH * 60 + tzM;

        String place = p[9];
        double lonDeg = double.parse(p[10]);
        double lonMin = double.parse(p[11]);
        double longitude = lonDeg + lonMin / 60;
        double latDeg = double.parse(p[13]);
        double latMin = double.parse(p[14]);
        double latitude = latDeg + latMin / 60;

        int second = 0;
        if (p.length > 16) {
          second = int.tryParse(p[16].trim())?? 0;
        }

        if (month < 1 || month > 12) continue;

        // BOSS FIX FINAL - 12hr -> 24hr PERFECT LOGIC
        // 8 AM (8#0) -> 8, 6 PM (6#1) -> 18, 12 AM -> 0, 12 PM -> 12
        int hour24 = hour12 % 12; // 12 becomes 0
        if (amPmFlag == 1) {
          hour24 += 12; // PM add 12
        }
        // Results:
        // Mahesh 8#31#0 -> 8%12=8 +0 =8 AM ✓
        // Rama 6#30#1 -> 6%12=6+12=18 PM ✓
        // 12 AM -> 0%12=0+0=0 ✓
        // 12 PM -> 12%12=0+12=12 ✓

        DateTime localDt = DateTime(year, month, day, hour24, minute, second);

        list.add(JyotishChart(
          name: name,
          day: day,
          month: month,
          monthZero: monthZero,
          year: year,
          hour: hour24,
          hour12: hour12,
          minute: minute,
          second: second,
          amPmFlag: amPmFlag,
          place: place,
          longitude: longitude,
          latitude: latitude,
          tzOffsetMinutes: tzOffset,
          birthDateTimeLocal: localDt,
        ));
      } catch (e) {
        continue;
      }
    }
    return list;
  }
}