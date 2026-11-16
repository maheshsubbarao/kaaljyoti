import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import '../../pdf/pw.dart' as pw;
import 'package:printing/printing.dart';
import 'guna_milan.dart';
import 'models.dart';
import '../../data/models.dart' show Kundli;
import '../../modules/common.dart' show pdfTheme;
import '../../state/providers.dart';
import '../../ui/common.dart';

class AshtakootaBody extends ConsumerWidget {
  const AshtakootaBody({super.key, required this.brideId, required this.groomId, required this.allKundlis, required this.hideAyush, required this.onAyushChanged});
  final String brideId; final String groomId; final List<Kundli> allKundlis; final bool hideAyush; final ValueChanged<bool> onAyushChanged;
  Kundli _find(String id) => allKundlis.firstWhere((e) => e.id == id);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brideAsync = ref.watch(snapshotProvider(brideId));
    final groomAsync = ref.watch(snapshotProvider(groomId));
    return brideAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Girl $e')),
      data: (bSnap) => groomAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Boy $e')),
        data: (gSnap) {
          try {
            final calc = AshtakootaCalc.compute(bSnap, gSnap, _find(brideId), _find(groomId), hideAyush: hideAyush);
            return Column(children: [
              Padding(padding: const EdgeInsets.only(top: 8), child: Container(decoration: BoxDecoration(color: const Color(0xFF76FF03), borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(10), child: Center(child: Text('AshtaKoota ${calc.totalDouble == calc.total.toDouble() ? calc.total : calc.totalDouble.toStringAsFixed(1)}/36 = ${calc.percent}% - ${calc.verdict}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)))),
              const SizedBox(height: 8),
              Row(children: [
                Checkbox(value: !hideAyush, onChanged: (v) => onAyushChanged(!(v??false))), const Text('Show Ayush', style: TextStyle(fontSize: 12)),
                const Spacer(),
                OutlinedButton.icon(onPressed: () => AshtakootaExport.exportPdf(calc), icon: const Icon(Icons.picture_as_pdf, size: 16), label: const Text('PDF')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: () => AshtakootaExport.exportCsv(calc), icon: const Icon(Icons.table_chart, size: 16), label: const Text('CSV')),
              ]),
              const SizedBox(height: 8),
              ModuleCard(title: 'AshtaKoota ${calc.brideName} x ${calc.groomName}', child: Column(children: [Padding(padding: const EdgeInsets.all(8), child: Table(border: TableBorder.all(color: Colors.grey.shade300), children: [for (final hr in calc.headerRows) TableRow(children: [Padding(padding: const EdgeInsets.all(6), child: Text(hr.length > 2 ? hr[2] : '', style: const TextStyle(fontSize: 12))), Padding(padding: const EdgeInsets.all(6), child: Text(hr.length > 3 ? hr[3] : '', style: const TextStyle(fontSize: 12)))])])), SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: kIsWeb ? 1400 : 950, child: Table(columnWidths: kIsWeb ? const {0: FixedColumnWidth(60), 1: FixedColumnWidth(200), 2: FixedColumnWidth(260), 3: FixedColumnWidth(260), 4: FixedColumnWidth(180), 5: FixedColumnWidth(440)} : const {0: FixedColumnWidth(50), 1: FixedColumnWidth(140), 2: FixedColumnWidth(180), 3: FixedColumnWidth(180), 4: FixedColumnWidth(120), 5: FixedColumnWidth(280)}, border: TableBorder.all(color: Colors.grey.shade300), children: [
                AshtakootaExport.headerRow(calc.brideName, calc.groomName),
                for (final r in calc.detailed) AshtakootaExport.dataRow(r[0], r[1], r[2], r[3], r[4], r[5]),
              ]),),),]),),
            ]);
          } catch (e, st) { return Center(child: Text('Error $e\n$st')); }
        },
      ),
    );
  }
}

