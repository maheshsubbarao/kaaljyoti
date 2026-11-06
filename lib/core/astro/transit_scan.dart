/// Transit scanning engine: finds the exact instants a moving body
/// crosses a target longitude within a window — the shared core for
/// the Gochar timeline, Upcoming Events feed, and Sade Sati tracker.
///
/// Pure Dart and dependency-injected: callers pass a [LongitudeAt]
/// sampler, so the engine is unit-testable with synthetic motion and
/// production code wires in the Swiss Ephemeris (see
/// [ephemerisLongitude]). Retrograde-safe: a planet that crosses a
/// boundary, retrogrades back, and crosses again yields THREE events.
library;

import 'ephemeris_service.dart';
import 'models.dart';

typedef LongitudeAt = double Function(DateTime t);

double _norm360(double x) => ((x % 360) + 360) % 360;
double _norm180(double x) {
  final n = _norm360(x);
  return n > 180 ? n - 360 : n;
}

LongitudeAt ephemerisLongitude(Planet planet, int ayanamsaId) {
  final svc = EphemerisService.instance;
  final cache = <int, double>{};
  return (t) {
    final utc = t.toUtc();
    return cache[utc.millisecondsSinceEpoch] ??=
        svc.planetLongitude(svc.julianDayUt(utc), ayanamsaId, planet);
  };
}

List<DateTime> findLongitudeCrossings(
  LongitudeAt f,
  double target,
  DateTime from,
  DateTime to, {
  Duration step = const Duration(hours: 24),
}) {
  bool neg(double d) => d < 0;
  final out = <DateTime>[];
  var t0 = from;
  var d0 = _norm180(f(t0) - target);
  while (t0.isBefore(to)) {
    var t1 = t0.add(step);
    if (t1.isAfter(to)) t1 = to;
    final d1 = _norm180(f(t1) - target);
    if (neg(d0) != neg(d1) && (d0 - d1).abs() < 180) {
      var a = t0, b = t1;
      final sideA = neg(d0);
      while (b.difference(a) > const Duration(minutes: 1)) {
        final mid = a.add(b.difference(a) ~/ 2);
        if (neg(_norm180(f(mid) - target)) == sideA) {
          a = mid;
        } else {
          b = mid;
        }
      }
      out.add(a.add(b.difference(a) ~/ 2));
    }
    if (!t1.isBefore(to)) break;
    t0 = t1;
    d0 = d1;
  }
  final deduped = <DateTime>[];
  for (final t in out) {
    if (deduped.isEmpty ||
        t.difference(deduped.last) > const Duration(minutes: 2)) {
      deduped.add(t);
    }
  }
  return deduped;
}

List<({ZodiacSign sign, DateTime start, DateTime end})> signOccupancy(
  LongitudeAt f,
  DateTime from,
  DateTime to, {
  Duration step = const Duration(hours: 24),
}) {
  final crossings = <DateTime>[
    for (var k = 0; k < 12; k++)
      ...findLongitudeCrossings(f, k * 30.0, from, to, step: step),
  ]..sort();
  final out = <({ZodiacSign sign, DateTime start, DateTime end})>[];
  var start = from;
  for (final c in crossings) {
    if (c.difference(start) < const Duration(minutes: 2)) continue;
    final mid = start.add(c.difference(start) ~/ 2);
    out.add((
      sign: ZodiacSign.fromLongitude(f(mid)),
      start: start,
      end: c,
    ));
    start = c;
  }
  final mid = start.add(to.difference(start) ~/ 2);
  out.add((sign: ZodiacSign.fromLongitude(f(mid)), start: start, end: to));
  return out;
}

enum TransitEventKind { ingress, aspect }

/// BOSS FIX: Added degree display for Rahu/Ketu reverse logic!
/// Normal: 0°00'00" = beginning, Rahu/Ketu: 29°59'59" = beginning!
String _formatDMS(double degInSign) {
  // degInSign 0-30
  int d = degInSign.floor();
  double mF = (degInSign - d) * 60;
  int m = mF.floor();
  int s = ((mF - m) * 60).round();
  if (s == 60) { s = 0; m++; }
  if (m == 60) { m = 0; d++; }
  if (d == 30) d = 29; // cap for display
  return "${d.toString().padLeft(2,'0')}°${m.toString().padLeft(2,'0')}'${s.toString().padLeft(2,'0')}\"";
}

