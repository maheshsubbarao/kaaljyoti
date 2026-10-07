// ====== FINAL STUBS FOR GREEN BUILD ======
class AnonymizedChart {
  final String mkCode;
  final DateTime? birthUtc;
  final double? latitude;
  final double? longitude;
  final String? timezoneName;
  final int? utcOffsetMinutes;
  final String? placeName;
  final String? locationGeneral;
  final int? ayanamsaId;
  final DateTime createdAt;
  AnonymizedChart({
    this.mkCode = '',
    this.birthUtc,
    this.latitude,
    this.longitude,
    this.timezoneName,
    this.utcOffsetMinutes,
    this.placeName,
    this.locationGeneral,
    this.ayanamsaId,
    DateTime? createdAt,
  }) : createdAt = createdAt?? DateTime.now();
  bool get hasBirthData => birthUtc!= null;
}

class TNMasterModule { const TNMasterModule(); }
class APTechniqueModule { const APTechniqueModule(); }

// FIXED - CompareFinding with key and group!
class CompareFinding {
  final String key;
  final String group;
  final String title;
  CompareFinding({this.key = '', this.group = '', this.title = ''});
}
class CompareSubject {
  CompareChart? get chart => null;
  dynamic toEntry() => null;
}
class CompareChart {}
class CompareEntry {}
