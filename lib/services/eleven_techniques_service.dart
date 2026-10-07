import 'swiss_service.dart';

class ElevenTechniquesService {
  static const List<String> planets = ["SU","MO","MA","ME","JU","VE","SA","RA","KE"];

  // TN = MASTER - Transit Nadi aspects
  String calculateTN(DateTime transitDate, Map natal) {
    final tPos = SwissService.getTransitPos(transitDate); // Map planet->deg
    final nPos = natal; // natal deg map

    List<String> grid = [];
    for (var tPlanet in planets) {
      double tp = (tPos[tPlanet]?? 0).toDouble();
      int tRashi = (tp ~/ 30);

      for (var nPlanet in planets) {
        double np = (nPos[nPlanet]?? nPos['${nPlanet}_deg']?? 0).toDouble();
        int nRashi = (np ~/ 30);
        int signDiff = (nRashi - tRashi) % 12;
        if (signDiff < 0) signDiff += 12;

        String ang = "";
        if (signDiff==0) ang="0";
        else if (signDiff==6) ang="180";
        else if (signDiff==2 && tPlanet=="SA") ang="60";
        else if (signDiff==10 && tPlanet=="SA") ang="300"; // Fixed 270->300
        else if (signDiff==3 && tPlanet=="MA") ang="90";
        else if (signDiff==9 && tPlanet=="MA") ang="270";
        else if (signDiff==4 && ["JU","RA","KE"].contains(tPlanet)) ang="120";
        else if (signDiff==8 && ["JU","RA","KE"].contains(tPlanet)) ang="240";

        if (ang!="") grid.add("$tPlanet-$nPlanet $ang");
      }
    }
    return grid.join(", ");
  }

  // 1. MD - Mahadasha Lord connection
  int calcMD(String tn, Map config) {
    int score = 0;
    String mdLord = (config['mdLord']?? "").toString().toUpperCase();
    if (mdLord.isEmpty) return 0;

    if (tn.contains(mdLord)) score++;
    if ((config['D2']?? "").toString().contains(mdLord)) score++;
    if ((config['E2']?? "").toString().contains(mdLord)) score++;
    return score;
  }

  // 3. D9 - Navamsa Trine 1,5,9 = 0,4,8 diff
  String calcD9(DateTime date, Map natal) {
    List<String> out = [];
    for (var planet in planets) {
      double d9Deg = SwissService.getD9Pos(planet, date);
      double natalD9Ref = (natal['D9_LAGNA']?? natal['G4']?? 0).toDouble();
      int diff = (((d9Deg ~/ 30) - (natalD9Ref ~/ 30)) % 12);
      if (diff < 0) diff += 12;
      if ([0,4,8].contains(diff)) out.add("D9-${planet}Blessed");
    }
    return out.join(", ");
  }

  // 6. BNN - FIXED 100% - Jupiter Progression
  String calcBNN(DateTime curr, DateTime dob, Map natal) {
    int age = curr.year - dob.year;
    if (curr.month < dob.month || (curr.month == dob.month && curr.day < dob.day)) {
      age--;
    }
    age = age + 1; // BNN starts at 1

    int natalJuDeg = (natal['juDeg']?? natal['JU']?? natal['JU_deg']?? 0).toInt();
    int natalJuRashi = (natalJuDeg ~/ 30); // 0-11
    int progression = (age - 1) % 12;
    int progRashi = (natalJuRashi + progression) % 12 + 1; // 1-12

    // BNN Hit = 1,5,9,7 from progression
    return '$age JU-$progRashi';
  }
}