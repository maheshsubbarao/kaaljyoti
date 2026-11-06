import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';
import 'package:csv/csv.dart';
import '../utils/csv_export.dart';
import '../core/astro/models.dart';
import '../core/astro/transit_scan.dart';
import '../core/astro/event_feed.dart';
// import '../core/astro/ephemeris_service.dart';
import '../core/astro/transit.dart' as transit;

String _hh(int n) => n.toString().padLeft(2, '0');
List<int> _off(String p) {
  switch (p) {
    case 'Ma':
      return [0, 3, 6, 7];
    case 'Ju':
      return [0, 4, 6, 8];
    case 'Sa':
      return [0, 2, 6, 9];
    case 'Ra':
    case 'Ke':
      return [0, 4, 6, 8];
    default:
      return [0, 6];
  }
}

bool _asp(int f, String p, int t) {
  for (var o in _off(p)) {
    int h = f + o;
    while (h > 12) h -= 12;
    if (h == t) return true;
  }
  return false;
}

Map<int, String> getLordsForAsc(int asc) {
  const lm = [
    '',
    'Ma',
    'Ve',
    'Me',
    'Mo',
    'Su',
    'Me',
    'Ve',
    'Ma',
    'Ju',
    'Sa',
    'Sa',
    'Ju'
  ];
  Map<int, String> l = {};
  for (int h = 1; h <= 12; h++) {
    int s = ((asc - 1 + h - 1) % 12) + 1;
    l[h] = lm[s];
  }
  return l;
}

Map<String, List<int>> getOwn(Map<int, String> lords) {
  Map<String, List<int>> o = {};
  lords.forEach((h, lord) {
    o.putIfAbsent(lord, () => []);
    o[lord]!.add(h);
  });
  return o;
}

String _planetToAbbr(dynamic p) {
  String s = p.toString().toLowerCase();
  if (s.contains('sun')) return 'Su';
  if (s.contains('moon')) return 'Mo';
  if (s.contains('mars')) return 'Ma';
  if (s.contains('mercury')) return 'Me';
  if (s.contains('jupiter')) return 'Ju';
  if (s.contains('venus')) return 'Ve';
  if (s.contains('saturn')) return 'Sa';
  if (s.contains('rahu')) return 'Ra';
  if (s.contains('ketu')) return 'Ke';
  return '';
}

String _lordOfSign(int sign) {
  const lm = [
    '',
    'Ma',
    'Ve',
    'Me',
    'Mo',
    'Su',
    'Me',
    'Ve',
    'Ma',
    'Ju',
    'Sa',
    'Sa',
    'Ju'
  ];
  return lm[sign];
}

double _d9Lon(double lon) {
  double deg = lon % 30;
  double navDeg = (deg * 9) % 30;
  int sign = (lon ~/ 30);
  return (sign * 30 + navDeg) % 360;
}

bool _isTrine(double natalD9, double transitLon) {
  double diff = (natalD9 - transitLon) % 360;
  if (diff < 0) diff += 360;
  int houseDiff = (diff / 30).floor();
  return houseDiff == 0 || houseDiff == 4 || houseDiff == 8;
}

double _norm360(double x) => ((x % 360) + 360) % 360;

// EXACT WHOLE SIGN - SAME AS TRANSIT WIDGET! NO APPROXIMATE!
int _houseWhole(double lon, int ascSign) {
  int tSign = (lon ~/ 30) + 1; // 1=Ar ... 12=Pi
  return ((tSign - ascSign + 12) % 12) + 1; // Pi 29:59 = Pi Sign 12 = 1H!
}

/// BOSS FIX: For Rahu/Ketu, degree display reversed!
/// Normal planets: 0° = beginning of house
/// Rahu/Ketu: 30° = beginning of house (retrograde) so display reversed!
// ignore: unused_element
double _displayDegForPlanet(String planetAbbr, double lon) {
  double deg = lon % 30;
  if (planetAbbr == 'Ra' || planetAbbr == 'Ke') {
    return (30.0 - deg) % 30; // 0°00'05" -> 29°59'55"
  }
  return deg;
}

List<String> _getNatalAssociated(String planet, Map<String, int> natalH) {
  int? pHouseOrNull = natalH[planet];
  if (pHouseOrNull == null) return [planet];
  int pHouse = pHouseOrNull;
  List<String> assoc = [planet];
  natalH.forEach((other, otherHouse) {
    if (other == planet) return;
    if (otherHouse == pHouse) {
      assoc.add(other); // conjunct
    } else if (_asp(otherHouse, other, pHouse)) {
      assoc.add(other); // aspects planet house
    }
  });
  return assoc.toSet().toList();
}

class _DashaInfo {
  String md;
  String ad;
  _DashaInfo(this.md, this.ad);
}