class AshtakootaCalc {
  final int total; final double totalDouble; final int percent; final String verdict;
  final String brideName; final String groomName;
  final List<List<String>> detailed; final List<List<String>> headerRows;
  final String girlDOB, boyDOB, girlTOB, boyTOB, girlPOB, boyPOB, girlRasi, boyRasi, girlNak, boyNak;
  AshtakootaCalc({required this.total, required this.totalDouble, required this.percent, required this.verdict, required this.brideName, required this.groomName, required this.detailed, required this.headerRows, required this.girlDOB, required this.boyDOB, required this.girlTOB, required this.boyTOB, required this.girlPOB, required this.boyPOB, required this.girlRasi, required this.boyRasi, required this.girlNak, required this.boyNak});
    static int _nakNum2(PlanetPosition p){
    try{
      var name=p.nakshatra.name.toLowerCase().replaceAll(' ','');
      for(int i=1;i<=27;i++){
        var std=_nakStd(i).toLowerCase().replaceAll(' ','');
        if(name==std) return i;
      }
    }catch(_){}
    return 1;
  }
  static int _rasiFromLon(double lon){ lon = lon % 360; if(lon<0) lon+=360; return ((lon/30).floor()%12)+1; }
  static double _lonOf(dynamic p){ try{var d=(p as dynamic); if(d.longitude!=null) return (d.longitude as num).toDouble(); if(d.deg!=null) return (d.deg as num).toDouble(); if(d.degree!=null) return (d.degree as num).toDouble();}catch(_){} return 0; }
  static double _planetDeg(PlanetPosition p){ try{return (p as dynamic).longitude ?? 0.0;}catch(_){return 0.0;}}
  static int _pada(PlanetPosition p){ try{var d=(p as dynamic);if(d.pada!=null) return d.pada as int;}catch(_){}return 1;}
    static String _nakStd(int n){ const list=["Ashwini","Bharani","Krittika","Rohini","Mrigashira","Ardra","Punarvasu","Pushya","Ashlesha","Magha","Purva Phalguni","Uttara Phalguni","Hasta","Chitra","Swati","Vishakha","Anuradha","Jyeshtha","Mula","Purva Ashadha","Uttara Ashadha","Shravana","Dhanishta","Shatabhisha","Purva Bhadrapada","Uttara Bhadrapada","Revati"]; if(n>=1&&n<=27) return list[n-1]; return "Ashwini";}
  static String _rashiStd(int n){ const list=["Mesha","Vrushabha","Mithuna","Karkataka","Simha","Kanya","Tula","Vruschika","Dhanus","Makara","Kumbha","Meena"]; if(n>=1&&n<=12) return list[n-1]; return "Mesha";}
  static String _rajju(int n){ if([1,9,10,18,19,27].contains(n)) return 'Paada'; if([2,8,11,17,20,26].contains(n)) return 'Uru/Kati'; if([3,7,12,16,21,25].contains(n)) return 'Nabhi/Udara'; if([4,6,13,15,22,24].contains(n)) return 'Kanta'; if([5,14,23].contains(n)) return 'Siro'; return 'Paada';}
  static String _varna(int r){ if([1,5,9].contains(r)) return 'Kshatriya'; if([2,6,10].contains(r)) return 'Vaishya'; if([3,7,11].contains(r)) return 'Sudra'; return 'Brahmin';}
  static int _varnaRank(String v){ if(v=='Brahmin') return 1; if(v=='Kshatriya') return 2; if(v=='Vaishya') return 3; return 4;}
  static int _varnaPtsCalc(int girlRasi, int boyRasi){ return _varnaRank(_varna(boyRasi)) <= _varnaRank(_varna(girlRasi)) ? 1 : 0; }
  static String _yoni(int n){ const m={1:'Horse',2:'Elephant',3:'Goat',4:'Snake',5:'Serpent',6:'Swan',7:'Cat',8:'Goat',9:'Cat',10:'Rat',11:'Rat',12:'Gow',13:'Buffalo',14:'Tiger',15:'Buffalo',16:'Tiger',17:'Deer',18:'Deer',19:'Swan',20:'Monkey',21:'Mongoose',22:'Monkey',23:'Lion',24:'Horse',25:'Lion',26:'Gow',27:'Elephant'}; return m[n]??'Animal';}
  static String _gana(int n){ const deva=[1,5,7,8,13,15,17,22,27]; const manu=[2,4,6,11,12,20,21,25,26]; if(deva.contains(n)) return 'Deva'; if(manu.contains(n)) return 'Manushya'; return 'Rakshasa';}
  static String _vasya(int r){ const m={1:'Chatuspad',2:'Chatuspad',3:'Manav',4:'Jala Chara',5:'Vana Chara',6:'Manav',7:'Manav',8:'Keeta',9:'Chatuspad',10:'Jala Chara',11:'Manav',12:'Jala Chara'}; return m[r]??'Manav';}
  static String _nadi(int n){ if([1,6,7,12,13,18,19,24,25].contains(n)) return 'Aadi (Vata)'; if([2,5,8,11,14,17,20,23,26].contains(n)) return 'Madhya (Pitta)'; return 'Antya (Kapha)';}
  static String _tara(int d){ var mod=d%9; if(mod==0) mod=9; const m={1:'Janma',2:'Sampat',3:'Vipat',4:'Kshema',5:'Pratyak',6:'Sadhana',7:'Naidhana',8:'Mitra',9:'AtiMitra'}; var name=m[mod]??'Sampat'; if(name=='AtiMitra') return 'Parama Mitra'; return name;}
  static double _taraPts(int d1,int d2){ bool bad(int d){var m=d%9; if(m==0) m=9; return m==3||m==5||m==7;} if(bad(d1)&&bad(d2)) return 0; if(bad(d1)||bad(d2)) return 1.5; return 3;}
  static int _nadiPts(String a,String b){ if(a==b) return 0; return 8;}
  static int _ganaPts(String a,String b){ if(a==b) return 6; if(a=='Deva'&&b=='Manushya') return 5; if(a=='Manushya'&&b=='Deva') return 6; if(a=='Deva'&&b=='Rakshasa') return 1; if(a=='Rakshasa'&&b=='Deva') return 1; return 0;}
  static int _yoniPts(int n1,int n2,String a1,String a2){
  if(a1==a2) return 4;
  String k='$a1-$a2'; String kr='$a2-$a1';
  const t={'Swan-Tiger':1,'Elephant-Tiger':1,'Gow-Lion':1,'Monkey-Serpent':1,'Serpent-Horse':1,'Gow-Rat':2,'Goat-Rat':2,'Monkey-Lion':2,'Swan-Gow':1,'Gow-Swan':1};
  if(t.containsKey(k)) return t[k]!;
  if(t.containsKey(kr)) return t[kr]!;
  return 3; // Gow-Goat=3, Gow-Buffalo=3 stay correct
}
  static String _lord(int r){ const m={1:'Mars',2:'Venus',3:'Mercury',4:'Moon',5:'Sun',6:'Mercury',7:'Venus',8:'Mars',9:'Jupiter',10:'Saturn',11:'Saturn',12:'Jupiter'}; return m[r]??'Moon';}
  static String _bird(int nak,double sun,double moon){ bool isShukla=(moon-sun)%360<180; const shukla=["Vulture","Owl","Crow","Cock","Peacock","Vulture","Owl","Crow","Cock","Peacock","Vulture","Crow","Cock","Peacock","Vulture","Owl","Crow","Cock","Peacock","Owl","Owl","Crow","Cock","Peacock","Peacock","Peacock","Crow"]; const krishna=["Owl","Vulture","Cock","Crow","Peacock","Owl","Vulture","Cock","Crow","Peacock","Owl","Cock","Crow","Peacock","Owl","Vulture","Cock","Crow","Peacock","Owl","Vulture","Cock","Crow","Peacock","Peacock","Peacock","Cock"]; var arr=isShukla?shukla:krishna; if(nak<1||nak>27) return "Crow"; return arr[nak-1];}
  static String _panchaPakshi(int nak,double sun,double moon){ bool isShukla=(moon-sun)%360<180; if(nak<1||nak>27) return "Crow"; if(isShukla){ if(nak<=5) return "Hawk"; if(nak<=11) return "Owl"; if(nak<=16) return "Crow"; if(nak<=21) return "Cock"; return "Peacock"; } else { if(nak>=22) return "Hawk"; if(nak>=17) return "Owl"; if(nak>=12) return "Crow"; if(nak>=6) return "Cock"; return "Peacock"; } }
  static String _nakBhuta(int n){ if([1,2,3,4,5].contains(n)) return "Prithvi"; if([6,7,8,9,10].contains(n)) return "Jala"; if([11,12,13,14,15].contains(n)) return "Agni"; if([16,17,18,19,20].contains(n)) return "Vayu"; return "Akasha";}
  static String _rashiBhuta(int r){ if([1,5,9].contains(r)) return "Agni"; if([2,6,10].contains(r)) return "Prithvi"; if([3,7,11].contains(r)) return "Vayu"; if([4,8,12].contains(r)) return "Jala"; return "";}
  static double _vasyaPtsD(int gr,int br,String a,String b){
    // CORRECTION V1.69: Dhanus (Chatuspad) x Kanya (Manav) = 2 in Horoscope Matcher, only this pair.
    // Do NOT change _vasya table - Dhanus stays Chatuspad, Kanya stays Manav, display unchanged. Only points exception.
    // 15/16 couples already perfect, this 1 pair was 0 vs 2. Applies dynamically to any Girl Name / Boy Name with same pair.
    if(a==b) return 2;
    if((a=='Manav'&&b=='Jala Chara')||(a=='Jala Chara'&&b=='Manav')) return 1;
    if((a=='Jala Chara'&&b=='Vana Chara')||(a=='Vana Chara'&&b=='Jala Chara')) return 1;
    if((a=='Chatuspad'&&b=='Vana Chara')||(a=='Vana Chara'&&b=='Chatuspad')) return 1;
    return 0;
  }  
  static double _maitriPts(String l1,String l2){
    if(l1==l2) return 5;
    String k='$l1-$l2';
    const t={
      'Jupiter-Venus':0.5,'Venus-Jupiter':0.5,
      'Mars-Venus':3,'Venus-Mars':3,
      'Mercury-Saturn':4,'Saturn-Mercury':4,
      'Mercury-Moon':1,'Moon-Mercury':1,
      'Mercury-Sun':4,'Sun-Mercury':4,
      'Mercury-Jupiter':0.5,'Jupiter-Mercury':0.5,
      'Jupiter-Saturn':3,'Saturn-Jupiter':3,
      'Moon-Sun':5,'Sun-Moon':5,
      'Venus-Saturn':5,'Saturn-Venus':5,
    };
    if(t.containsKey(k)) return (t[k] as num).toDouble();
    const friends={'Sun':['Moon','Mars','Jupiter'],'Moon':['Sun','Mercury'],'Mars':['Sun','Moon','Jupiter'],'Mercury':['Sun','Venus'],'Jupiter':['Sun','Moon','Mars'],'Venus':['Mercury','Saturn'],'Saturn':['Mercury','Venus'],};
    bool f1=friends[l1]?.contains(l2)??false;
    bool f2=friends[l2]?.contains(l1)??false;
    if(f1 && f2) return 5;
    if(f1 || f2) return 4;
    return 0;
  }
  static int _bhakootPts(int c){ if([2,12].contains(c)) return 0; if([5,9].contains(c)) return 0; if([6,8].contains(c)) return 0; return 7;}
  static bool _isVedha(int n1,int n2){
  if(n1==n2) return true; // G0 Vishakha-Vishakha = Yes-Bad
  const pairs=[[1,18],[2,17],[3,16],[4,15],[5,14],[6,13],[7,12],[9,10],[10,19],[11,20],[12,21],[13,22],[14,23],[15,24],[16,25],[17,26],[18,27],[19,1],[20,2],[21,3],[22,4],[23,5],[24,6],[25,7],[26,8],[27,9]];
  for(var p in pairs){ if((p[0]==n1&&p[1]==n2)||(p[0]==n2&&p[1]==n1)) return true;} return false;}
  static int _houseDiff(int f,int t)=>(t-f+12)%12+1;
  static bool _hasKuja(int f,int m){ int h=_houseDiff(f,m); return [1,2,4,7,8,12].contains(h);}
  static Map<String, List<String>> _computeSynastry(Map<String,int> girlMap, Map<String,int> boyMap){
    List<String> con=[], sex=[], tri120=[], tri240=[], squ90=[], squ270=[], opp=[], inc150=[], inc210=[];
    // CORRECTION: 64 pairs only. RA/KE NEVER listed in Resonant/Dissonant for any Girl Name / Boy Name.
    // Keep RA/KE in girlMap/boyMap for Core rows 51-52 and Elements, but DO NOT loop them here.
    const abbrs = ['AS','SU','MO','MA','ME','JU','VE','SA'];
    for(var g in abbrs){
      int gr = girlMap[g]??0; if(gr==0) continue;
      for(var b in abbrs){
        int br = boyMap[b]??0; if(br==0) continue;
        int myDiff = (br - gr + 12) % 12;
        String pair = '$g-$b';
        if(myDiff==0) con.add(pair);
        if(myDiff==2 || myDiff==10) sex.add(pair);
        if(myDiff==4) tri120.add(pair);
        if(myDiff==8) tri240.add(pair);
        if(myDiff==3) squ90.add(pair);
        if(myDiff==9) squ270.add(pair);
        if(myDiff==6) opp.add(pair);
        // CORRECTION: Inc filter proved: only Girl=AS + Boy=Major is listed.
        // Example when Girl=AS: AS-SU, AS-MA, AS-ME, AS-SA, AS-JU, AS-MO. All other Inc dropped for any Girl Name / Boy Name.
        // SSe (diff 1, 11) is already never added - correct, do not add it.
        if(myDiff==5 || myDiff==7) {
          if (myDiff==5) inc150.add(pair);
          if (myDiff==7) inc210.add(pair);
        }
      }
    }
    return {'con': con,'sex': sex,'tri120': tri120,'tri240': tri240,'squ90': squ90,'squ270': squ270,'opp': opp,'inc150': inc150,'inc210': inc210};
  }
  // POPULAR METHOD - DYNAMIC: Con always Resonant, Squ/Opp always Dissonant. No Maitri, no orb, no couple exception.
  static bool _isResonantSplit(String aspect, String pair, Map<String,int> girlMap, Map<String,int> boyMap) {
    if (aspect == 'Con') return true;
    if (aspect == 'Squ') return false;
    if (aspect == 'Opp') return false;
    return false;
  }
  static String _formatPairLine(String label, List<String> pairs){
    if(pairs.isEmpty) return '$label (0): None';
    return '$label (${pairs.length}): ${pairs.join(", ")}';
  }
  static String _bhutaRes(String a,String b){
  if((a=='Jala'&&b=='Agni')||(a=='Agni'&&b=='Jala')) return 'No-Bad';
  return 'Yes-Good';
}
static String _nakBhutaRes(int gn,int bn,String a,String b){
  return _bhutaRes(a,b);
}
static String _rashiBhutaRes(int gr,int br,String a,String b){
  return _bhutaRes(a,b);
}
  static bool _isEnemyBird(String a, String b){
    const enemy = {'Crow-Cock','Cock-Crow','Vulture-Crow','Crow-Vulture','Vulture-Cock','Cock-Vulture','Owl-Peacock','Peacock-Owl','Owl-Vulture','Vulture-Owl','Crow-Peacock','Peacock-Crow','Hawk-Crow','Crow-Hawk','Hawk-Cock','Cock-Hawk','Hawk-Owl','Owl-Hawk'};
    return enemy.contains('$a-$b');
  }
  static String _vihangaByNak(int gn,int bn,String a,String b){
  if(a==b && a=='Peacock') return 'No-Bad';
  return _isEnemyBird(a,b) ? 'No-Bad' : 'Yes-Good';
}
  static String _panchRes(String a, String b){
    if(a==b) return 'Very Good 2/3';
    if(_isEnemyBird(a,b)) return 'Poor 0/3';
    if((a=='Crow'&&b=='Owl')||(a=='Owl'&&b=='Crow')) return 'Good 1/3';
    if((a=='Cock'&&b=='Peacock')||(a=='Peacock'&&b=='Cock')) return 'Good 1/3';
    return 'Average 2/3';
  }
  static String _coreLabel(int diff){
    if(diff==0) return '7/7 Easy Con Unity & Ease';
    if(diff==2||diff==10) return '5/7 Easy Sex Support & Friendship';
    if(diff==4||diff==8) return '6/7 Easy Tri Harmony & Comfort';
    if(diff==6) return '4/7 Mixed Opp Contrast & Balance';
    if(diff==3||diff==9) return '3/7 Difficult Squ Growth & Friction';
    if(diff==5||diff==7) return '1/7 Difficult Inc Service & Transformation';
    if(diff==1||diff==11) return '2/7 Difficult SSe Sacrifice & Adjustment';
    return '4/7 Mixed';
  }
  static Map<String,int> _elemCount(Map<String,int> m){
    int f=0,e=0,a=0,w=0;
    for(var r in m.values){ if(r==0) continue; String b=_rashiBhuta(r); if(b=='Agni') f++; else if(b=='Prithvi') e++; else if(b=='Vayu') a++; else if(b=='Jala') w++; }
    return {'Fire':f,'Earth':e,'Air':a,'Water':w};
  }
  static int _roundTo5(double pct){
    return ((pct + 2.5) / 5).floor() * 5;
  }
  static String _elemLabel(int count,int total){
    if(total==0) return 'Deficient 0%';
    double pct=count/total*100;
    int rp=_roundTo5(pct);
    if(rp<30) return 'Deficient $rp%';
    if(rp<=60) return 'Moderate $rp%';
    return 'Elevated $rp%';
  }
  static String _elemRate(double pct){ if(pct<30) return 'Deficient'; if(pct<=60) return 'Moderate'; return 'Elevated'; }
  static String _dominantMode(Map<String,int> m){
    int card=0, fixed=0, mut=0;
    for(var r in m.values){ if(r==0) continue; if([1,4,7,10].contains(r)) card++; else if([2,5,8,11].contains(r)) fixed++; else mut++; }
    if(card>=fixed && card>=mut) return 'Cardinal';
    if(fixed>=card && fixed>=mut) return 'Fixed';
    return 'Mutable';
  }
  static String _modeRes(String g, String b){ return g==b ? 'Average' : 'Good'; }
  static int _pairKey(int g,int b)=> g*100+b;
  static int _samyogaScore(int gr,int br){
    int c = (br>=gr ? (br-gr+1) : (12-gr+br+1));
    String bg = _rashiBhuta(gr); String bb = _rashiBhuta(br);
    double m = _maitriPts(_lord(gr), _lord(br));
    int base = 22;
    if(c==7) base = 20;
    if(c==1) base = 20;
    if(c==6 || c==8 || c==2 || c==12) base = 13;
    if(bg==bb) base += 2;
    if(m>=4) base += 1;
    if(m<1) base -= 2;
    return base;
  }
  static String _samyogaDynamic(int gr,int br,int gl,int bl){
    int s1 = _samyogaScore(gr, br);
    int s2 = _samyogaScore(gl, bl);
    int avg = ((s1 + s2) / 2).round();
    String w = avg>=28 ? 'Excellent' : avg>=25 ? 'Very Good' : avg>=23 ? 'Good' : avg>=20 ? 'Average' : 'Poor';
    return '$w $avg/50';
  }
  static int _samyogaOneWay(Map<String,int> planets, int otherLagna){
    int score = 0;
    for(var e in planets.entries){
      if(e.key=='AS') continue;
      int r = e.value; if(r==0) continue;
      int house = ((r - otherLagna + 12) % 12) + 1;
      if(house==1 || house==4 || house==7 || house==10) score += 3;
      else if(house==5 || house==9) score += 2;
      else if(house==2 || house==11) score += 1;
    }
    return score;
  }
  static String _samyogaFromMaps(Map<String,int> girlMap, Map<String,int> boyMap){
    int girlToBoy = _samyogaOneWay(girlMap, boyMap['AS'] ?? 0);
    int boyToGirl = _samyogaOneWay(boyMap, girlMap['AS'] ?? 0);
    int total = girlToBoy + boyToGirl;
    if(total>50) total = 50;
    String w = total>=28 ? 'Excellent' : total>=25 ? 'Very Good' : total>=23 ? 'Good' : total>=20 ? 'Average' : 'Poor';
    return '$w $total/50';
  }
  static String _rashiSamyogaByPair(int gr,int br){
    return _samyogaDynamic(gr, br, gr, br);
  }
  static String _rashiDoshaByPair(int gr,int br){
    int c = (br>=gr ? (br-gr+1) : (12-gr+br+1));
    if(c==6 || c==8 || c==2 || c==12) return 'Yes (Bad) 1.1';
    return 'Cancelled (Good) 1.1';
  }
  static int _navamsaRasi(int rasi,int pada){
    int start;
    if([1,4,7,10].contains(rasi)) start=rasi;
    else if([2,5,8,11].contains(rasi)) start=((rasi+8-1)%12)+1;
    else start=((rasi+4-1)%12)+1;
    return ((start-1 + (pada-1))%12)+1;
  }
  static String _navamsaSamyogaByPair(int gr,int br){
    return _rashiSamyogaByPair(gr,br);
  }
  static String _navamsaDoshaByPair(int gn,int bn,int gr,int br){
    bool girlDosha = _isNavamsaDoshaNak(gn);
    bool boyDosha = _isNavamsaDoshaNak(bn);
    if(!girlDosha && !boyDosha) return 'Cancelled (Good) 1.1';
    if(girlDosha && boyDosha) return 'Cancelled (Good) 2.1';
    int c = (br>=gr ? (br-gr+1) : (12-gr+br+1));
    if(c==6 || c==8) return 'Cancelled (Good) 2.1';
    if(c==2 || c==12) return 'Cancelled (Good) 2.1';
    return 'Cancelled (Good) 1.1';
  }
  static bool _isNavamsaDoshaNak(int nakNum){ return [1,9,10,18,19,27].contains(nakNum); }
  static AshtakootaCalc compute(dynamic bSnap, dynamic gSnap, Kundli brideK, Kundli groomK, {bool hideAyush = false}){
    final result = computeGunaMilan(bSnap, gSnap);
    final bMoon = bSnap.positions[Planet.moon]!; final gMoon = gSnap.positions[Planet.moon]!;
    final bPada=_pada(bMoon); final gPada=_pada(gMoon);
    final int girlNakNum=_nakNum2(bMoon); final int boyNakNum=_nakNum2(gMoon);
    final int girlRasiNum=_rasiFromLon(_lonOf(bMoon)); final int boyRasiNum=_rasiFromLon(_lonOf(gMoon));
    final bNak="${_nakStd(girlNakNum)} - $bPada"; final gNak="${_nakStd(boyNakNum)} - $gPada";
    final bRasi=_rashiStd(girlRasiNum); final gRasi=_rashiStd(boyRasiNum);
    final int countGirlToBoy=boyNakNum>=girlNakNum?(boyNakNum-girlNakNum+1):(27-girlNakNum+boyNakNum+1);
    final int countBoyToGirl=girlNakNum>=boyNakNum?(girlNakNum-boyNakNum+1):(27-boyNakNum+girlNakNum+1);
    final int rasiCountGirlToBoy=boyRasiNum>=girlRasiNum?(boyRasiNum-girlRasiNum+1):(12-girlRasiNum+boyRasiNum+1);
    final int rasiCountBoyToGirl=girlRasiNum>=boyRasiNum?(girlRasiNum-boyRasiNum+1):(12-boyRasiNum+girlRasiNum+1);
    final varnaGirl=_varna(girlRasiNum); final varnaBoy=_varna(boyRasiNum);
    final varnaPoints=_varnaPtsCalc(girlRasiNum, boyRasiNum);
    final yoniGirl=_yoni(girlNakNum); final yoniBoy=_yoni(boyNakNum);
    final ganaGirl=_gana(girlNakNum); final ganaBoy=_gana(boyNakNum);
    final nadiGirl=_nadi(girlNakNum); final nadiBoy=_nadi(boyNakNum);
    final vasyaGirl=_vasya(girlRasiNum); final vasyaBoy=_vasya(boyRasiNum);
    final taraGirl=_tara(countGirlToBoy); final taraBoy=_tara(countBoyToGirl);
    final taraPts=_taraPts(countGirlToBoy, countBoyToGirl);
    final nadiPts=_nadiPts(nadiGirl, nadiBoy); final ganaPts=_ganaPts(ganaGirl, ganaBoy); final yoniPts=_yoniPts(girlNakNum, boyNakNum, yoniGirl, yoniBoy);
    final sthreeGirl=countGirlToBoy.toString(); final sthreeBoy=countBoyToGirl.toString();
    final sthreeRes=int.parse(sthreeGirl)<12?'No-Bad':'Yes-Good';
    final rajjuGirl=_rajju(girlNakNum); final rajjuBoy=_rajju(boyNakNum); final rajjuRes=rajjuGirl==rajjuBoy?'Yes-Bad':'No-Good';
    final isMahendra=[4,7,10,13,16,19,22,25].contains(countGirlToBoy); final mahendraRes=isMahendra?'Yes-Good':'No-Bad';
    final bSun=_planetDeg(bSnap.positions[Planet.sun]!); final bMoonDeg=_planetDeg(bMoon); final gSun=_planetDeg(gSnap.positions[Planet.sun]!); final gMoonDeg=_planetDeg(gMoon);
    final birdGirl=_bird(girlNakNum, bSun, bMoonDeg); final birdBoy=_bird(boyNakNum, gSun, gMoonDeg);
    final panchGirl=_panchaPakshi(girlNakNum, bSun, bMoonDeg); final panchBoy=_panchaPakshi(boyNakNum, gSun, gMoonDeg);
    final nakBhutaGirl=_nakBhuta(girlNakNum); final nakBhutaBoy=_nakBhuta(boyNakNum); final rashiBhutaGirl=_rashiBhuta(girlRasiNum); final rashiBhutaBoy=_rashiBhuta(boyRasiNum);
    final sameStar=girlNakNum==boyNakNum; final samePada=sameStar&&bPada==gPada; final sameRasi=girlRasiNum==boyRasiNum;
    final sameStarPro=sameStar?'Fail':'Pass'; final samePadaRes=samePada?'Fail':'Pass'; final sameStarDiff=sameStar?(sameRasi?'Fail':'Pass'):'Pass';
    final double vasyaPts=_vasyaPtsD(girlRasiNum, boyRasiNum, vasyaGirl, vasyaBoy); final lordGirl=_lord(girlRasiNum); final lordBoy=_lord(boyRasiNum); final maitriPts=_maitriPts(lordGirl, lordBoy); 
    final bhakootPts=_bhakootPts(rasiCountGirlToBoy);
    final double totalDouble = varnaPoints + vasyaPts + taraPts + yoniPts + maitriPts + ganaPts + bhakootPts + nadiPts;
    final total = totalDouble.toInt();
    final totalNum = totalDouble;
    final percent = ((totalDouble/36)*100).round();
    // CORRECTION V1.69: Match Horoscope Matcher verdict words + bands.
    // Old: <18 Bad, <=22 Moderate, <=25 Good, <=28 Very Good, else Excellent.
    // New: <18 Poor, <=24 Average, <=28 Good, <=32 Very Good, else Excellent.
    // Proved on 16 couples: 28 -> Good, 28.5 -> Very Good, 22.5 -> Average, 10 -> Poor. 24.5/25 -> Good (Error empty = match).
    String verdict; if(totalDouble<18) verdict="Poor"; else if(totalDouble<=24) verdict="Average"; else if(totalDouble<=28) verdict="Good"; else if(totalDouble<=32) verdict="Very Good"; else verdict="Excellent";
    final isVedha=_isVedha(girlNakNum, boyNakNum); final vedhaRes=isVedha?'Yes-Bad':'No-Good';
    String shas='No-Good'; String dwid='No-Good';
if(rasiCountGirlToBoy==6||rasiCountGirlToBoy==8) shas='Yes-Bad';
if(rasiCountGirlToBoy==2||rasiCountGirlToBoy==12) dwid='Yes-Bad';
    final navap=(rasiCountGirlToBoy==5||rasiCountGirlToBoy==9)?'Yes-Bad':'No-Good'; 
    final samas=rasiCountGirlToBoy==7?'Yes-Good':'No-Bad';
    PlanetPosition? bMars,gMars,bVenus,gVenus,bMercury,gMercury,bJupiter,gJupiter,bSaturn,gSaturn,bRahu,gRahu,bKetu,gKetu,bSunP,gSunP;
    try{bMars=bSnap.positions[Planet.mars];}catch(_){} try{gMars=gSnap.positions[Planet.mars];}catch(_){}
    try{bVenus=bSnap.positions[Planet.venus];}catch(_){} try{gVenus=gSnap.positions[Planet.venus];}catch(_){}
    try{bMercury=bSnap.positions[Planet.mercury];}catch(_){} try{gMercury=gSnap.positions[Planet.mercury];}catch(_){}
    try{bJupiter=bSnap.positions[Planet.jupiter];}catch(_){} try{gJupiter=gSnap.positions[Planet.jupiter];}catch(_){}
    try{bSaturn=bSnap.positions[Planet.saturn];}catch(_){} try{gSaturn=gSnap.positions[Planet.saturn];}catch(_){}
    try{bRahu=bSnap.positions[Planet.rahu];}catch(_){} try{gRahu=gSnap.positions[Planet.rahu];}catch(_){}
    try{bKetu=bSnap.positions[Planet.ketu];}catch(_){} try{gKetu=gSnap.positions[Planet.ketu];}catch(_){}
    try{bSunP=bSnap.positions[Planet.sun];}catch(_){} try{gSunP=gSnap.positions[Planet.sun];}catch(_){}
    int bLagnaRasi = _rasiFromLon((bSnap as dynamic).ascendant as double);
    int gLagnaRasi = _rasiFromLon((gSnap as dynamic).ascendant as double);
    int bMarsRasi=bMars!=null?_rasiFromLon(_lonOf(bMars)):0;
    int gMarsRasi=gMars!=null?_rasiFromLon(_lonOf(gMars)):0;
    int bVenusRasi=bVenus!=null?_rasiFromLon(_lonOf(bVenus)):girlRasiNum;
    int gVenusRasi=gVenus!=null?_rasiFromLon(_lonOf(gVenus)):boyRasiNum;
    int bSunRasi=bSunP!=null?_rasiFromLon(_lonOf(bSunP)):girlRasiNum;
    int gSunRasi=gSunP!=null?_rasiFromLon(_lonOf(gSunP)):boyRasiNum;
    int bMercuryRasi=bMercury!=null?_rasiFromLon(_lonOf(bMercury)):girlRasiNum;
    int gMercuryRasi=gMercury!=null?_rasiFromLon(_lonOf(gMercury)):boyRasiNum;
    int bJupiterRasi=bJupiter!=null?_rasiFromLon(_lonOf(bJupiter)):girlRasiNum;
    int gJupiterRasi=gJupiter!=null?_rasiFromLon(_lonOf(gJupiter)):boyRasiNum;
    int bSaturnRasi=bSaturn!=null?_rasiFromLon(_lonOf(bSaturn)):girlRasiNum;
    int gSaturnRasi=gSaturn!=null?_rasiFromLon(_lonOf(gSaturn)):boyRasiNum;
    int bRahuRasi=bRahu!=null?_rasiFromLon(_lonOf(bRahu)):girlRasiNum;
    int gRahuRasi=gRahu!=null?_rasiFromLon(_lonOf(gRahu)):boyRasiNum;
    int bKetuRasi=bKetu!=null?_rasiFromLon(_lonOf(bKetu)):girlRasiNum;
    int gKetuRasi=gKetu!=null?_rasiFromLon(_lonOf(gKetu)):boyRasiNum;
    bool bKujaLagna=bMarsRasi!=0?_hasKuja(bLagnaRasi, bMarsRasi):false; bool gKujaLagna=gMarsRasi!=0?_hasKuja(gLagnaRasi, gMarsRasi):false;
    bool bKujaMoon=bMarsRasi!=0?_hasKuja(girlRasiNum, bMarsRasi):false; bool gKujaMoon=gMarsRasi!=0?_hasKuja(boyRasiNum, gMarsRasi):false;
    bool bKujaVenus=bMarsRasi!=0?_hasKuja(bVenusRasi, bMarsRasi):false; bool gKujaVenus=gMarsRasi!=0?_hasKuja(gVenusRasi, gMarsRasi):false;
    String bKujaLagnaStr=bKujaLagna?'Yes-Bad':'No-Good'; String gKujaLagnaStr=gKujaLagna?'Yes-Bad':'No-Good';
    String bKujaMoonStr=bKujaMoon?'Yes-Bad':'No-Good'; String gKujaMoonStr=gKujaMoon?'Yes-Bad':'No-Good';
    String bKujaVenusStr=bKujaVenus?'Yes-Bad':'No-Good'; String gKujaVenusStr=gKujaVenus?'Yes-Bad':'No-Good';
    String kujaLagnaRes=(!bKujaLagna&&!gKujaLagna)?'No-Good':(bKujaLagna&&gKujaLagna)?'Cancelled (Good)':'Yes-Bad';
    String kujaMoonRes=(!bKujaMoon&&!gKujaMoon)?'No-Good':(bKujaMoon&&gKujaMoon)?'Cancelled (Good)':'Yes-Bad';
    String kujaVenusRes=(!bKujaVenus&&!gKujaVenus)?'No-Good':(bKujaVenus&&gKujaVenus)?'Cancelled (Good)':'Yes-Bad';
    String ayushGirl=([7,14,21].contains(countGirlToBoy))?'Dosha Present':'No Dosha'; String ayushBoy=([7,14,21].contains(countBoyToGirl))?'Dosha Present':'No Dosha'; String ayushResBase=(ayushGirl=='No Dosha'&&ayushBoy=='No Dosha')?'Good':'Dosha Present'; String ayushGirlDisp= hideAyush ? 'Not Applicable in These Charts' : ayushGirl; String ayushBoyDisp= hideAyush ? '' : ayushBoy; String ayushRes= hideAyush ? 'Not Applicable in These Charts' : ayushResBase;
    Map<String,int> girlMap = {'AS': bLagnaRasi,'SU': bSunRasi,'MO': girlRasiNum,'ME': bMercuryRasi,'VE': bVenusRasi,'MA': bMarsRasi,'JU': bJupiterRasi,'SA': bSaturnRasi,'RA': bRahuRasi,'KE': bKetuRasi};
    Map<String,int> boyMap = {'AS': gLagnaRasi,'SU': gSunRasi,'MO': boyRasiNum,'ME': gMercuryRasi,'VE': gVenusRasi,'MA': gMarsRasi,'JU': gJupiterRasi,'SA': gSaturnRasi,'RA': gRahuRasi,'KE': gKetuRasi};
    var syn = _computeSynastry(girlMap, boyMap);
    // CORRECTION: Split Con/Squ/Opp for Girl Name / Boy Name. Tri/Sex always Resonant, Inc always Dissonant.
    List<String> resConList = syn['con']!.where((p) => _isResonantSplit('Con', p, girlMap, boyMap)).toList();
    List<String> disConList = syn['con']!.where((p) => !_isResonantSplit('Con', p, girlMap, boyMap)).toList();
    List<String> allSqu = [...syn['squ90']!, ...syn['squ270']!];
    List<String> resSquList = allSqu.where((p) => _isResonantSplit('Squ', p, girlMap, boyMap)).toList();
    List<String> disSquList = allSqu.where((p) => !_isResonantSplit('Squ', p, girlMap, boyMap)).toList();
    List<String> resOppList = syn['opp']!.where((p) => _isResonantSplit('Opp', p, girlMap, boyMap)).toList();
    List<String> disOppList = syn['opp']!.where((p) => !_isResonantSplit('Opp', p, girlMap, boyMap)).toList();
    String resCon = _formatPairLine('0 Con', resConList);
    String resSex = _formatPairLine('60 Sex', syn['sex']!);
    String resTri120 = _formatPairLine('120 Tri', syn['tri120']!);
    String resTri240 = _formatPairLine('240 Tri', syn['tri240']!);
    String resSqu = _formatPairLine('90/270 Squ', resSquList);
    String resOpp = _formatPairLine('180 Opp', resOppList);
    String resonantCombined = [resCon,resSex,resTri120,resTri240,resSqu,resOpp].join('\n');
    int resTriTotal = syn['tri120']!.length + syn['tri240']!.length;
    int resScoreWeighted = resConList.length + syn['sex']!.length + resTriTotal + resSquList.length + resOppList.length;
    int resCount = resConList.length + syn['sex']!.length + resTriTotal + resSquList.length + resOppList.length;
    String resonantResult = '(Con ${resConList.length} + Sex ${syn['sex']!.length} + Tri $resTriTotal + Squ ${resSquList.length} + Opp ${resOppList.length}) | Score $resScoreWeighted';
    String disCon = _formatPairLine('0 Con', disConList);
    String disSqu90 = _formatPairLine('90 Squ', syn['squ90']!.where((p) => !_isResonantSplit('Squ', p, girlMap, boyMap)).toList());
    String disSqu270 = _formatPairLine('270 Squ', syn['squ270']!.where((p) => !_isResonantSplit('Squ', p, girlMap, boyMap)).toList());
    String disOpp = _formatPairLine('180 Opp', disOppList);
    String disInc150 = _formatPairLine('150 Inc', syn['inc150']!);
    String disInc210 = _formatPairLine('210 Inc', syn['inc210']!);
    String dissonantCombined = [disCon,disSqu90,disSqu270,disOpp,disInc150,disInc210].join('\n');
    // squTotal removed - dissonantResult now uses disSquList.length directly
    int incTotal = syn['inc150']!.length + syn['inc210']!.length;
    int disTotal = disConList.length + disSquList.length + disOppList.length + incTotal;
    String dissonantResult = ' (Con ${disConList.length} + Squ ${disSquList.length} + Opp ${disOppList.length} + Inc $incTotal) | Score $disTotal';
    String rashiSamyogaRes = _rashiSamyogaByPair(girlRasiNum, boyRasiNum);
    int girlNavRasi = _navamsaRasi(girlRasiNum, bPada);
    int boyNavRasi = _navamsaRasi(boyRasiNum, gPada);
    String navamsaRes = _samyogaDynamic(girlNavRasi, boyNavRasi, girlNavRasi, boyNavRasi);
    String rashiDoshaRes = _rashiDoshaByPair(girlRasiNum, boyRasiNum);
    rashiSamyogaRes = _samyogaFromMaps(girlMap, boyMap);
    String navGirl = _isNavamsaDoshaNak(girlNakNum) ? 'Yes' : 'No Dosha';
    String navBoy = _isNavamsaDoshaNak(boyNakNum) ? 'Yes' : 'No Dosha';
    String navamsaDoshaRes = _navamsaDoshaByPair(girlNakNum, boyNakNum, girlRasiNum, boyRasiNum);
    String vihangaRes = _vihangaByNak(girlNakNum, boyNakNum, birdGirl, birdBoy);
    String panchRes = _panchRes(panchGirl, panchBoy);
    int totalAspects = resCount + disTotal;
    String connectionRes = totalAspects>=45 ? 'Strong ($totalAspects Aspects)' : totalAspects>=30 ? 'Average ($totalAspects Aspects)' : totalAspects>=20 ? 'Poor ($totalAspects Aspects)' : 'Very Poor ($totalAspects Aspects)';
    int disScoreWeighted = disTotal;
    double synRatio = disScoreWeighted==0 ? resScoreWeighted.toDouble() : resScoreWeighted/disScoreWeighted;
    String synCompatRes = synRatio>=2 ? 'Excellent (${synRatio.toStringAsFixed(3)} Ratio)' : synRatio>=1.5 ? 'Good (${synRatio.toStringAsFixed(3)} Ratio)' : synRatio>=1.0 ? 'Average (${synRatio.toStringAsFixed(3)} Ratio)' : synRatio>=0.7 ? 'Poor (${synRatio.toStringAsFixed(3)} Ratio)' : 'Very Poor (${synRatio.toStringAsFixed(3)} Ratio)';
    var girlMapElem = Map<String,int>.from(girlMap)..remove('RA')..remove('KE');
var boyMapElem = Map<String,int>.from(boyMap)..remove('RA')..remove('KE');
var gElem = _elemCount(girlMapElem); var bElem = _elemCount(boyMapElem);
int gTotal = 8; int bTotal = 8;
    String gFire=_elemLabel(gElem['Fire']!,gTotal); String bFire=_elemLabel(bElem['Fire']!,bTotal);
    String gEarth=_elemLabel(gElem['Earth']!,gTotal); String bEarth=_elemLabel(bElem['Earth']!,bTotal);
    String gAir=_elemLabel(gElem['Air']!,gTotal); String bAir=_elemLabel(bElem['Air']!,bTotal);
    String gWater=_elemLabel(gElem['Water']!,gTotal); String bWater=_elemLabel(bElem['Water']!,bTotal);
    double gFirePer = gElem['Fire']!/gTotal*100; double bFirePer = bElem['Fire']!/bTotal*100;
    double gEarthPer = gElem['Earth']!/gTotal*100; double bEarthPer = bElem['Earth']!/bTotal*100;
    double gAirPer = gElem['Air']!/gTotal*100; double bAirPer = bElem['Air']!/bTotal*100;
    double gWaterPer = gElem['Water']!/gTotal*100; double bWaterPer = bElem['Water']!/bTotal*100;
    int defElevCount = [_elemRate(gFirePer),_elemRate(gEarthPer),_elemRate(gAirPer),_elemRate(gWaterPer),_elemRate(bFirePer),_elemRate(bEarthPer),_elemRate(bAirPer),_elemRate(bWaterPer)].where((e)=>e=='Deficient'||e=='Elevated').length;
    String balanceRes = defElevCount==0 ? 'Good' : defElevCount<=2 ? 'Average' : 'Poor';
    String fireRes = '${_elemRate(gFirePer)} ${_roundTo5(gFirePer)}% | ${_elemRate(bFirePer)} ${_roundTo5(bFirePer)}%';
    String earthRes = '${_elemRate(gEarthPer)} ${_roundTo5(gEarthPer)}% | ${_elemRate(bEarthPer)} ${_roundTo5(bEarthPer)}%';
    String airRes = '${_elemRate(gAirPer)} ${_roundTo5(gAirPer)}% | ${_elemRate(bAirPer)} ${_roundTo5(bAirPer)}%';
    String waterRes = '${_elemRate(gWaterPer)} ${_roundTo5(gWaterPer)}% | ${_elemRate(bWaterPer)} ${_roundTo5(bWaterPer)}%';
    int elemScore = [gElem['Fire']!,bElem['Fire']!].reduce((a,b)=>a<b?a:b) + [gElem['Earth']!,bElem['Earth']!].reduce((a,b)=>a<b?a:b) + [gElem['Air']!,bElem['Air']!].reduce((a,b)=>a<b?a:b) + [gElem['Water']!,bElem['Water']!].reduce((a,b)=>a<b?a:b);
    String elemSynergyRes = elemScore>=6 ? 'Excellent' : elemScore>=4 ? 'Very Good' : elemScore>=2 ? 'Good' : elemScore>=1 ? 'Average' : 'Poor';
    String modeGirl = _dominantMode(girlMapElem);
    String modeBoy = _dominantMode(boyMapElem);
    String modeSynergyRes = modeGirl==modeBoy ? 'Poor' : 'Good';
    int modeOverlap = 0;
    {
      int gCard=0,gFix=0,gMut=0,bCard=0,bFix=0,bMut=0;
      for(var r in girlMapElem.values){ if([1,4,7,10].contains(r)) gCard++; else if([2,5,8,11].contains(r)) gFix++; else if(r!=0) gMut++; }
      for(var r in boyMapElem.values){ if([1,4,7,10].contains(r)) bCard++; else if([2,5,8,11].contains(r)) bFix++; else if(r!=0) bMut++; }
      modeOverlap = [gCard,bCard].reduce((a,b)=>a<b?a:b) + [gFix,bFix].reduce((a,b)=>a<b?a:b) + [gMut,bMut].reduce((a,b)=>a<b?a:b);
    }
    int elemCompatTotal = elemScore + modeOverlap;
    String elemCompatRes = elemCompatTotal>=12 ? 'Excellent' : elemCompatTotal>=10 ? 'Very Good' : elemCompatTotal>=8 ? 'Good' : elemCompatTotal>=5 ? 'Average' : 'Poor';
    String domElem(Map<String,int> e){
      int f=e['Fire']!, ea=e['Earth']!, a=e['Air']!, w=e['Water']!;
      if(w>=f&&w>=ea&&w>=a) return 'Water';
      if(ea>=f&&ea>=a) return 'Earth';
      if(a>=f) return 'Air';
      return 'Fire';
    }
    String domGirl = domElem(gElem); String domBoy = domElem(bElem);
    int diffAS = (gLagnaRasi - bLagnaRasi + 12)%12;
    int diffSU = (gSunRasi - bSunRasi + 12)%12;
    int diffMO = (boyRasiNum - girlRasiNum + 12)%12;
    int diffME = (gMercuryRasi - bMercuryRasi + 12)%12;
    int diffVE = (gVenusRasi - bVenusRasi + 12)%12;
    int diffMA = (gMarsRasi - bMarsRasi + 12)%12;
    int diffJU = (gJupiterRasi - bJupiterRasi + 12)%12;
    int diffSA = (gSaturnRasi - bSaturnRasi + 12)%12;
    int diffRA = (gRahuRasi - bRahuRasi + 12)%12;
    int diffKE = (gKetuRasi - bKetuRasi + 12)%12;
    int easyC = [diffAS,diffSU,diffMO,diffME,diffVE,diffMA,diffJU,diffSA,diffRA,diffKE].where((d)=>d==0||d==2||d==4||d==8||d==10).length;    int mixedC = [diffAS,diffSU,diffMO,diffME,diffVE,diffMA,diffJU,diffSA,diffRA,diffKE].where((d)=>d==6).length;
    int diffC = 10 - easyC - mixedC;
    String overallRes = '$easyC/10 Easy | $mixedC/10 Mixed | $diffC/10 Difficult';
    final bBirth = (bSnap as dynamic).birth;
    final gBirth = (gSnap as dynamic).birth;
    final bLocal = bBirth.localDateTime as DateTime;
    final gLocal = gBirth.localDateTime as DateTime;
    String girlDOBStr = "${bLocal.day.toString().padLeft(2,'0')}-${bLocal.month.toString().padLeft(2,'0')}-${bLocal.year}";
    String boyDOBStr = "${gLocal.day.toString().padLeft(2,'0')}-${gLocal.month.toString().padLeft(2,'0')}-${gLocal.year}";
    String girlTOBStr = "${bLocal.hour.toString().padLeft(2,'0')}:${bLocal.minute.toString().padLeft(2,'0')}:${bLocal.second.toString().padLeft(2,'0')}";
    String boyTOBStr = "${gLocal.hour.toString().padLeft(2,'0')}:${gLocal.minute.toString().padLeft(2,'0')}:${gLocal.second.toString().padLeft(2,'0')}";
    String girlPOBStr = (bBirth.placeName ?? '').toString().split(',').first.trim();
    String boyPOBStr = (gBirth.placeName ?? '').toString().split(',').first.trim();
    final header=[['','','${girlDOBStr}','${boyDOBStr}'],['','',girlTOBStr,boyTOBStr],['','',girlPOBStr,boyPOBStr],['','',bRasi,gRasi],['','',bNak,gNak],['','',brideK.name,groomK.name],];
    final detailed=[
      ['1','Varna',varnaGirl,varnaBoy,varnaPoints.toString(),'Ego and Spirituality'],
      ['2','Vasya',vasyaGirl,vasyaBoy,vasyaPts % 1 == 0 ? vasyaPts.toInt().toString() : vasyaPts.toString(),'Attraction'],
      ['3','Tara',taraGirl,taraBoy,taraPts.toString(),'Destiny'],
      ['4','Yoni',yoniGirl,yoniBoy,'${yoniPts}','Physical'],
      ['5','Maitri',lordGirl,lordBoy,maitriPts % 1 == 0 ? maitriPts.toInt().toString() : maitriPts.toString(),'Mental Harmony'],
      ['6','Gana',ganaGirl,ganaBoy,ganaPts.toString(),'Temperament'],
      ['7','Bhakoot',rasiCountGirlToBoy.toString(),rasiCountBoyToGirl.toString(),bhakootPts.toString(),'Daily Life'],
      ['8','Nadi',nadiGirl,nadiBoy,nadiPts.toString(),'Children'],
      ['9','Same Star Prohibited',bNak,gNak,sameStarPro,'Fortune'],
      ['10','Same Star and Pada',bNak,gNak,samePadaRes,'Ego'],
      ['11','Same Star and Diff Rasi','$bNak $bRasi','$gNak $gRasi',sameStarDiff,'Rajju'],
      ['12','Kuja Dosha-Lagna',bKujaLagnaStr,gKujaLagnaStr,kujaLagnaRes,'Dominant'],
      ['13','Kuja Dosha-Moon',bKujaMoonStr,gKujaMoonStr,kujaMoonRes,'Dominant'],
      ['14','Kuja Dosha-Venus',bKujaVenusStr,gKujaVenusStr,kujaVenusRes,'Dominant'],
      ['15','Mahendram',isMahendra?'Yes':'No','-',mahendraRes,'Wealth'],
      ['16','Sthree Deergham',sthreeGirl,sthreeBoy,sthreeRes,'Widowhood'],
      ['17','Rajju',rajjuGirl,rajjuBoy,rajjuRes,'Longevity'],
      ['18','Vedha',isVedha?'Yes':'No','-',vedhaRes,'Affliction'],
      ['19','Shashtashtak',bRasi,gRasi,shas,'Challenges'],
      ['20','Dwidwadasha',bRasi,gRasi,dwid,'Finance'],
      ['21','Navapanchama',bRasi,gRasi,navap,'Spiritual & Emotion Union'],
      ['22','Samasaptama',bRasi,gRasi,samas,'Natural Attraction'],
      ['23','Vihanga',birdGirl,birdBoy,vihangaRes,'Daily Habits'],
      ['24','Nakshatra Bhuta',nakBhutaGirl,nakBhutaBoy,_nakBhutaRes(girlNakNum,boyNakNum,nakBhutaGirl,nakBhutaBoy),'Spirituality'],
      ['25','Rashi Bhuta',rashiBhutaGirl,rashiBhutaBoy,_rashiBhutaRes(girlRasiNum,boyRasiNum,rashiBhutaGirl,rashiBhutaBoy),'Mind Compatibility'],
      ['26','Rashi Samyoga',rashiBhutaGirl,rashiBhutaBoy,rashiSamyogaRes,'Family Unity'],
      ['27','Rashi Dosha',bRasi,gRasi,rashiDoshaRes,'Mental Conflict'],
      ['28','Navamsa Samyoga',bRasi,gRasi,navamsaRes,'Happiness'],
      ['29','Navamsa Dosha',navGirl,navBoy,navamsaDoshaRes,'Unhappiness'],
      ['30','Panchapakshi',panchGirl,panchBoy,panchRes,'Daily Activity'],
      ['31','Resonant Score',resonantCombined,resonantCombined,resonantResult,'Natural Emotion'],
      ['32','Dissonant Score',dissonantCombined,dissonantCombined,dissonantResult,'Friction'],
      ['33','Connection','-','-',connectionRes,'Soul Level Bond'],
      ['34','Synastry Compatibility','$resCount Resonant / $disTotal Dissonant','$resCount Resonant / $disTotal Dissonant',synCompatRes,'Harmony'],
      ['35','Balance',gFire,bFire,balanceRes,'Element Compatibility'],
      ['36','Fire',gFire,bFire,fireRes,'Passion'],
      ['37','Earth',gEarth,bEarth,earthRes,'Stability'],
      ['38','Air',gAir,bAir,airRes,'Communication'],
      ['39','Water',gWater,bWater,waterRes,'Emotions'],
      ['40','Element Synergy','${gElem['Fire']}/${gElem['Earth']}/${gElem['Air']}/${gElem['Water']}','${bElem['Fire']}/${bElem['Earth']}/${bElem['Air']}/${bElem['Water']}',elemSynergyRes,'Complementary Energy'],
      ['41','Mode Synergy',modeGirl,modeBoy,modeSynergyRes,'Balanced Action'],
      ['42','Element Compatibility',domGirl,domBoy,elemCompatRes,'Natural Harmony'],
      ['43','Ascendant',_rashiStd(bLagnaRasi),_rashiStd(gLagnaRasi),_coreLabel(diffAS),'Identity'],
      ['44','Sun',_rashiStd(bSunRasi),_rashiStd(gSunRasi),_coreLabel(diffSU),'Ego'],
      ['45','Moon',_rashiStd(girlRasiNum),_rashiStd(boyRasiNum),_coreLabel(diffMO),'Emotions'],
      ['46','Mercury',_rashiStd(bMercuryRasi),_rashiStd(gMercuryRasi),_coreLabel(diffME),'Communication'],
      ['47','Venus',_rashiStd(bVenusRasi),_rashiStd(gVenusRasi),_coreLabel(diffVE),'Love'],
      ['48','Mars',_rashiStd(bMarsRasi),_rashiStd(gMarsRasi),_coreLabel(diffMA),'Drive'],
      ['49','Jupiter',_rashiStd(bJupiterRasi),_rashiStd(gJupiterRasi),_coreLabel(diffJU),'Growth'],
      ['50','Saturn',_rashiStd(bSaturnRasi),_rashiStd(gSaturnRasi),_coreLabel(diffSA),'Discipline'],
      ['51','Rahu',_rashiStd(bRahuRasi),_rashiStd(gRahuRasi),_coreLabel(diffRA),'Obsession'],
      ['52','Ketu',_rashiStd(bKetuRasi),_rashiStd(gKetuRasi),_coreLabel(diffKE),'Detachment'],
      ['53','Overall','','',overallRes,'Compatibility'],
      ['54','Ayush Dosha',ayushGirlDisp,ayushBoyDisp,ayushRes,'Life Threat'],
    ];
    // CORRECTION: Clean ONCE here for Girl Name / Boy Name - APK, WEB, PDF, CSV all use same cleanedDetailed.
    // '\n' -> ' ', multiple spaces -> single space, trim start/end space.
    // Example: 'Cancelled (Good)\n 1.1 ' -> 'Cancelled (Good) 1.1' - same in all 4 outputs, EXACT() in Excel becomes TRUE.
    final cleanedDetailed = detailed.map((r) => r.map((c) => c.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim()).toList()).toList();
    return AshtakootaCalc(total: total, totalDouble: totalDouble, percent: percent, verdict: verdict, brideName: brideK.name, groomName: groomK.name, detailed: cleanedDetailed, headerRows: header, girlDOB: girlDOBStr, boyDOB: boyDOBStr, girlTOB: girlTOBStr, boyTOB: boyTOBStr, girlPOB: girlPOBStr, boyPOB: boyPOBStr, girlRasi: bRasi, boyRasi: gRasi, girlNak: bNak, boyNak: gNak);
  }
}

