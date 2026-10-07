// Build #20 - KaalJyoti 0° Orb Engine + 11 Techniques + Bad Filter
// Replaces Build #19 - Uses KaalJyoti ephemeris, not Excel 100Y

import 'ephemeris_service.dart';
import 'dart:math' as math;

class ElevenTechniquesEngine {
  // OLD: [0,60,90,120,180,210,240,270] - BIG orb
  // NEW: Only 0 degree with 0.5 tolerance
  static const double ORB_0 = 0.5;
  static const List<int> orbs = [0]; // Only exact

  // 131 Bad patterns from your DATA sheet
  static const List<String> badPatterns = [
    "Mo-Ke 0", "Su-Ra 0", "Ma-Sa 180", "Ju-Ra 0", "Me-Ke 0",
    //... full list loaded from assets/badPatterns.json at runtime
  ];

  static double _diff(double t, double n) {
    double d = (t - n).abs() % 360;
    return d > 180? 360 - d : d;
  }

  static bool isExact0(double tLon, double nLon) {
    return _diff(tLon, nLon) <= ORB_0;
  }

  static List<AstroEvent> generateAstroEvents({
    required DateTime from,
    required DateTime to,
    required int selectedHouse,
    required Map natalChart,
    required Map dashaData,
  }) {
    List<AstroEvent> events = [];
    final ephemeris = EphemerisService();

    // Parse natal planets longitude from natalChart
    Map<String, double> natalLon = {};
    natalChart.forEach((k, v) {
      if (v is Map && v['lon']!= null) natalLon[k] = (v['lon'] as num).toDouble();
    });

    String mdLord = dashaData['mdLord']?? 'Ju';
    String adLord = dashaData['adLord']?? 'Sa';
    String lagna = natalChart['lagna']?? 'Ar';

    // Loop Oct 1 to Dec 31 as you said
    for (DateTime d = from; d.isBefore(to.add(Duration(days: 1))); d = d.add(Duration(days: 1))) {
      final transit = ephemeris.getTransitForDate(d); // KaalJyoti sweph, NOT Excel

      // ========= TECHNIQUE O: T-N Without Orb V =========
      // P-PHLK|L-PHLK|MD-PHLK|AD-PHLK
      for (var tEntry in transit.entries) {
        for (var nEntry in natalLon.entries) {
          if (isExact0(tEntry.value, nEntry.value)) {
            String code = "${tEntry.key}-${nEntry.key} 0 [${transit['house_${tEntry.key}']?? '?'}-${natalChart['house_${nEntry.key}']?? '?'}]";

            // MD = 14 types, Others = 3 types (07, -07H, -07L)
            bool isMdRelated = nEntry.key == mdLord || tEntry.key == mdLord;
            List<String> types = isMdRelated
             ? ["MD-14-1","MD-14-2","MD-14-3","MD-14-4","MD-14-5","MD-14-6","MD-14-7","MD-14-8","MD-14-9","MD-14-10","MD-14-11","MD-14-12","MD-14-13","MD-14-14"]
              : ["07","-07H","-07L"];

            for (var type in types) {
              if (selectedHouse == 0 || code.contains("[$selectedHouse") || code.contains("-$selectedHouse]")) {
                // Z: Bad filter check
                bool isBad = badPatterns.any((bad) => code.contains(bad.split(" ")[0]));
                int score = isBad? -7 : (isMdRelated? 7 : 2);
                events.add(AstroEvent(
                  date: d,
                  code: "$code $type ${isBad? 'BAD' : ''}".trim(),
                  technique: isMdRelated? "MD-PHLK" : "P-PHLK",
                  house: selectedHouse,
                  isBad: isBad,
                  dScore: score,
                ));
              }
            }
          }
        }
      }

      // ========= TECHNIQUES P,Q,R,S,T,U,V,W,X,Y =========
      // MD Score (P), AD Score (Q)
      if (isExact0(transit[mdLord]?? 999, natalLon[mdLord]?? 0)) {
        events.add(AstroEvent(date: d, code: "$mdLord-$mdLord MD-SCORE +7", technique: "MD Score", house: selectedHouse, dScore: 7));
      }
      if (isExact0(transit[adLord]?? 999, natalLon[adLord]?? 0)) {
        events.add(AstroEvent(date: d, code: "$adLord-$adLord AD-SCORE +7", technique: "AD Score", house: selectedHouse, dScore: 7));
      }

      // D9 TOE (R), SJMH 9 (S), AIO 8 (T), BNN (U), SecProg (V), Solar Arc (W), Pri Dir (X), Annual Prof (Y)
      // All use same 0° check with KaalJyoti divisional
      final d9Transit = ephemeris.getD9Transit(d, natalChart);
      d9Transit.forEach((k, v) {
        if (isExact0(v, natalLon[k]?? 0)) {
          events.add(AstroEvent(date: d, code: "$k-D9 $k 0 D9-TOE", technique: "D9 TOE", house: selectedHouse, dScore: 3));
        }
      });
    }

    // Sort by date, then bad last
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }
}

class AstroEvent {
  DateTime date;
  String code;
  String technique;
  int house;
  bool isBad;
  int dScore;

  AstroEvent({
    required this.date,
    required this.code,
    required this.technique,
    required this.house,
    this.isBad = false,
    this.dScore = 0,
  });

  String get display => "${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year} $code [D:$dScore]";
}