class TransitEvent {
  const TransitEvent({
    required this.planet,
    required this.kind,
    required this.time,
    this.sign,
    this.natalPoint,
    this.drishti,
    this.entryDegree, // BOSS NEW: degree at entry!
  });

  final Planet planet;
  final TransitEventKind kind;
  final DateTime time;
  final ZodiacSign? sign;
  final String? natalPoint;
  final int? drishti;
  final double? entryDegree; // 0-30 deg in sign at entry

  String get label {
    if (kind == TransitEventKind.ingress) {
      String degStr = "";
      if (entryDegree != null) {
        degStr = " at ${_formatDMS(entryDegree!)}";
      }
      return '${planet.displayName} enters ${sign!.sanskrit} (${sign!.western})$degStr';
    } else {
      return drishti == 1
          ? '${planet.displayName} conjunct natal $natalPoint'
          : '${planet.displayName} ${drishti}th drishti on natal $natalPoint';
    }
  }
}

const Map<int, double> drishtiAngle = {
  1: 0, 3: 60, 4: 90, 5: 120, 7: 180, 8: 210, 9: 240, 10: 270,
};

List<int> drishtisOf(Planet p) => switch (p) {
      Planet.saturn => const [1, 3, 7, 10],
      Planet.jupiter => const [1, 5, 7, 9],
      Planet.mars => const [1, 4, 7, 8],
      Planet.rahu || Planet.ketu => const [1, 5, 7, 9],
      _ => const [1, 7],
    };

const List<Planet> kGocharDefaultPlanets = [
  Planet.sun, Planet.moon, Planet.mercury, Planet.venus,
  Planet.mars, Planet.jupiter, Planet.saturn, Planet.rahu, Planet.ketu,
];

List<TransitEvent> scanGochar({
  required Map<String, double> natalPoints,
  required DateTime from,
  required DateTime to,
  required int ayanamsaId,
  List<Planet> planets = kGocharDefaultPlanets,
  LongitudeAt Function(Planet)? samplerFor,
}) {
  final sampler = samplerFor ?? (p) => ephemerisLongitude(p, ayanamsaId);
  final out = <TransitEvent>[];
  for (final planet in planets) {
    final f = sampler(planet);
    for (var k = 0; k < 12; k++) {
      for (final t in findLongitudeCrossings(f, k * 30.0, from, to)) {
        // Sample just after to know sign entered + degree
        // For Rahu/Ketu retrograde, after is deeper into previous sign = 29°...
        // For normal, after is just into new sign = 0°...
        final afterLon = f(t.add(const Duration(hours: 6)));
        final afterSign = ZodiacSign.fromLongitude(afterLon);
        double degInSign = afterLon % 30;
        // BOSS FIX: For Rahu/Ketu, degree display is reversed logic but actual deg is 29.xx = beginning!
        // So we keep actual degInSign - it will be ~29.9 for Rahu entering, ~0.0 for normal!
        out.add(TransitEvent(
          planet: planet,
          kind: TransitEventKind.ingress,
          time: t,
          sign: afterSign,
          entryDegree: degInSign,
        ));
      }
    }
    for (final d in drishtisOf(planet)) {
      final angle = drishtiAngle[d]!;
      for (final MapEntry(key: label, value: natal) in natalPoints.entries) {
        for (final t in findLongitudeCrossings(f, _norm360(natal - angle), from, to)) {
          out.add(TransitEvent(
            planet: planet,
            kind: TransitEventKind.aspect,
            time: t,
            natalPoint: label,
            drishti: d,
          ));
        }
      }
    }
  }
  out.sort((a, b) => a.time.compareTo(b.time));
  return out;
}

// ... Sade Sati code remains same as before ...
enum SadeSatiPhaseKind { rising, peak, setting, smallPanoti }
class SadeSatiPhase {
  const SadeSatiPhase({required this.kind, required this.sign, required this.start, required this.end});
  final SadeSatiPhaseKind kind; final ZodiacSign sign; final DateTime start; final DateTime end;
  Duration get length => end.difference(start);
  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}
