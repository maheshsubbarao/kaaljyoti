import 'swiss_service.dart';

class ElevenTechniquesService {
  static const List<String> planets = ["SU","MO","MA","ME","JU","VE","SA","RA","KE","MD","AD"];

  // TN = MASTER - All other 10 search in this!
  String calculateTN(DateTime transitDate, Map natal) {
    final tPos = SwissService.getTransitPos(transitDate);
    final nPos = SwissService.getNatalPos();

    List<String> grid = [];
    for (int r=0; r<48; r++) {
      for (int c=0; c<12; c++) {
        double tp = tPos[c] is double? tPos[c] : 0.0;
        double np = nPos[r] is double? nPos[r] : 0.0;
        int signDiff = ((np~/30) - (tp~/30)) % 12;
        if (signDiff < 0) signDiff += 12;

        String ang = "";
        String tName = planets[c < planets.length? c : 0];

        if (signDiff==0) ang="0";
        else if (signDiff==6) ang="180";
        else if (signDiff==2 && tName=="SA") ang="60";
        else if (signDiff==9 && tName=="SA") ang="270";
        else if (signDiff==3 && tName=="MA") ang="90";
        else if (signDiff==7 && tName=="MA") ang="210";
        else if (signDiff==4 && ["JU","RA","KE"].contains(tName)) ang="120";
        else if (signDiff==8 && ["JU","RA","KE"].contains(tName)) ang="240";

        if (ang!="") {
          String pLabel = tName;
          String nName = "P$r";
          grid.add("$pLabel-$nName $ang");
        }
      }
    }
    return grid.join(", ");
  }

  // 1. MD
  int calcMD(String tn, Map config) {
    int score = 0;
    var mdLord = config['mdLord']?? "";
    List cfgList = config['A2:M2']?? [];
    for (var cfg in cfgList) {
      if (tn.contains("MD$cfg")) score++;
    }
    if (config['D2']==mdLord) score++;
    if (config['E2']==mdLord) score++;
    if ((config['N2']?? "").toString().contains(mdLord)) score++;
    return score;
  }

  // 3. D9 - {0,4,8} trine
  String calcD9(DateTime date, Map natal) {
    double az = SwissService.getD9Pos("SU", date);
    double transitG4 = (natal['G4']?? 0).toDouble();
    List<String> out = [];
    for (var planet in planets) {
      int diff = ((az - transitG4)/30).floor() % 12;
      if ([0,4,8].contains(diff)) out.add("D9-${planet}Blessed");
    }
    return out.join(", ");
  }

  // 6. BNN - FIXED! This was the main bug
  String calcBNN(DateTime curr, DateTime dob, Map natal) {
    int age = curr.difference(dob).inDays ~/ 365 + 1;
    int cycle = (age-1) ~/ 12;
    int house = ((cycle) + (age-1)%12) % 12 + 1;
    int natalJuDeg = (natal['juDeg']?? natal['JU']?? 0).toInt();
    int natalJuRashi = (natalJuDeg~/30)+1;
    int progRashi = (natalJuRashi-1+house-1)%12+1;
    // dist 0,4,6,8 = hit
    return '$age JU-$progRashi';
  }
}