library;

import 'models.dart';

class CompareSubject {
  CompareChart? get chart => null;
  dynamic toEntry() => null;
}

class CompareChart {
  final String? locationGeneral;
  CompareChart({this.locationGeneral});
}

class CompareEventDetail {
  final String subjectId;
  final bool approximate;
  final String precision;
  final DateTime? date;
  final int? ageYears;
  final String? mdLordLabel;
  final String? adLordLabel;
  final dynamic sadeSatiPhase;
  final Map<Planet, int> transitHousesFromMoon;
  final Map<Planet, int> transitHousesFromLagna;
  CompareEventDetail({
    this.subjectId = '',
    this.approximate = false,
    this.precision = '',
    this.date,
    this.ageYears,
    this.mdLordLabel,
    this.adLordLabel,
    this.sadeSatiPhase,
    Map<Planet, int>? transitHousesFromMoon,
    Map<Planet, int>? transitHousesFromLagna,
  }) : transitHousesFromMoon = transitHousesFromMoon ?? {},
       transitHousesFromLagna = transitHousesFromLagna ?? {};
}

class CompareFinding {
  final String key;
  final String group;
  final List<String> subjectIds;
  final Map<String, String> params;
  final List<CompareEventDetail>? eventDetails;
  CompareFinding({
    this.key = '',
    this.group = '',
    this.subjectIds = const [],
    this.params = const {},
    this.eventDetails,
  });
}

class CompareEntry {}
class MahakoshSubject extends CompareSubject {
  final dynamic mkChart;
  final dynamic snapshot;
  MahakoshSubject({this.mkChart, this.snapshot});
  @override
  CompareChart? get chart => CompareChart();
}
class LocalSubject extends CompareSubject {
  final dynamic kundli;
  final dynamic snapshot;
  final dynamic kundliEvents;
  LocalSubject({this.kundli, this.snapshot, this.kundliEvents});
}

List<CompareFinding> computeCompareFindings({
  required List subjects,
  required dynamic dashaSystem,
  required DateTime now,
  required dynamic transitPositions,
}) => [];

dynamic ephemerisPositionsAt(int id) => null;