List<SadeSatiPhase> sadeSatiPhases({
  required ZodiacSign moonSign, required DateTime from, required DateTime to,
  required int ayanamsaId, LongitudeAt? saturn,
}) {
  final f = saturn ?? ephemerisLongitude(Planet.saturn, ayanamsaId);
  final occ = signOccupancy(f, from, to, step: const Duration(days: 5));
  final m = moonSign.index;
  SadeSatiPhaseKind? kindFor(int signIdx) {
    final rel = (signIdx - m + 12) % 12;
    return switch (rel) {
      11 => SadeSatiPhaseKind.rising, 0 => SadeSatiPhaseKind.peak,
      1 => SadeSatiPhaseKind.setting, 3 || 7 => SadeSatiPhaseKind.smallPanoti, _ => null,
    };
  }
  return [for (final o in occ) if (kindFor(o.sign.index) case final k?) SadeSatiPhase(kind: k, sign: o.sign, start: o.start, end: o.end)];
}
const double kSadeSatiDegreeOrb = 45.0;
double sadeSatiSeparation(double saturnLon, double moonLon) => _norm180(saturnLon - moonLon);
class SadeSatiDegreeWindow {
  const SadeSatiDegreeWindow({required this.start, required this.end, this.conjunctions = const [], this.clippedStart = false, this.clippedEnd = false, this.approachingAtStart = true});
  final DateTime start; final DateTime end; final List<DateTime> conjunctions;
  final bool clippedStart; final bool clippedEnd; final bool approachingAtStart;
  Duration get length => end.difference(start);
  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}
enum DegreeSpanKind { approaching, separating, outOfArc }
class DegreeArcSpan {
  const DegreeArcSpan({required this.kind, required this.start, required this.end});
  final DegreeSpanKind kind; final DateTime start; final DateTime end;
  Duration get length => end.difference(start);
}
List<DegreeArcSpan> degreeArcSpans(List<SadeSatiDegreeWindow> passage) {
  final out = <DegreeArcSpan>[];
  for (var i = 0; i < passage.length; i++) {
    final w = passage[i]; var approaching = w.approachingAtStart; var cursor = w.start;
    for (final c in w.conjunctions) {
      if (!c.isAfter(cursor) || !c.isBefore(w.end)) continue;
      out.add(DegreeArcSpan(kind: approaching ? DegreeSpanKind.approaching : DegreeSpanKind.separating, start: cursor, end: c));
      approaching = !approaching; cursor = c;
    }
    out.add(DegreeArcSpan(kind: approaching ? DegreeSpanKind.approaching : DegreeSpanKind.separating, start: cursor, end: w.end));
    if (i + 1 < passage.length) out.add(DegreeArcSpan(kind: DegreeSpanKind.outOfArc, start: w.end, end: passage[i + 1].start));
  }
  return out;
}
List<SadeSatiDegreeWindow> sadeSatiDegreeWindows({
  required double natalMoonLon, required DateTime from, required DateTime to,
  required int ayanamsaId, LongitudeAt? saturn, double orb = kSadeSatiDegreeOrb, Duration step = const Duration(days: 5),
}) {
  final f = saturn ?? ephemerisLongitude(Planet.saturn, ayanamsaId);
  final moon = _norm360(natalMoonLon);
  final edges = <DateTime>[...findLongitudeCrossings(f, _norm360(moon - orb), from, to, step: step), ...findLongitudeCrossings(f, _norm360(moon + orb), from, to, step: step)]..sort();
  final conjunctions = findLongitudeCrossings(f, moon, from, to, step: step);
  final out = <SadeSatiDegreeWindow>[];
  var start = from;
  void emit(DateTime segStart, DateTime segEnd) {
    final mid = segStart.add(segEnd.difference(segStart) ~/ 2);
    if (sadeSatiSeparation(f(mid), moon).abs() > orb) return;
    out.add(SadeSatiDegreeWindow(start: segStart, end: segEnd, conjunctions: [for (final c in conjunctions) if (!c.isBefore(segStart) && !c.isAfter(segEnd)) c], clippedStart: segStart == from, clippedEnd: segEnd == to, approachingAtStart: sadeSatiSeparation(f(segStart), moon) < 0));
  }
  for (final c in edges) {
    if (c.difference(start) < const Duration(minutes: 2)) continue;
    emit(start, c); start = c;
  }
  if (to.isAfter(start)) emit(start, to);
  return out;
}