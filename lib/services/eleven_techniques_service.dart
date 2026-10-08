import 'swiss_service.dart';

class ElevenTechniquesService {
  static const List<String> planets = ['SU','MO','MA','ME','JU','VE','SA','RA','KE'];

  static const Map<String, double> dashaScores = {
    'MD': 1.0,
    'AD': 2.0,
    'PD': 0.75,
    'SD': 0.50,
    'PrD': 0.25,
  };

  List<String> getAssociatedPlanets({
    required int requiredHouse,
    required String requiredHouseLord,
    required Map<String, int> planetHouses,
    required Map<String, double> planetDegs,
  }) {
    List<String> associated = [];
    int lordHouse = planetHouses[requiredHouseLord]?? -1;

    planetHouses.forEach((planet, house) {
      if (house == requiredHouse) {
        associated.add(planet);
      }
      if (house == lordHouse && planet!= requiredHouseLord) {
        double degDiff = (planetDegs[planet]! - planetDegs[requiredHouseLord]!).abs();
        if (degDiff < 1.0 || (360 - degDiff) < 1.0) {
          associated.add(planet);
        }
      }
    });

    final Map<String, List<int>> specialAspects = {
      'MA': [3,6,7],
      'SA': [2,6,9],
      'JU': [4,6,8],
      'RA': [4,6,8],
      'KE': [4,6,8],
    };

    planetHouses.forEach((aspectingPlanet, aspectingHouse) {
      List<int> aspects = specialAspects[aspectingPlanet]?? [6];
      for (int diff in aspects) {
        int aspectedHouse = ((aspectingHouse - 1 + diff) % 12) + 1;
        if (aspectedHouse == requiredHouse || aspectedHouse == lordHouse) {
          associated.add(aspectingPlanet);
        }
      }
    });

    return associated.toSet().toList();
  }

  Map<int, List<String>> calcDashaTechnique(DateTime date, Map config) {
    Map<int, List<String>> houseHits = {};
    Map<int, double> houseScores = {};

    String mdLord = (config['mdLord']?? '').toString().toUpperCase();
    String adLord = (config['adLord']?? '').toString().toUpperCase();
    String pdLord = (config['pdLord']?? '').toString().toUpperCase();
    String sdLord = (config['sdLord']?? '').toString().toUpperCase();
    String prdLord = (config['prdLord']?? '').toString().toUpperCase();

    void addHit(String type, String lord, int house) {
      if (lord.isEmpty) {
        return;
      }
      houseHits.putIfAbsent(house, () => []);
      houseHits[house]!.add('$type-${house.toString().padLeft(2,'0')}');
      houseScores[house] = (houseScores[house]?? 0) + (dashaScores[type]?? 0);
    }

    if (config['mdHouse']!= null) {
      addHit('MD', mdLord, config['mdHouse']);
    }
    if (config['adHouse']!= null) {
      addHit('AD', adLord, config['adHouse']);
    }
    if (config['pdHouse']!= null) {
      addHit('PD', pdLord, config['pdHouse']);
    }
    if (config['sdHouse']!= null) {
      addHit('SD', sdLord, config['sdHouse']);
    }
    if (config['prdHouse']!= null) {
      addHit('PrD', prdLord, config['prdHouse']);
    }

    return houseHits;
  }

  double calcDashaScore(List<String> hits) {
    double total = 0;
    for (var hit in hits) {
      if (hit.startsWith('MD')) {
        total += dashaScores['MD']!;
      } else if (hit.startsWith('AD')) {
        total += dashaScores['AD']!;
      } else if (hit.startsWith('PD')) {
        total += dashaScores['PD']!;
      } else if (hit.startsWith('SD')) {
        total += dashaScores['SD']!;
      } else if (hit.startsWith('PrD')) {
        total += dashaScores['PrD']!;
      }
    }
    return total;
  }

  String calculateTN(DateTime transitDate, Map natal) {
    final tPos = SwissService.getTransitPos(transitDate);
    final nPos = natal;

    List<String> grid = [];
    for (var tPlanet in planets) {
      double tp = (tPos[tPlanet]?? 0).toDouble();
      int tRashi = (tp ~/ 30);

      for (var nPlanet in planets) {
        double np = (nPos[nPlanet]?? nPos['${nPlanet}_deg']?? 0).toDouble();
        int nRashi = (np ~/ 30);
        int signDiff = (nRashi - tRashi) % 12;
        if (signDiff < 0) {
          signDiff += 12;
        }

        String ang = '';
        if (signDiff == 0) {
          ang = '0';
        } else if (signDiff == 6) {
          ang = '180';
        } else if (signDiff == 2 && tPlanet == 'SA') {
          ang = '60';
        } else if (signDiff == 10 && tPlanet == 'SA') {
          ang = '300';
        } else if (signDiff == 3 && tPlanet == 'MA') {
          ang = '90';
        } else if (signDiff == 9 && tPlanet == 'MA') {
          ang = '270';
        } else if (signDiff == 4 && ['JU','RA','KE'].contains(tPlanet)) {
          ang = '120';
        } else if (signDiff == 8 && ['JU','RA','KE'].contains(tPlanet)) {
          ang = '240';
        }

        if (ang!= '') {
          grid.add('$tPlanet-$nPlanet $ang');
        }
      }
    }
    return grid.join(', ');
  }

  List<String> calcTNWithoutOrbPHLK(DateTime date, Map natal, Map dashaConfig) {
    String tn = calculateTN(date, natal);
    return tn.split(', ');
  }

  String calcD9(DateTime date, Map natal) {
    List<String> out = [];
    for (var planet in planets) {
      double d9Deg = SwissService.getD9Pos(planet, date);
      double natalD9Ref = (natal['D9_LAGNA']?? natal['G4']?? 0).toDouble();
      int diff = (((d9Deg ~/ 30) - (natalD9Ref ~/ 30)) % 12);
      if (diff < 0) {
        diff += 12;
      }
      if ([0,4,8].contains(diff)) {
        out.add('D9-${planet}Blessed');
      }
    }
    return out.join(', ');
  }

  String calcBNN(DateTime curr, DateTime dob, Map natal) {
    int age = curr.year - dob.year;
    if (curr.month < dob.month || (curr.month == dob.month && curr.day < dob.day)) {
      age--;
    }
    age = age + 1;
    int natalJuDeg = (natal['juDeg']?? natal['JU']?? 0).toInt();
    int natalJuRashi = (natalJuDeg ~/ 30);
    int progression = (age - 1) % 12;
    int progRashi = (natalJuRashi + progression) % 12 + 1;
    return '$age JU-$progRashi';
  }
}