_DashaInfo _getMDAD(DateTime dob, DateTime target, double moonLon) {
  const seq = ['Ke', 'Ve', 'Su', 'Mo', 'Ma', 'Ra', 'Ju', 'Sa', 'Me'];
  const dur = [7, 20, 6, 10, 7, 18, 16, 19, 17];
  double nakFloat = (moonLon % 360) * 27.0 / 360.0;
  int nakIdx = nakFloat.floor() % 27;
  int lordIdx = nakIdx % 9;
  double rem = 1.0 - (nakFloat - nakIdx);
  double balance = rem * dur[lordIdx];
  DateTime cur = dob;
  int idx = lordIdx;
  double left = balance;
  while (cur.isBefore(target)) {
    double mdDays = left * 365.2425;
    DateTime mdEnd = cur.add(Duration(days: mdDays.round()));
    if (target.isBefore(mdEnd)) {
      String md = seq[idx];
      double elapsed = target.difference(cur).inDays.toDouble();
      double adElapsed = elapsed / mdDays * 120.0;
      double acc = 0;
      for (int j = 0; j < 9; j++) {
        int aIdx = (idx + j) % 9;
        double adPortion = dur[idx] * dur[aIdx] / 120.0;
        if (adElapsed < acc + adPortion) {
          return _DashaInfo(md, seq[aIdx]);
        }
        acc += adPortion;
      }
      return _DashaInfo(md, md);
    } else {
      cur = mdEnd;
      idx = (idx + 1) % 9;
      left = dur[idx].toDouble();
    }
  }
  return _DashaInfo(seq[idx], seq[idx]);
}
String? _westernAspectExact(double diff) {
  double d = diff.abs();
  if (d > 180) d = 360 - d;
  if (d < 0.5) return "0";
  if ((d - 60).abs() < 0.5) return "1";
  if ((d - 90).abs() < 0.5) return "2";
  if ((d - 120).abs() < 0.5) return "3";
  if ((d - 150).abs() < 0.5) return "4";
  if ((d - 180).abs() < 0.5) return "5";
  return null;
}

Map<String, String> _jaiminiMap(Map<String, double> natalLon) {
  List<MapEntry<String, double>> list = [];
  for (var e in natalLon.entries) {
    if (['Su', 'Mo', 'Me', 'Ve', 'Ma', 'Ju', 'Sa'].contains(e.key)) {
      list.add(MapEntry(e.key, e.value % 30));
    }
  }
  list.sort((a, b) => b.value.compareTo(a.value));
  const karakas = ['AK', 'AmK', 'BK', 'MK', 'PK', 'GK', 'DK'];
  Map<String, String> m = {};
  for (int i = 0; i < list.length && i < 7; i++) {
    m[list[i].key] = karakas[i];
  }
  return m;
}

String _jkForHouse(int h) {
  switch (h) {
    case 1:
      return 'AK';
    case 2:
      return 'AmK';
    case 3:
      return 'BK';
    case 4:
      return 'MK';
    case 5:
      return 'PK';
    case 6:
      return 'GK';
    case 7:
      return 'DK';
    case 8:
      return 'GK';
    case 9:
      return 'BK';
    case 10:
      return 'AmK';
    case 11:
      return 'AK';
    case 12:
      return 'GK';
    default:
      return 'GK';
  }
}

class GlobalRange {
  static ValueNotifier<DateTime> from =
      ValueNotifier(DateTime(DateTime.now().year, DateTime.now().month, 1));
  static ValueNotifier<DateTime> to =
      ValueNotifier(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
}

class GlobalDateRangeWidgetT1 extends StatelessWidget {
  const GlobalDateRangeWidgetT1({super.key});
  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
        valueListenable: GlobalRange.from,
        builder: (context, fromVal, _) {
          return ValueListenableBuilder<DateTime>(
              valueListenable: GlobalRange.to,
              builder: (context, toVal, __) {
                return Wrap(spacing: 8, children: [
                  InkWell(
                      onTap: () async {
                        DateTime? p = await showDatePicker(
                            context: context,
                            initialDate: fromVal,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(DateTime.now().year + 50));
                            if (p != null) { GlobalRange.to.value = p; if (p.isBefore(GlobalRange.from.value)) GlobalRange.from.value = p.subtract(const Duration(days: 30)); }
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade300)),
                          child: Text(_fmt(fromVal),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)))),
                  const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text("To",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold))),
                  InkWell(
                      onTap: () async {
                        DateTime? p = await showDatePicker(
                            context: context,
                            initialDate: toVal,
                            firstDate: DateTime(1900),
			    lastDate: DateTime(DateTime.now().year + 50));
                        if (p != null) GlobalRange.to.value = p;
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade300)),
                          child: Text(_fmt(toVal),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)))),
                ]);
              });
        });
  }
}

class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'md',
      title: 'T1 T-N Aspects',
      icon: Icons.auto_awesome,
      category: 'Techniques',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext context, ModuleContext ctx) =>
      _DashaFullCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('T1 T-N Aspects')];
}

class _DashaFullCard extends ConsumerStatefulWidget {
  final ModuleContext ctx;
  const _DashaFullCard({required this.ctx});
  @override
  ConsumerState<_DashaFullCard> createState() => _DashaFullCardState();
}

class _DashaFullCardState extends ConsumerState<_DashaFullCard> {
  Future<void> _exportToExcel(List<Map<String, dynamic>> rows) async {
    List<List<dynamic>> csvData = [];
    csvData.add([
      "Date",
      "T-N",
      "TS-NS",
      "H1",
      "H2",
      "H3",
      "H4",
      "H5",
      "H6",
      "H7",
      "H8",
      "H9",
      "H10",
      "H11",
      "H12"
    ]);
    for (var r in rows) {
      Map<int, List<String>> tags = r['tags'] as Map<int, List<String>>;
      List<dynamic> line = [];
      line.add(r['date']);
      line.add(r['tn']);
      line.add(r['tsns']);
      for (int h = 1; h <= 12; h++) {
        line.add((tags[h] ?? []).join(' '));
      }
      csvData.add(line);
    }
    String csv = const ListToCsvConverter().convert(csvData);
    await exportCsv(csv, "T1_TN_${DateTime.now().millisecondsSinceEpoch}.csv");
  }

