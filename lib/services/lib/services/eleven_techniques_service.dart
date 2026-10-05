class ElevenTechniquesService {
  // TN = MASTER - All other 10 search in this!
  String calculateTN(DateTime transitDate, Map natal) {
    // B4:M4 = transit pos, H!P1:BK1 = natal pos
    final tPos = SwissService.getTransitPos(transitDate); // 12 planets
    final nPos = SwissService.getNatalPos(); // 48 points
    final tLords = SwissService.getHouseLords(tPos);
    final nLords = SwissService.getHouseLords(nPos);

    List<String> grid = [];
    for (int r=0; r<48; r++) {
      for (int c=0; c<14; c++) {
        int cIdx = c<12?c:(c==12?mdCode:adCode);
        double tp = tPos[cIdx];
        double np = nPos[r];
        int signDiff = ((np~/30) - (tp~/30)) % 12;

        String ang = '';
        if (signDiff==0) ang='0';
        else if (signDiff==6) ang='180';
        else if (signDiff==2 && tPos==SA) ang='60';
        else if (signDiff==9 && tPos==SA) ang='270';
        else if (signDiff==3 && tPos==MA) ang='90';
        else if (signDiff==7 && tPos==MA) ang='210';
        else if (signDiff==4 && ['JU','RA','KE'].contains(tName)) ang='120';
        else if (signDiff==8 && ['JU','RA','KE'].contains(tName)) ang='240';

        if (ang!='') grid.add('$pLabel-$nName $ang $lordPairs');
      }
    }
    return grid.join(', '); // This is O4!
  }

  // 1. MD
  int calcMD(String tn, Map config) {
    // =SUMPRODUCT(--ISNUMBER(SEARCH("MD"&A2:M2,O4))) + lord checks
    int score = 0;
    for (var cfg in config['A2:M2']) {
      if (tn.contains('MD$cfg')) score++;
    }
    if (config['D2']==mdLord) score++;
    if (config['E2']==mdLord) score++;
    if (config['N2'].contains(mdLord)) score++;
    return score;
  }

  // 3. D9 - {0,4,8} trine
  String calcD9(DateTime date, Map natal) {
    double az = SwissService.getD9Pos('SU', date);
    // ROUNDDOWN(MOD(AZ1-G4,360)/30,0) in {0,4,8}
    List<String> out = [];
    for (var planet in planets) {
      int diff = ((az - transitG4)/30).floor() % 12;
      if ([0,4,8].contains(diff)) out.add('D9-${planet}Blessed');
    }
    return out.join(', ');
  }

  // 6. BNN
  String calcBNN(DateTime curr, DateTime dob) {
    int age = curr.difference(dob).inDays ~/ 365 + 1;
    int cycle = (age-1) ~/ 12;
    int house = ((cycle) + (age-1)%12) % 12 + 1;
    int natalJuRashi = (natalJuDeg~/30)+1;
    int progRashi = (natalJuRashi-1+house-1)%12+1;
    // dist 0,4,6,8 = hit
    return '$age JU-$matched';
  }
}
