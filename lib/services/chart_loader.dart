import 'package:flutter/services.dart';

class ChartLoader {
  static Future<List<String>> loadRaw() async {
    final data = await rootBundle.loadString('assets/JyotishAppCharts.txt');
    return data.split('\n').where((l) => l.trim().isNotEmpty && l.contains(':::')).toList();
  }
}