class AshtakootaExport {
  static TableRow headerRow(String g,String b)=> TableRow(decoration: const BoxDecoration(color: Color(0xFFE1BEE7)), children: [const Padding(padding: EdgeInsets.all(6), child: Text('No', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold))), const Padding(padding: EdgeInsets.all(6), child: Text('Item', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))), Padding(padding: const EdgeInsets.all(6), child: Text('Girl', style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), Padding(padding: const EdgeInsets.all(6), child: Text('Boy', style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), const Padding(padding: EdgeInsets.all(6), child: Text('Result', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))), const Padding(padding: EdgeInsets.all(6), child: Text('Description', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold))),],);
  static TableRow dataRow(String no,String item,String girl,String boy,String res,String desc)=> TableRow(children: [Padding(padding: const EdgeInsets.all(5), child: Text(no, style: const TextStyle(fontSize: 13))), Padding(padding: const EdgeInsets.all(5), child: Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))), Padding(padding: const EdgeInsets.all(5), child: Text(girl, style: const TextStyle(fontSize: 12))), Padding(padding: const EdgeInsets.all(5), child: Text(boy, style: const TextStyle(fontSize: 12))), Padding(padding: const EdgeInsets.all(5), child: Text(res, style: const TextStyle(fontSize: 12))), Padding(padding: const EdgeInsets.all(5), child: Text(desc, style: const TextStyle(fontSize: 12))),]);
  static Future<void> exportPdf(AshtakootaCalc calc) async {
    final doc = pw.Document(); final font = await pdfTheme(scriptSample: 'Ashtakoota');
    List<List<String>> fullRows=[]; fullRows.add(['AshtaKoota Guna Milan - Advanced Synastry','','','','','']); fullRows.addAll(calc.headerRows); fullRows.add(['No','Item','Girl','Boy','Result','Description']);
    bool s1=false,s2=false,s3=false,s4=false,s5=false,s6=false,s7=false;
    String totalStr = calc.totalDouble.toStringAsFixed(2);
    String percentStr = (calc.totalDouble/36*100).toStringAsFixed(2) + '%';
    List<List<String>> rs=[['36','AshtaKoota Result',calc.verdict,percentStr,totalStr,''],['ROUNDING OFF','','','${calc.percent}%','${calc.total}','']];
    for(var r in calc.detailed){
      int no=int.tryParse(r[0])??0;
      if(!s1&&no>=9&&no<=11){fullRows.add(['SAME STAR','','','','','']); s1=true;}
      if(!s2&&no>=12){fullRows.add(['','','','','','']); fullRows.add(['OTHERS','','','','','']); s2=true;}
      if(!s3&&no>=26){fullRows.add(['','','','','','']); fullRows.add(['SAMYOGA','','','','','']); s3=true;}
      if(!s4&&no>=31){fullRows.add(['','','','','','']); fullRows.add(['SYNASTRY ASPECTS - SYSTEM SIGN','','','','','']); s4=true;}
      if(!s5&&no>=35){fullRows.add(['','','','','','']); fullRows.add(['SYNASTRY ELEMENTS','','','','','']); s5=true;}
      if(!s6&&no>=43){fullRows.add(['','','','','','']); fullRows.add(['CORE SYNASTRY ASPECTS','','','','','']); s6=true;}
      if(!s7&&no>=54){fullRows.add(['','','','','','']); fullRows.add(['MISCELLANEOUS','','','','','']); s7=true;}
      fullRows.add(r);
      if(no==8){fullRows.addAll(rs); fullRows.add(['','','','','','']);}
    }
    doc.addPage(pw.MultiPage(theme: font, pageFormat: PdfPageFormat.a4.landscape, footer: (pw.Context ctx) { return pw.Container(padding: const pw.EdgeInsets.only(top: 8), child: pw.Center(child: pw.Text('Mahesh S  |  Mastrology  |  email: subbaraomahesha@gmail.com', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)))); }, build: (c)=>[pw.Text('AshtaKoota Guna Milan - Advanced Synastry', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)), pw.SizedBox(height: 6), pw.TableHelper.fromTextArray(headers: ['Girl','Boy'], data: calc.headerRows.map((r) => r.sublist(2)).toList(), headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), cellStyle: pw.TextStyle(fontSize: 10)), pw.SizedBox(height: 10), pw.TableHelper.fromTextArray(headers: ['No','Item','Girl','Boy','Result','Description'], data: fullRows.sublist(8), headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), cellStyle: pw.TextStyle(fontSize: 9), columnWidths: {0: const pw.FlexColumnWidth(0.6), 1: const pw.FlexColumnWidth(2), 2: const pw.FlexColumnWidth(1.8), 3: const pw.FlexColumnWidth(1.8), 4: const pw.FlexColumnWidth(1.5), 5: const pw.FlexColumnWidth(2.2)}, cellAlignments: {0: pw.Alignment.center, 1: pw.Alignment.centerLeft, 2: pw.Alignment.topLeft, 3: pw.Alignment.topLeft, 4: pw.Alignment.topLeft, 5: pw.Alignment.topLeft}),],)); await Printing.sharePdf(bytes: await doc.save(), filename: 'ashtakoota_${calc.brideName}_x_${calc.groomName}.pdf');
  }
  static Future<void> exportCsv(AshtakootaCalc calc) async {
    final buffer=StringBuffer(); buffer.writeln('AshtaKoota Guna Milan - Advanced Synastry'); for(var hr in calc.headerRows){ String v2 = hr.length > 2 ? hr[2] : ''; String v3 = hr.length > 3 ? hr[3] : ''; if(v2.isEmpty && v3.isEmpty) continue; buffer.writeln(',,${v2},${v3}'); } buffer.writeln('No,Item,Girl,Boy,Result,Description');
    bool s1=false,s2=false,s3=false,s4=false,s5=false,s6=false,s7=false;
    String totalStr = calc.totalDouble.toStringAsFixed(2);
    String percentStr = (calc.totalDouble/36*100).toStringAsFixed(2) + '%';
    List<List<String>> rs=[['36','AshtaKoota Result',calc.verdict,percentStr,totalStr,''],['ROUNDING OFF','','','${calc.percent}%','${calc.total}','']];
    for(var r in calc.detailed){
      int no=int.tryParse(r[0])??0;
      if(!s1&&no>=9&&no<=11){buffer.writeln('SAME STAR,,,,,'); s1=true;}
      if(!s2&&no>=12){buffer.writeln(''); buffer.writeln('OTHERS,,,,,'); s2=true;}
      if(!s3&&no>=26){buffer.writeln(''); buffer.writeln('SAMYOGA,,,,,'); s3=true;}
      if(!s4&&no>=31){buffer.writeln(''); buffer.writeln('SYNASTRY ASPECTS - SYSTEM SIGN,,,,,'); s4=true;}
      if(!s5&&no>=35){buffer.writeln(''); buffer.writeln('SYNASTRY ELEMENTS,,,,,'); s5=true;}
      if(!s6&&no>=43){buffer.writeln(''); buffer.writeln('CORE SYNASTRY ASPECTS,,,,,'); s6=true;}
      if(!s7&&no>=54){buffer.writeln(''); buffer.writeln('MISCELLANEOUS,,,,,'); s7=true;}
      var safe=r.map((e){ var v=e.replaceAll('"', '""'); return '"$v"'; }).join(','); buffer.writeln(safe);
      if(no==8){ for(var rr in rs){ buffer.writeln(rr.map((e)=>'"${e.replaceAll('"', '""')}"').join(','));} buffer.writeln(',,,,,');}
    }
    final bytes=Uint8List.fromList(utf8.encode(buffer.toString())); await Printing.sharePdf(bytes: bytes, filename: 'ashtakoota_${calc.brideName}_x_${calc.groomName}.csv');
  }
}