  @override
  Widget build(BuildContext context) {
    final snap = widget.ctx.snapshot;
    return ValueListenableBuilder<DateTime>(
        valueListenable: GlobalRange.from,
        builder: (context, fromVal, _) {
          return ValueListenableBuilder<DateTime>(
              valueListenable: GlobalRange.to,
              builder: (context, toVal, __) {
                DateTime from =
                    DateTime(fromVal.year, fromVal.month, fromVal.day, 0, 0)
                        .toUtc();
                                DateTime to =
                    DateTime(toVal.year, toVal.month, toVal.day, 23, 59)
                        .toUtc();
                if (to.difference(from).inDays > 370 || to.isBefore(from)) {
                  return Card(child: Padding(padding: const EdgeInsets.all(12), child: Text('Select max 1 year range. To is too far from From - pick To within 1 year of From.', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))));
                }
                List<Map<String, dynamic>> rows = [];
                try {
                  Map<String, double> natalPoints = natalPointsFor(snap);
                  int asc = 0;
                  try {
                    if (natalPoints.containsKey('Lagna')) {
                      asc = (natalPoints['Lagna']! ~/ 30) +
                          1; // EXACT FROM LAGNA!
                    } else {
                      var ls = snap.lagnaSign;
                      asc = ls is int ? ls : (ls as dynamic).index + 1;
                    }
                  } catch (e) {}
                  final lords = getLordsForAsc(asc);
                  final own = getOwn(lords);
                  Map<String, double> natalLon = {};
                  try {
                    snap.positions.forEach((pl, pos) {
                      String ab = _planetToAbbr(pl);
                      natalLon[ab] = pos.longitude;
                    });
                  } catch (e) {}
                  Map<String, int> natalH = {};
                  try {
                    var m = (snap as dynamic).planetHouses;
                    if (m != null) natalH = Map<String, int>.from(m);
                  } catch (e) {}
                  if (natalH.isEmpty) {
                    // Compute houses from longitude + asc - do not depend on planetHouses field
                    natalLon.forEach((ab, lon) {
                      natalH[ab] = _houseWhole(lon, asc);
                    });
                  }
                  if (natalH.isEmpty) {
                    return Card(child: Padding(padding: EdgeInsets.all(12), child: Text('No natal houses - check kundli')));
                  }
                  Map<int, double> natalLordD9 = {};
                  for (int req = 1; req <= 12; req++) {
                    String lord = lords[req]!;
                    double lon = natalLon[lord] ?? 0;
                    natalLordD9[req] = _d9Lon(lon);
                  }
                  double ascLon = (asc - 1) * 30.0;
                  List<double> sandhi =
                      List.generate(12, (i) => (ascLon + i * 30) % 360);
                  List<TransitEvent> exactEvents = [];
                  for (final p in Planet.values) {
                    final f = ephemerisLongitude(p, snap.ayanamsaId);
                    for (final d in drishtisOf(p)) {
                      final angle = drishtiAngle[d]!;
                      for (final entry in natalPoints.entries) {
                        final target = _norm360(entry.value - angle);
                        final crosses =
                            findLongitudeCrossings(f, target, from, to);
                        for (final t in crosses) {
                          if (t.isBefore(from) || t.isAfter(to)) continue;
                          exactEvents.add(TransitEvent(
                              planet: p,
                              kind: TransitEventKind.aspect,
                              time: t,
                              natalPoint: entry.key,
                              drishti: d));
                        }
                      }
                    }
                    for (int cuspIdx = 0; cuspIdx < 12; cuspIdx++) {
                      final target = sandhi[cuspIdx];
                      final crosses =
                          findLongitudeCrossings(f, target, from, to);
                      for (final t in crosses) {
                        if (t.isBefore(from) || t.isAfter(to)) continue;
                        exactEvents.add(TransitEvent(
                            planet: p,
                            kind: TransitEventKind.aspect,
                            time: t,
                            natalPoint: 'House${cuspIdx + 1}',
                            drishti: 1));
                      }
                    }
                  }
                  exactEvents.sort((a, b) => a.time.compareTo(b.time));
                  if (exactEvents.length > 500) exactEvents = exactEvents.sublist(0, 500);
                  DateTime dob;
                  int utcOffsetMinutes = 0;
                  try {
                    final k = widget.ctx.kundli;
                    utcOffsetMinutes = k.utcOffsetMinutes;
                    dob = k.birthUtc.add(Duration(minutes: utcOffsetMinutes));
                  } catch (e) {
      		   rethrow;
                  }
                  if (!natalLon.containsKey('Mo')) throw Exception('Mo longitude missing');
                  double moonLon = natalLon['Mo']!;
                  Map<String, String> jaiminiPlanets = _jaiminiMap(natalLon);
                  Map<String, String> jkToPlanet = {};
                  jaiminiPlanets.forEach((pl, jk) {
                    jkToPlanet[jk] = pl;
                  });
                  int moonSign = natalLon.containsKey('Mo')
        	      ? ((natalLon['Mo']! ~/ 30) + 1)
                      : 0;
                  for (final ev in exactEvents) {
                    DateTime utc = ev.time;
                    DateTime ist =
                        utc.add(Duration(minutes: utcOffsetMinutes));
                    String dateStr =
                        "${ist.day.toString().padLeft(2, '0')}-${ist.month.toString().padLeft(2, '0')}-${ist.year} ${ist.hour.toString().padLeft(2, '0')}:${ist.minute.toString().padLeft(2, '0')}";
                    Map<String, double> tLonMap = {};
                    Map<String, int> tHouseMap = {};
                    try {
                      var curPos = transit.currentTransitPositions(
                          ayanamsaId: snap.ayanamsaId, at: utc);
                      curPos.forEach((pl, pos) {
                        String ab = _planetToAbbr(pl);
                        tLonMap[ab] = pos.longitude;
                        tHouseMap[ab] = _houseWhole(pos.longitude, asc);
                      });
                    } catch (e) {
                      for (final p in Planet.values) {
                        try {
                          double lon =
                              ephemerisLongitude(p, snap.ayanamsaId)(utc);
                          String ab = _planetToAbbr(p);
                          tLonMap[ab] = lon;
                          tHouseMap[ab] = _houseWhole(lon, asc);
                        } catch (_) {}
                      }
                    }
                    String tpAb = _planetToAbbr(ev.planet);
                    String natalLabel = ev.natalPoint ?? '';
                    int? eventHouseNum;
                    if (natalLabel.startsWith('House')) {
                      eventHouseNum = int.tryParse(
                          natalLabel.replaceAll(RegExp(r'[^0-9]'), ''));
                    }
                    int? transitHouseOrNull = tHouseMap[tpAb];
                    if (transitHouseOrNull == null) continue;
                    int transitHouse = transitHouseOrNull;
                    if (eventHouseNum != null &&
                        transitHouse != eventHouseNum) {
                      continue;
                    }
                    int effectiveHouse = eventHouseNum ?? transitHouse;
                    String tnVal = "";
                    String npAb = "";
                    if (natalLabel.startsWith('House')) {
                      tnVal = "$tpAb-${_hh(effectiveHouse)}H (${ev.drishti})";
                    } else if (natalLabel == 'Lagna') {
                      tnVal = "$tpAb-01H (${ev.drishti})";
                    } else {
                      if (natalPoints.containsKey(natalLabel)) {
                        for (final entry in snap.positions.entries) {
                          if (entry.value.planet.displayName == natalLabel) {
                            npAb = _planetToAbbr(entry.key);
                            break;
                          }
                        }
                      }
                      tnVal = npAb.isNotEmpty
                          ? "$tpAb-$npAb (${ev.drishti})"
                          : "$tpAb-$natalLabel (${ev.drishti})";
                    }
                    List<String> rashiShort = [
                      '',
                      'Ar',
                      'Ta',
                      'Ge',
                      'Cn',
                      'Le',
                      'Vi',
                      'Li',
                      'Sc',
                      'Sg',
                      'Cp',
                      'Aq',
                      'Pi'
                    ];
                    if (!tLonMap.containsKey(tpAb)) continue;
                    double tLonForSign = tLonMap[tpAb]!;
                    int tSign = (tLonForSign ~/ 30) + 1;
                    int nSignForTSNS = 1;
                    if (natalLabel.startsWith('House')) {
                      int hn = eventHouseNum ?? 1;
                      int sign = ((asc - 1 + hn - 1) % 12) + 1;
                      nSignForTSNS = sign;
                    } else if (natalPoints.containsKey(natalLabel)) {
                      double nLon = natalPoints[natalLabel]!;
                      nSignForTSNS = (nLon ~/ 30) + 1;
                    }
                    String tsnsVal =
                        "${rashiShort[tSign]}-${rashiShort[nSignForTSNS]}";
                    bool aspectsHL(String pAb, int targetHouse) {
                      int? th = tHouseMap[pAb];
                      if (th == null) return false;
                      int? targetLordHouseOrNull =
                          natalH[lords[targetHouse]];
                      if (targetLordHouseOrNull == null) return false;
                      int targetLordHouse = targetLordHouseOrNull;
                      return _asp(th, pAb, targetHouse) ||
                          _asp(th, pAb, targetLordHouse);
                    }

                    Map<int, int> knrPoints = {};
                    final karaka = {
                      1: 'Su',
                      2: 'Ju',
                      3: 'Ma',
                      4: 'Ve',
                      5: 'Ju',
                      6: 'Ma',
                      7: 'Ve',
                      8: 'Sa',
                      9: 'Ju',
                      10: 'Su',
                      11: 'Ju',
                      12: 'Sa'
                    };
                    for (int req = 1; req <= 12; req++) {
                      String kar = karaka[req]!;
                      bool p1a = aspectsHL('Sa', 1) ||
                          aspectsHL('Ra', 1) ||
                          aspectsHL('Ke', 1);
                      bool p1b = aspectsHL('Sa', req) ||
                          aspectsHL('Ra', req) ||
                          aspectsHL('Ke', req);
                      bool point1 = p1a && p1b;
                      bool ju01 = aspectsHL('Ju', 1);
                      bool ju05 = aspectsHL('Ju', 5);
                      bool ju09 = aspectsHL('Ju', 9);
                      bool juReq = aspectsHL('Ju', req);
                      bool karOk = aspectsHL(kar, req) || aspectsHL(kar, 1);
                      bool point2 = ju01 && ju05 && (ju09 || (karOk && juReq));
                      bool ma01 = aspectsHL('Ma', 1);
                      bool ma05 = aspectsHL('Ma', 5);
                      bool ma09 = aspectsHL('Ma', 9);
                      bool maReq = aspectsHL('Ma', req);
                      bool point3 = ma01 && ma05 && (ma09 || (karOk && maReq));
                      String lordPlanet = lords[req]!;
                      int? lordTh = tHouseMap[lordPlanet];
                      bool lord01L = false, lord09H = false, lord11H = false;
                      if (lordTh != null) {
                        int lordOf1House = natalH[lords[1] ?? 'Su'] ?? 12;
                        lord01L = _asp(lordTh, lordPlanet, lordOf1House) ||
                            _asp(lordTh, lordPlanet, 1);
                        lord09H = _asp(lordTh, lordPlanet, 9);
                        lord11H = _asp(lordTh, lordPlanet, 11);
                      }
                      bool point4 = lord01L || lord09H || lord11H;
                      int pts = 0;
                      if (point1) pts++;
                      if (point2) pts++;
                      if (point3) pts++;
                      if (point4) pts++;
                      knrPoints[req] = pts;
                    }
                    Map<int, List<String>> houseTags = {};
                    _DashaInfo mdad = _getMDAD(dob, ist, moonLon);
                    List<int> mdOwn = own[mdad.md] ?? [];
                    List<int> adOwn = own[mdad.ad] ?? [];
                    int age = ist.difference(dob).inDays ~/ 365;
                    DateTime progDate = dob.add(Duration(days: age));
                    Map<String, double> progLon = {};
                    for (final p in Planet.values) {
                      try {
                        double lon = ephemerisLongitude(p, snap.ayanamsaId)(
                            progDate.toUtc());
                        progLon[_planetToAbbr(p)] = lon;
                      } catch (e) {}
                    }
                    double arcSA = _norm360(
                        (progLon['Su'] ?? natalLon['Su'] ?? 0) -
                            (natalLon['Su'] ?? 0));
                    Map<String, double> saLon = {};
                    natalLon.forEach((k, v) {
                      saLon[k] = _norm360(v + arcSA);
                    });
                    double arcPD = age.toDouble();
                    Map<String, double> pdLon = {};
                    natalLon.forEach((k, v) {
                      pdLon[k] = _norm360(v + arcPD);
                    });
                    int pH = (age % 12) + 1;
                    String lordOfPH = lords[pH] ?? 'Su';

                    for (int req = 1; req <= 12; req++) {
                      List<String> tags = [];
                      if (effectiveHouse == req) {
                        tags.add("${_hh(req)}H");
                      }
                      String rLord = lords[req]!;
                      int rLordH = natalH[rLord] ?? 12;
                      String k = karaka[req]!;
                      int kH = natalH[k] ?? 12;
                      int kSign = natalLon.containsKey(k)
                          ? ((natalLon[k]! ~/ 30) + 1)
                          : 1;
                      String lfkLord =
                          _lordOfSign(((kSign - 1 + req - 1) % 12) + 1);
                      int lfkLordH = natalH[lfkLord] ?? 12;
                      int hfmSign = ((moonSign - 1 + req - 1) % 12) + 1;
                      int hfmSignHouse = ((hfmSign - asc + 12) % 12) + 1;
                      String lfmLord = _lordOfSign(hfmSign);
                      int lfmLordH = natalH[lfmLord] ?? 12;
                      int hfkSign = ((kSign - 1 + req - 1) % 12) + 1;
                      int hfkHouse = ((hfkSign - asc + 12) % 12) + 1;
                      if (_asp(transitHouse, tpAb, req))
                        tags.add("${_hh(req)}H");
                      if (_asp(transitHouse, tpAb, rLordH))
                        tags.add("${_hh(req)}L");
                      if (_asp(transitHouse, tpAb, kH))
                        tags.add("${_hh(req)}K");
                      String jkNeeded = _jkForHouse(req);
                      String? jkPlanet = jkToPlanet[jkNeeded];
                      if (jkPlanet != null) {
                        int jkH = natalH[jkPlanet] ?? 12;
                        if (_asp(transitHouse, tpAb, jkH))
                          tags.add("${_hh(req)}JK");
                      }
                      if (_asp(transitHouse, tpAb, lfkLordH))
                        tags.add("${_hh(req)}LFK");
                      if (_asp(transitHouse, tpAb, hfkHouse))
                        tags.add("${_hh(req)}HFK");
                      if (_asp(transitHouse, tpAb, hfmSignHouse))
                        tags.add("${_hh(req)}HFM");
                      if (_asp(transitHouse, tpAb, lfmLordH))
                        tags.add("${_hh(req)}LFM");
                      if (knrPoints[req] != null && knrPoints[req]! >= 3)
                        tags.add("KNR-0${knrPoints[req]}");
                      double d9Deg = natalLordD9[req] ?? 0;
                      double tVe = tLonMap['Ve'] ?? 0;
                      double tMa = tLonMap['Ma'] ?? 0;
                      double tJu = tLonMap['Ju'] ?? 0;
                      double tSa = tLonMap['Sa'] ?? 0;
                      double tRa = tLonMap['Ra'] ?? 0;
                      double tKe = tLonMap['Ke'] ?? 0;
                      if (req == 1 && _isTrine(d9Deg, tJu)) tags.add("D901");
                      if (req == 2 && _isTrine(d9Deg, tJu)) tags.add("D902");
                      if (req == 3 && _isTrine(d9Deg, tJu)) tags.add("D903");
                      if (req == 4) {
                        if (_isTrine(d9Deg, tSa)) tags.add("D904FB");
                        if (_isTrine(d9Deg, tVe) ||
                            _isTrine(d9Deg, tMa) ||
                            _isTrine(d9Deg, tJu)) tags.add("D904VPM");
                      }
                      if (req == 5 && _isTrine(d9Deg, tJu)) tags.add("D905");
                      if (req == 6) {
                        if (_isTrine(d9Deg, tMa) ||
                            _isTrine(d9Deg, tSa) ||
                            _isTrine(d9Deg, tRa) ||
                            _isTrine(d9Deg, tKe)) tags.add("D906");
                      }
                      if (req == 7 && _isTrine(d9Deg, tJu)) tags.add("D907");
                      if (req == 8 && _isTrine(d9Deg, tSa)) tags.add("D908");
                      if (req == 9 && _isTrine(d9Deg, tJu)) tags.add("D909");
                      if (req == 10 && _isTrine(d9Deg, tJu)) tags.add("D910");
                      if (req == 11) {
                        if (_isTrine(d9Deg, tJu)) tags.add("D911");
                        if (_isTrine(d9Deg, tSa)) tags.add("D911MB");
                      }
                      if (req == 12) {
                        if (_isTrine(d9Deg, tRa)) tags.add("D912GB");
                        if (_isTrine(d9Deg, tJu)) tags.add("D912FT");
                      }
                      if (mdOwn.contains(req))
                        tags.add("MD${mdad.md}${_hh(req)}");
                      if (adOwn.contains(req))
                        tags.add("AD${mdad.ad}${_hh(req)}");
                      if ((own[tpAb] ?? []).contains(req))
                        tags.add("${_hh(req)}O");
                      for (var entry in progLon.entries) {
                        String spP = entry.key;
                        if (['Ur', 'Ne', 'Pl'].contains(spP)) continue;
                        double spLon = entry.value;
                        for (var nEntry in natalLon.entries) {
                          String nP = nEntry.key;
                          if (['Ur', 'Ne', 'Pl'].contains(nP)) continue;
                          double diff = _norm360(spLon - nEntry.value);
                          String? asp = _westernAspectExact(diff);
                          if (asp != null) {
                            if (own[nP]?.contains(req) == true ||
                                natalH[nP] == req)
                              tags.add("SP-$spP-$nP($asp)");
                          }
                        }
                      }
                      for (var entry in saLon.entries) {
                        String saP = entry.key;
                        if (['Ur', 'Ne', 'Pl'].contains(saP)) continue;
                        double sLon = entry.value;
                        for (var nEntry in natalLon.entries) {
                          String nP = nEntry.key;
                          if (['Ur', 'Ne', 'Pl'].contains(nP) || saP == nP)
                            continue;
                          double diff = _norm360(sLon - nEntry.value);
                          String? asp = _westernAspectExact(diff);
                          if (asp != null) {
                            if (own[nP]?.contains(req) == true ||
                                natalH[nP] == req)
                              tags.add("SAr-$saP-$nP($asp)");
                          }
                        }
                      }
                      for (var entry in pdLon.entries) {
                        String pdP = entry.key;
                        if (['Ur', 'Ne', 'Pl'].contains(pdP)) continue;
                        double pLon = entry.value;
                        for (var nEntry in natalLon.entries) {
                          String nP = nEntry.key;
                          if (['Ur', 'Ne', 'Pl'].contains(nP) || pdP == nP)
                            continue;
                          double diff = _norm360(pLon - nEntry.value);
                          String? asp = _westernAspectExact(diff);
                          if (asp != null) {
                            if (own[nP]?.contains(req) == true ||
                                natalH[nP] == req)
                              tags.add("PD-$pdP-$nP($asp)");
                          }
                        }
                      }
                      if (pH == req) tags.add("APr-${_hh(req)}H");
                      if (req == pH) tags.add("APr-L-${lordOfPH}${_hh(req)}L");
                      if (tags.isNotEmpty)
                        houseTags[req] = tags.toSet().toList();
                    }

                    // NEW AP LOGIC - FORGET TRANSIT, ONLY NATAL PLANET ASSOCIATION!
                    if (npAb.isNotEmpty) {
                      List<String> assocPlanets =
                          _getNatalAssociated(npAb, natalH);
                      List<int> ownedHouses = own[npAb] ?? [];
                      for (int oh in ownedHouses) {
                        for (String ap in assocPlanets) {
                          houseTags
                              .putIfAbsent(oh, () => [])
                              .add("AP${_hh(oh)}$ap");
                        }
                      }
                    }

                    rows.add({
                      'date': dateStr,
                      'tn': tnVal,
                      'tsns': tsnsVal,
                      'tags': houseTags,
                      'time': ev.time
                    });
                  }
                  rows.sort((a, b) =>
                      (a['time'] as DateTime).compareTo(b['time'] as DateTime));
                } catch (e) {
                  rows.add({
                    'date': 'Error $e',
                    'tn': '',
                    'tsns': '',
                    'tags': <int, List<String>>{},
                    'time': DateTime.now()
                  });
                }
                return Card(
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const GlobalDateRangeWidgetT1(),
                              const SizedBox(height: 6),
                              Row(children: [
                                Text('${rows.length} Events',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Colors.deepOrange)),
                                const Spacer(),
                                ElevatedButton.icon(
                                    icon: const Icon(Icons.download, size: 14),
                                    label: const Text('Export CSV',
                                        style: TextStyle(fontSize: 10)),
                                    onPressed: () => _exportToExcel(rows))
                              ]),
                              const SizedBox(height: 6),
                              SizedBox(
                                  height: 600,
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: DataTable(
                                            columnSpacing: 12,
                                            headingRowColor:
                                                WidgetStateProperty.all(
                                                    Colors.orange[100]),
                                            columns: const [
                                              DataColumn(
                                                  label: Text('Date',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('T-N',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('TS-NS',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H1',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H2',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H3',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H4',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H5',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H6',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H7',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H8',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H9',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H10',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H11',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                              DataColumn(
                                                  label: Text('H12',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11))),
                                            ],
                                            rows: rows.map((r) {
                                              Map<int, List<String>> tags =
                                                  r['tags']
                                                      as Map<int, List<String>>;
                                              List<DataCell> cells = [];
                                              cells.add(DataCell(Text(r['date'],
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold))));
                                              cells.add(DataCell(Text(r['tn'],
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold))));
                                              cells.add(DataCell(Text(r['tsns'],
                                                  style: const TextStyle(
                                                      fontSize: 10))));
                                              for (int h = 1; h <= 12; h++) {
                                                List<String> list =
                                                    tags[h] ?? [];
                                                String joined = list.join('\n');
                                                Color col;
                                                if (list.isEmpty) {
                                                  col = Colors.grey;
                                                } else if (list.any((e) =>
                                                    e.startsWith('KNR'))) {
                                                  col = Colors.red;
                                                } else if (h % 2 == 1) {
                                                  col = Colors.blue;
                                                } else {
                                                  col = Colors.black;
                                                }
                                                cells.add(DataCell(Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            minWidth: 75),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: Text(joined,
                                                        style: TextStyle(
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: col)))));
                                              }
                                              return DataRow(cells: cells);
                                            }).toList(),
                                          ))))
                            ])));
              });
        });
  }
}

