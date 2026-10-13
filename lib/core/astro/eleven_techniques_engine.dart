// Paste this - Build #20 Engine - BNN FIXED with your Spiral Rule
class ElevenTechniquesEngine {
  static const rashiCodes = ['Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];

  // Your Parampara - Macro / Micro
  static const Map<String, Map<String, double>> bnnConfig = {
    'JU': {'macro': 12, 'micro': 1.0},
    'SA': {'macro': 30, 'micro': 2.5},
    'RA': {'macro': 18, 'micro': 1.5},
    'KE': {'macro': 18, 'micro': 1.5},
  };

  static List<AstroEvent> generateAstroEvents({
    required DateTime from, // This is your Custom Range From (Upcoming Event picker)
    required DateTime to, // This is your Custom Range To
    required int selectedHouse,
    required Map natalChart, // Must have dob + planets
    required Map dashaData,
  }) {
    List<AstroEvent> events = [];

    // --- GET DOB ---
    DateTime dob;
    try {
      dob = natalChart['dob']?? dashaData['dob']?? DateTime(1966,2,22,8,31,16);
      if (dob is String) dob = DateTime.parse(dob);
    } catch(e) {
      dob = DateTime(1966,2,22,8,31,16);
    }

    // --- GET NATAL SIGNS 0-11 ---
    Map<String,int> natalSigns = {};
    // natalChart can be {'JU': 45.0 degree} or {'JU': 1 sign}
    for (var p in ['SU','MO','MA','ME','JU','VE','SA','RA','KE']) {
      if (natalChart.containsKey(p)) {
        var val = natalChart[p];
        int sign;
        if (val is double) {
          sign = (val / 30).floor() % 12;
        } else if (val is int) {
          sign = val % 12;
          if (sign <0) sign+=12;
          // If val is 1-12 convert to 0-11
          if (sign > 11) sign = (sign-1) %12;
          // If your chart sends 1-12 as sign number, handle
          if (natalChart['isOneToTwelve'] == true) sign = (val-1) %12;
        } else {
          continue;
        }
        natalSigns[p] = sign;
      }
    }
    // Fallback example for testing - Remove after real chart connected
    if (natalSigns.isEmpty) {
      natalSigns = {'SU':10,'MO':6,'MA':11,'ME':11,'JU':1,'VE':9,'SA':1,'RA':1,'KE':7};
    }

    // --- BNN SPIRAL PROGRESSION ---
    for (var ppEntry in bnnConfig.entries) {
      String pp = ppEntry.key;
      double micro = ppEntry.value['micro']!;
      if (!natalSigns.containsKey(pp)) continue;

      int natalRashiPP = natalSigns[pp]!;
      double cumulative = 0;
      int cycle = 0;

      // Max generate till 'to' range + 1 year buffer
      double maxYears = to.difference(dob).inDays / 365.25 + 2;
      if (maxYears < 0) maxYears = 80;

      while (cumulative <= maxYears) {
        for (int j=0; j<12; j++) {
          if (cumulative > maxYears) break;

          // YOUR EXACT FORMULA
          // cycle = floor((age-1)/12), start = cycle
          // progRashi = (natalRashi + cycle + j) %12
          int progRashi = (natalRashiPP + cycle + j) % 12;

          DateTime progFrom = _addYears(dob, cumulative);
          DateTime progTo = _addYears(dob, cumulative + micro);

          // Check if this progression period overlaps with custom range [from, to]
          bool overlaps = progTo.isAfter(from) && progFrom.isBefore(to);

          if (overlaps) {
            // Check aspects 0,1,4,6,8 => 1st,2nd,5th,7th,9th house
            for (var npEntry in natalSigns.entries) {
              String np = npEntry.key;
              if (np == pp) continue; // Don't aspect self
              int natalR = npEntry.value;
              int dist = (natalR - progRashi + 12) % 12;
              bool hit = (dist == 0 || dist == 1 || dist == 4 || dist == 6 || dist == 8);

              if (hit) {
                // Optional: Filter by selectedHouse if needed
                // if selectedHouse!=0 and you want only events where progRashi+1 == selectedHouse, uncomment:
                // if (selectedHouse!= 0 && (progRashi+1)!= selectedHouse) continue;

                events.add(AstroEvent(
                  date: progFrom,
                  code: "$pp-$np", // Like JU-VE, SA-RA
                  technique: "BNN",
                  house: progRashi + 1,
                  // Extra info for your table
                  psNs: "${rashiCodes[progRashi]}-${rashiCodes[natalR]}",
                  y: cumulative, // 7.5, 30.0
                  toDate: progTo,
                ));
              }
            }
          }
          cumulative += micro;
        }
        cycle++;
      }
    }

    events.sort((a,b) => a.date.compareTo(b.date));
    return events;
  }

  static DateTime _addYears(DateTime dob, double years) {
    int whole = years.floor();
    double frac = years - whole;
    DateTime d = DateTime(dob.year + whole, dob.month, dob.day, dob.hour, dob.minute, dob.second);
    int extraDays = (frac * 365.25).round();
    return d.add(Duration(days: extraDays));
  }
}

class AstroEvent {
  DateTime date; // From
  DateTime toDate; // To
  String code; // PP-NP like JU-VE
  String technique;
  int house;
  String psNs; // PS-NS like Ta-Ta, Cp-Cp
  double y; // Age like 7.5, 30.0

  AstroEvent({
    required this.date,
    required this.code,
    required this.technique,
    required this.house,
    DateTime? toDate,
    String? psNs,
    double? y,
  }) : toDate = toDate?? date.add(Duration(days: 365)),
       psNs = psNs?? "",
       y = y?? 0;

  String get display => "${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year} $code";

  // For your table: From | To | Y | PP-NP | PS-NS
  String get tableRow => "${date.day}-${date.month}-${date.year} | ${toDate.day}-${toDate.month}-${toDate.year} | $y | $code | $psNs";
}