class D9TechniqueModule extends AstroModule {
  const D9TechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'd9',
      title: 'T3 D9 TOE',
      icon: Icons.auto_awesome,
      category: 'Internal',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class SJMHModule extends AstroModule {
  const SJMHModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'sjmh',
      title: 'T2 KN Rao',
      icon: Icons.auto_awesome,
      category: 'Internal',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class AIOModule extends AstroModule {
  const AIOModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'aio',
      title: 'T5 AIO 8',
      icon: Icons.auto_awesome,
      category: 'Internal',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(
      child: Padding(padding: EdgeInsets.all(20), child: Text('T5')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class BNNModule extends AstroModule {
  const BNNModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'bnn',
      title: 'T2 BNN RG Rao',
      icon: Icons.auto_awesome,
      category: 'Techniques',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext context, ModuleContext ctx) =>
      _BNNCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('BNN')];
}

class _BNNCard extends StatefulWidget {
  final ModuleContext ctx;
  const _BNNCard({required this.ctx});
  @override
  State<_BNNCard> createState() => _BNNCardState();
}

class _BNNCardState extends State<_BNNCard> {
  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  DateTime _getDob() {
    try {
      final k = widget.ctx.kundli;
      DateTime utc = k.birthUtc;
      DateTime local = utc.add(Duration(minutes: k.utcOffsetMinutes));
      return local;
    } catch (e) {
      rethrow;
    }
  }

  String _getName() {
    try {
      return widget.ctx.kundli.name;
    } catch (e) {
      return "Chart";
    }
  }

  Map<String, int> _getRashi() {
    try {
      var snap = widget.ctx.snapshot;
      Map<String, int> m = {};
      snap.positions.forEach((planet, pos) {
        String ab = _planetToAbbr(planet);
        int sign = (pos.longitude ~/ 30) + 1;
        m[ab] = sign;
      });
      if (m.isNotEmpty && m.length >= 5) return m;
    } catch (e) {}
    return {};
  }

    @override
  Widget build(BuildContext context) {
    Map<String, int> natal = _getRashi();
    DateTime dob;
    try {
      dob = _getDob();
    } catch (e) {
      return Card(child: Padding(padding: EdgeInsets.all(12), child: Text('No DOB - check kundli: $e')));
    }
    if (natal.isEmpty) {
      return Card(child: Padding(padding: EdgeInsets.all(12), child: Text('No natal positions - check kundli')));
    }
    String name = _getName();
    List<String> rashiName = [
      '',
      'Ar',
      'Ta',
      'Ge',
      'Cn',
      'Le',
      'Vi',
      'Li',
      'Sc',
      'Sg',
      'Cp',
      'Aq',
      'Pi'
    ];
    const asp = [0, 1, 4, 6, 8];
    return ValueListenableBuilder<DateTime>(
        valueListenable: GlobalRange.from,
        builder: (context, fromVal, _) {
          return ValueListenableBuilder<DateTime>(
              valueListenable: GlobalRange.to,
              builder: (context, toVal, __) {
                List<Map<String, dynamic>> rows = [];
                final defs = [
                  {'p': 'Ju', 'micro': 1.0, 'retro': false},
                  {'p': 'Sa', 'micro': 2.5, 'retro': false},
                  {'p': 'Ra', 'micro': 1.5, 'retro': true},
                  {'p': 'Ke', 'micro': 1.5, 'retro': true}
                ];
                for (var def in defs) {
                  String pp = def['p'] as String;
                  double micro = def['micro'] as double;
                  bool retro = def['retro'] as bool;
                  int natalPP = natal[pp] ?? 0;
                  if (natalPP == 0) continue;
                  for (int idx = 0; idx < 80; idx++) {
                    double sAge = idx * micro;
                    double eAge = sAge + micro;
                    int cyc = idx ~/ 12;
                    int off = idx % 12;
                    int prog;
                    if (retro) {
                      prog = (natalPP - 1 - cyc - off) % 12 + 1;
                      if (prog <= 0) prog += 12;
                    } else {
                      prog = (natalPP - 1 + cyc + off) % 12 + 1;
                    }
                    DateTime from = DateTime(dob.year, dob.month, dob.day)
                        .add(Duration(days: (sAge * 365.25).round()));
                    DateTime to = DateTime(dob.year, dob.month, dob.day)
                        .add(Duration(days: (eAge * 365.25).round()))
                        .subtract(const Duration(days: 1));
                    if (to.isBefore(fromVal)) continue;
                    if (from.isAfter(toVal)) continue;
                    natal.forEach((np, npR) {
                      if (np == pp) return;
                      int dist = (npR - prog + 12) % 12;
                      if (asp.contains(dist))
                        rows.add({
                          'from': from,
                          'to': to,
                          'pp': pp,
                          'np': np,
                          'ps': rashiName[prog],
                          'ns': rashiName[npR],
                          'age':
                              "${sAge.toStringAsFixed(1)}-${eAge.toStringAsFixed(1)}"
                        });
                    });
                  }
                }
                rows.sort((a, b) =>
                    (a['from'] as DateTime).compareTo(b['from'] as DateTime));
                return Card(
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '$name - DOB ${_fmt(dob)} - ${rows.length} Events',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                      columns: const [
                                        DataColumn(
                                            label: Text('From To',
                                                style:
                                                    TextStyle(fontSize: 12))),
                                        DataColumn(
                                            label: Text('To',
                                                style:
                                                    TextStyle(fontSize: 12))),
                                        DataColumn(label: Text('PP-NP')),
                                        DataColumn(label: Text('PS-NS')),
                                        DataColumn(label: Text('Age'))
                                      ],
                                      rows: rows.map((r) {
                                        DateTime f = r['from'];
                                        DateTime t = r['to'];
                                        String fs =
                                            "${f.day.toString().padLeft(2, '0')}-${f.month.toString().padLeft(2, '0')}-${f.year} To ${t.day.toString().padLeft(2, '0')}-${t.month.toString().padLeft(2, '0')}-${t.year}";
                                        return DataRow(cells: [
                                          DataCell(Text(fs,
                                              style: const TextStyle(
                                                  fontSize: 12))),
                                          DataCell(Text(_fmt(t),
                                              style: const TextStyle(
                                                  fontSize: 12))),
                                          DataCell(
                                              Text('${r['pp']}-${r['np']}')),
                                          DataCell(
                                              Text('${r['ps']}-${r['ns']}')),
                                          DataCell(Text('${r['age']}'))
                                        ]);
                                      }).toList()))
                            ])));
              });
        });
  }
}

class SPModule extends AstroModule {
  const SPModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'sp',
      title: 'T7 Sec Progression',
      icon: Icons.auto_awesome,
      category: 'Internal',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class SATechniqueModule extends AstroModule {
  const SATechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'sa_tech',
      title: 'T8 Solar Arc',
      icon: Icons.auto_awesome,
      category: 'Internal',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class PDTechniqueModule extends AstroModule {
  const PDTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'pd_tech',
      title: 'T9 Pri Direction',
      icon: Icons.auto_awesome,
      category: 'Internal',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class APTechniqueModule extends AstroModule {
  const APTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'ap_tech',
      title: 'T10 Annual Profection',
      icon: Icons.auto_awesome,
      category: 'Internal',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class BadTransitsModule extends AstroModule {
  const BadTransitsModule();
  @override
  ModuleMeta get meta => const ModuleMeta(
      id: 'bad',
      title: 'T11 Bad Transits - NEGATIVE',
      icon: Icons.warning,
      category: 'Internal',
      defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}
