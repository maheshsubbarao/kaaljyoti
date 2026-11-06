import 'dart:convert';
import 'dart:typed_data';
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
              Container(decoration: BoxDecoration(color: const Color(0xFF76FF03), borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(10), child: Center(child: Text('AshtaKoota ${calc.totalDouble == calc.total.toDouble() ? calc.total : calc.totalDouble.toStringAsFixed(1)}/36 = ${calc.percent}% - ${calc.verdict} | All Dynamic', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),),
              const SizedBox(height: 8),
              Row(children: [
                Checkbox(value: !hideAyush, onChanged: (v) => onAyushChanged(!(v??false))), const Text('Show Ayush', style: TextStyle(fontSize: 12)),
                const Spacer(),
                OutlinedButton.icon(onPressed: () => AshtakootaExport.exportPdf(calc), icon: const Icon(Icons.picture_as_pdf, size: 16), label: const Text('PDF')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: () => AshtakootaExport.exportCsv(calc), icon: const Icon(Icons.table_chart, size: 16), label: const Text('CSV')),
              ]),
              const SizedBox(height: 8),
              ModuleCard(title: 'AshtaKoota ${calc.brideName} x ${calc.groomName}', child: Table(columnWidths: const {0: FlexColumnWidth(0.35), 1: FlexColumnWidth(0.9), 2: FlexColumnWidth(2.8), 3: FlexColumnWidth(2.8), 4: FlexColumnWidth(1.1), 5: FlexColumnWidth(0.9)}, border: TableBorder.all(color: Colors.grey.shade300), children: [
                AshtakootaExport.headerRow(calc.brideName, calc.groomName),
                for (final r in calc.detailed) AshtakootaExport.dataRow(r[0], r[1], r[2], r[3], r[4], r[5]),
              ],),),
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
      const list=['ashwini','bharani','krittika','rohini','mrigashira','ardra','punarvasu','pushya','ashlesha','magha','purvaphalguni','uttaraphalguni','hasta','chitra','swati','vishakha','anuradha','jyeshtha','moola','purvaashadha','uttaraashadha','shravana','dhanishta','shatabhisha','purvabhadrapada','uttarabhadrapada','revati'];
      var name=p.nakshatra.name.toLowerCase().replaceAll(' ','');
      for(int i=0;i<list.length;i++){ if(name.contains(list[i])) return i+1; }
    }catch(_){}
    return 1;
  }
  static int _rasiFromLon(double lon){ lon = lon % 360; if(lon<0) lon+=360; return ((lon/30).floor()%12)+1; }
  static double _lonOf(dynamic p){ try{var d=(p as dynamic); if(d.longitude!=null) return (d.longitude as num).toDouble(); if(d.deg!=null) return (d.deg as num).toDouble(); if(d.degree!=null) return (d.degree as num).toDouble();}catch(_){} return 0; }
  static double _planetDeg(PlanetPosition p){ try{return (p as dynamic).longitude ?? 0.0;}catch(_){return 0.0;}}
  static int _pada(PlanetPosition p){ try{var d=(p as dynamic);if(d.pada!=null) return d.pada as int;}catch(_){}return 1;}
  static String _nakStd(int n){ const list=["Aswini","Bharani","Krittika","Rohini","Mrugasira","Arudra","Punarvasu","Pushyami","Aslesha","Makha","Poorva Phalguni","Uttara Phalguni","Hasta","Chitra","Swati","Visakha","Anuradha","Jyeshta","Moola","Poorvashadha","Uttarashadha","Sravana","Dhanishta","Satabhisha","Poorva Bhaadra","Uttara Bhaadra","Revati"]; if(n>=1&&n<=27) return list[n-1]; return "Aswini";}
  static String _rashiStd(int n){ const list=["Mesha","Vrushabha","Midhuna","Karka","Simha","Kanya","Tula","Vruschika","Dhanus","Makara","Kumbha","Meena"]; if(n>=1&&n<=12) return list[n-1]; return "Mesha";}
  static String _rajju(int n){ if([1,9,10,18,19,27].contains(n)) return 'Pada'; if([2,8,11,17,20,26].contains(n)) return 'Uru/Kati'; if([3,7,12,16,21,25].contains(n)) return 'Nabhi/Udara'; if([4,6,13,15,22,24].contains(n)) return 'Kanta'; if([5,14,23].contains(n)) return 'Siro'; return 'Pada';}
  static String _varna(int r){ if([1,5,9].contains(r)) return 'Kshatriya'; if([2,6,10].contains(r)) return 'Vaishya'; if([3,7,11].contains(r)) return 'Sudra'; return 'Brahmin';}
  static int _varnaRank(String v){ if(v=='Brahmin') return 1; if(v=='Kshatriya') return 2; if(v=='Vaishya') return 3; return 4;}
  static int _varnaPtsCalc(int girlRasi, int boyRasi){ return _varnaRank(_varna(boyRasi)) < _varnaRank(_varna(girlRasi)) ? 1 : 0; }
  static String _yoni(int n){ const m={1:'Horse',2:'Elephant',3:'Goat',4:'Snake',5:'Serpent',6:'Dog',7:'Cat',8:'Goat',9:'Cat',10:'Rat',11:'Rat',12:'Cow',13:'Buffalo',14:'Tiger',15:'Buffalo',16:'Tiger',17:'Deer',18:'Deer',19:'Dog',20:'Monkey',21:'Mongoose',22:'Monkey',23:'Lion',24:'Horse',25:'Lion',26:'Cow',27:'Elephant'}; return m[n]??'Animal';}
  static String _gana(int n){ const deva=[1,5,7,8,13,15,17,22,27]; const manu=[2,4,6,11,12,20,21,25,26]; if(deva.contains(n)) return 'Deva'; if(manu.contains(n)) return 'Manushya'; return 'Rakshasa';}
  static String _vasya(int r){ const m={1:'Chatushpada',2:'Chatushpada',3:'Nara',4:'Jala Chara',5:'Vana Chara',6:'Nara',7:'Nara',8:'Keeta',9:'Nara',10:'Jala Chara',11:'Nara',12:'Jala Chara'}; return m[r]??'Nara';}
  static String _nadi(int n){ if([1,6,7,12,13,18,19,24,25].contains(n)) return 'Aadi'; if([2,5,8,11,14,17,20,23,26].contains(n)) return 'Madhya'; return 'Antya';}
  static String _tara(int d){ var mod=d%9; if(mod==0) mod=9; const m={1:'Janma',2:'Sampat',3:'Vipat',4:'Kshema',5:'Pratyak',6:'Sadhana',7:'Naidhana',8:'Mitra',9:'AtiMitra'}; var name=m[mod]??'Sampat'; if(name=='AtiMitra') return 'Parama Mitra'; return name;}
  static double _taraPts(int d1,int d2){ bool bad(int d){var m=d%9; if(m==0) m=9; return m==3||m==5||m==7;} if(bad(d1)&&bad(d2)) return 0; if(bad(d1)||bad(d2)) return 1.5; return 3;}
  static int _nadiPts(String a,String b){ if(a==b) return 0; return 8;}
  static int _ganaPts(String a,String b){ if(a==b) return 6; if((a=='Deva'&&b=='Manushya')||(a=='Manushya'&&b=='Deva')) return 6; if(a=='Deva'&&b=='Rakshasa') return 1; if(a=='Rakshasa'&&b=='Deva') return 1; return 0;}
  static int _yoniPts(int n1,int n2,String a1,String a2){ if(n1==n2) return 4; if((a1=='Monkey'&&a2=='Lion')||(a1=='Lion'&&a2=='Monkey')) return 2; return 3;}
  static String _lord(int r){ const m={1:'Mars',2:'Venus',3:'Mercury',4:'Moon',5:'Sun',6:'Mercury',7:'Venus',8:'Mars',9:'Jupiter',10:'Saturn',11:'Saturn',12:'Jupiter'}; return m[r]??'Moon';}
  static String _bird(int nak,double sun,double moon){ bool isShukla=(moon-sun)%360<180; const shukla=["Vulture","Owl","Crow","Cock","Peacock","Vulture","Owl","Crow","Cock","Peacock","Vulture","Crow","Cock","Peacock","Vulture","Owl","Crow","Cock","Peacock","Owl","Owl","Crow","Cock","Peacock","Peacock","Peacock","Crow"]; const krishna=["Owl","Vulture","Cock","Crow","Peacock","Owl","Vulture","Cock","Crow","Peacock","Owl","Cock","Crow","Peacock","Owl","Vulture","Cock","Crow","Peacock","Owl","Vulture","Cock","Crow","Peacock","Peacock","Peacock","Cock"]; var arr=isShukla?shukla:krishna; if(nak<1||nak>27) return "Crow"; return arr[nak-1];}
  static String _nakBhuta(int n){ if([1,2,3,4,5].contains(n)) return "Prithvi"; if([6,7,8,9,10].contains(n)) return "Jala"; if([11,12,13,14,15].contains(n)) return "Agni"; if([16,17,18,19,20].contains(n)) return "Vayu"; return "Akasha";}
  static String _rashiBhuta(int r){ if([1,5,9].contains(r)) return "Agni"; if([2,6,10].contains(r)) return "Prithvi"; if([3,7,11].contains(r)) return "Vayu"; if([4,8,12].contains(r)) return "Jala"; return "";}
  static int _vasyaPts(String a,String b){ if(a==b){ if(a=='Nara') return 1; return 2;} if((a=='Nara'&&b=='Chatushpada')||(a=='Chatushpada'&&b=='Nara')) return 1; if((a=='Jala Chara'&&b=='Vana Chara')||(a=='Vana Chara'&&b=='Jala Chara')) return 1; if((a=='Chatushpada'&&b=='Vana Chara')||(a=='Vana Chara'&&b=='Chatushpada')) return 1; return 0;}
  static int _maitriPts(String l1,String l2){ if(l1==l2) return 5; if((l1=='Jupiter'&&l2=='Saturn')||(l1=='Saturn'&&l2=='Jupiter')) return 3; const friends={'Sun':['Moon','Mars','Jupiter'],'Moon':['Sun','Mercury'],'Mars':['Sun','Moon','Jupiter'],'Mercury':['Sun','Venus'],'Jupiter':['Sun','Moon','Mars'],'Venus':['Mercury','Saturn'],'Saturn':['Mercury','Venus'],}; if(friends[l1]?.contains(l2)??false) return 5; if(friends[l2]?.contains(l1)??false) return 5; const enemies={'Sun':['Venus','Saturn'],'Moon':['Rahu'],'Mars':['Mercury'],'Mercury':['Moon'],'Jupiter':['Mercury','Venus'],'Venus':['Sun','Moon'],'Saturn':['Sun','Moon','Mars'],}; if(enemies[l1]?.contains(l2)??false) return 0; if(enemies[l2]?.contains(l1)??false) return 0; return 4;}
  static int _bhakootPts(int c){ if([2,12].contains(c)) return 0; if([5,9].contains(c)) return 0; if([6,8].contains(c)) return 0; return 7;}
  static bool _isVedha(int n1,int n2){ const pairs=[[1,18],[2,17],[3,16],[4,15],[5,14],[6,13],[7,12],[8,11],[9,10],[10,19],[11,20],[12,21],[13,22],[14,23],[15,24],[16,25],[17,26],[18,27],[19,1],[20,2],[21,3],[22,4],[23,5],[24,6],[25,7],[26,8],[27,9]]; for(var p in pairs){ if((p[0]==n1&&p[1]==n2)||(p[0]==n2&&p[1]==n1)) return true;} return false;}
  static int _houseDiff(int f,int t)=>(t-f+12)%12+1;
  static bool _hasKuja(int f,int m){ int h=_houseDiff(f,m); return [1,2,4,7,8,12].contains(h);}
  static Map<String, List<String>> _computeSynastry(Map<String,int> girlMap, Map<String,int> boyMap){
    List<String> con=[], sex=[], tri120=[], tri240=[], squ90=[], squ270=[], opp=[], inc150=[], inc210=[];
    const abbrs = ['AS','SU','MO','MA','ME','JU','VE','SA','RA','KE'];
    for(var g in abbrs){
      int gr = girlMap[g]??0; if(gr==0) continue;
      for(var b in abbrs){
        int br = boyMap[b]??0; if(br==0) continue;
        int myDiff = (br - gr + 12) % 12;
        String pair = '$g-$b';
        if(myDiff==0) con.add(pair);
        if(myDiff==2) sex.add(pair);
        if(myDiff==4) tri120.add(pair);
        if(myDiff==8) tri240.add(pair);
        if(myDiff==3) squ90.add(pair);
        if(myDiff==9) squ270.add(pair);
        if(myDiff==6) opp.add(pair);
        if(myDiff==5) inc150.add(pair);
        if(myDiff==7) inc210.add(pair);
      }
    }
    return {'con': con,'sex': sex,'tri120': tri120,'tri240': tri240,'squ90': squ90,'squ270': squ270,'opp': opp,'inc150': inc150,'inc210': inc210};
  }
  static String _formatPairLine(String label, List<String> pairs){
    if(pairs.isEmpty) return '$label (0): None';
    return '$label (${pairs.length}): ${pairs.join(", ")}';
  }
  static String _bhutaRes(String a, String b){
    if((a=='Jala'&&b=='Agni')||(a=='Agni'&&b=='Jala')) return 'No-Bad';
    return 'Yes-Good';
  }
  static bool _isEnemyBird(String a, String b){
    const enemy = {'Crow-Cock','Cock-Crow','Vulture-Crow','Crow-Vulture','Vulture-Cock','Cock-Vulture','Owl-Peacock','Peacock-Owl','Owl-Vulture','Vulture-Owl','Crow-Peacock','Peacock-Crow'};
    return enemy.contains('$a-$b');
  }
  static String _vihangaRes(String a, String b){ return _isEnemyBird(a,b) ? 'No-Bad' : 'Yes-Good'; }
  static String _panchRes(String a, String b){
    if(a==b) return 'Good 3/3';
    if(_isEnemyBird(a,b)) return 'Poor 0/3';
    if((a=='Owl'&&b=='Crow')||(a=='Crow'&&b=='Owl')) return 'Average 2/3';
    return 'Average 2/3';
  }
  static String _coreLabel(int diff){
    if(diff==0) return '7/7 Easy Con Unity & Ease';
    if(diff==2||diff==10) return '5/7 Easy Sex Support & Friendship';
    if(diff==4||diff==8) return '6/7 Easy Tri Harmony & Comfort';
    if(diff==6) return '1/7 Difficult Opp Challenge & Balance';
    if(diff==3||diff==9) return '3/7 Difficult Squ Tension & Action';
    if(diff==5||diff==7) return '1/7 Difficult Inc Service & Transformation';
    if(diff==1||diff==11) return '2/7 Difficult SSe Sacrifice & Adjustment';
    return '4/7 Mixed';
  }
  static Map<String,int> _elemCount(Map<String,int> m){
    int f=0,e=0,a=0,w=0;
    for(var r in m.values){ if(r==0) continue; String b=_rashiBhuta(r); if(b=='Agni') f++; else if(b=='Prithvi') e++; else if(b=='Vayu') a++; else if(b=='Jala') w++; }
    return {'Fire':f,'Earth':e,'Air':a,'Water':w};
  }
  static String _elemLabel(int count,int total){
    if(total==0) return 'Deficient 0%';
    double pct=count/total*100;
    if(pct<30) return 'Deficient ${pct.toStringAsFixed(0)}%';
    if(pct<=60) return 'Moderate ${pct.toStringAsFixed(0)}%';
    return 'Elevated ${pct.toStringAsFixed(0)}%';
  }
  static String _elemRate(double pct){ if(pct<30) return 'Deficient'; if(pct<=60) return 'Moderate'; return 'Elevated'; }
  static String _dominantMode(Map<String,int> m){
    int card=0, fixed=0, mut=0;
    for(var r in m.values){ if(r==0) continue; if([1,4,7,10].contains(r)) card++; else if([2,5,8,11].contains(r)) fixed++; else mut++; }
    if(fixed>=card && fixed>=mut) return 'Fixed';
    if(card>=fixed && card>=mut) return 'Cardinal';
    return 'Mutable';
  }
  static String _modeRes(String g, String b){ return g==b ? 'Average' : 'Good'; }
  static bool _isNavamsaDoshaNak(int nakNum){ return [1,9,10,18,19,27].contains(nakNum); }
  static AshtakootaCalc compute(dynamic bSnap, dynamic gSnap, Kundli brideK, Kundli groomK, {bool hideAyush = false}){
    final result = computeGunaMilan(bSnap, gSnap);
    final bMoon = bSnap.positions[Planet.moon]!; final gMoon = gSnap.positions[Planet.moon]!;
    final totalNum = result.total as num;
    final total = totalNum.toInt();
    final double totalDouble = totalNum.toDouble();
    final percent = ((totalNum/36)*100).round();
    String verdict; if(totalNum<18) verdict="Bad"; else if(totalNum<=22) verdict="Moderate"; else if(totalNum<=25) verdict="Good"; else if(totalNum<=28) verdict="Very Good"; else verdict="Excellent";
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
    final sthreeGirl=countGirlToBoy.toString(); final sthreeBoy=countBoyToGirl.toString(); final sthreeRes=int.parse(sthreeGirl)<13?'No-Bad':'Good';
    final rajjuGirl=_rajju(girlNakNum); final rajjuBoy=_rajju(boyNakNum); final rajjuRes=rajjuGirl==rajjuBoy?'Bad':'No-Good';
    final isMahendra=[4,7,10,13,16,19,22,25].contains(countGirlToBoy); final mahendraRes=isMahendra?'Yes-Good':'No-Bad';
    final bSun=_planetDeg(bSnap.positions[Planet.sun]!); final bMoonDeg=_planetDeg(bMoon); final gSun=_planetDeg(gSnap.positions[Planet.sun]!); final gMoonDeg=_planetDeg(gMoon);
    final birdGirl=_bird(girlNakNum, bSun, bMoonDeg); final birdBoy=_bird(boyNakNum, gSun, gMoonDeg);
    final nakBhutaGirl=_nakBhuta(girlNakNum); final nakBhutaBoy=_nakBhuta(boyNakNum); final rashiBhutaGirl=_rashiBhuta(girlRasiNum); final rashiBhutaBoy=_rashiBhuta(boyRasiNum);
    final sameStar=girlNakNum==boyNakNum; final samePada=sameStar&&bPada==gPada; final sameRasi=girlRasiNum==boyRasiNum;
    final sameStarPro=sameStar?'Fail':'Pass'; final samePadaRes=samePada?'Fail':'Pass'; final sameStarDiff=sameStar?(sameRasi?'Fail':'Pass'):'Pass';
    final vasyaPts=_vasyaPts(vasyaGirl, vasyaBoy); final lordGirl=_lord(girlRasiNum); final lordBoy=_lord(boyRasiNum); final maitriPts=_maitriPts(lordGirl, lordBoy); final bhakootPts=_bhakootPts(rasiCountGirlToBoy);
    final isVedha=_isVedha(girlNakNum, boyNakNum); final vedhaRes=isVedha?'Yes-Bad':'No-Good';
    final shas=rasiCountGirlToBoy==6||rasiCountGirlToBoy==8?'Yes-Bad':'No-Good'; final dwid=rasiCountGirlToBoy==2||rasiCountGirlToBoy==12?'Yes-Bad':'No-Good';
    final navap=(rasiCountGirlToBoy==5||rasiCountGirlToBoy==9)?'Yes-Bad':'No-Good'; final samas=rasiCountGirlToBoy==7?'Yes-Bad':'No-Bad';
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
    String kujaLagnaRes=(!bKujaLagna&&!gKujaLagna)?'No Dosha':(bKujaLagna&&gKujaLagna)?'Cancelled (Good)':'Not Cancelled (Bad)';
    String kujaMoonRes=(!bKujaMoon&&!gKujaMoon)?'No Dosha':(bKujaMoon&&gKujaMoon)?'Cancelled (Good)':'Not Cancelled (Bad)';
    String kujaVenusRes=(!bKujaVenus&&!gKujaVenus)?'No Dosha':(bKujaVenus&&gKujaVenus)?'Cancelled (Good)':'Not Cancelled (Bad)';
    String ayushGirl=([7,14,21].contains(countGirlToBoy))?'Dosha Present':'No Dosha'; String ayushBoy=([7,14,21].contains(countBoyToGirl))?'Dosha Present':'No Dosha'; String ayushResBase=(ayushGirl=='No Dosha'&&ayushBoy=='No Dosha')?'Good':'Dosha Present'; String ayushGirlDisp= hideAyush ? 'Not Applicable in These Charts' : ayushGirl; String ayushBoyDisp= hideAyush ? '' : ayushBoy; String ayushRes= hideAyush ? 'Not Applicable in These Charts' : ayushResBase;
    Map<String,int> girlMap = {'AS': bLagnaRasi,'SU': bSunRasi,'MO': girlRasiNum,'ME': bMercuryRasi,'VE': bVenusRasi,'MA': bMarsRasi,'JU': bJupiterRasi,'SA': bSaturnRasi,'RA': bRahuRasi,'KE': bKetuRasi};
    Map<String,int> boyMap = {'AS': gLagnaRasi,'SU': gSunRasi,'MO': boyRasiNum,'ME': gMercuryRasi,'VE': gVenusRasi,'MA': gMarsRasi,'JU': gJupiterRasi,'SA': gSaturnRasi,'RA': gRahuRasi,'KE': gKetuRasi};
    var syn = _computeSynastry(girlMap, boyMap);
    String resCon = _formatPairLine('0 Con', syn['con']!);
    String resSex = _formatPairLine('60 Sex', syn['sex']!);
    String resTri120 = _formatPairLine('120 Tri', syn['tri120']!);
    String resTri240 = _formatPairLine('240 Tri', syn['tri240']!);
    String resonantCombined = [resCon,resSex,resTri120,resTri240].join('\n');
    int resTriTotal = syn['tri120']!.length + syn['tri240']!.length;
    int resScoreWeighted = syn['con']!.length*1 + syn['sex']!.length*2 + resTriTotal*3;
    int resCount = syn['con']!.length + syn['sex']!.length + resTriTotal;
    String resonantResult = '(Con ${syn['con']!.length} + Sex ${syn['sex']!.length} + Tri $resTriTotal) | Score $resScoreWeighted';
    String disCon = _formatPairLine('0 Con', syn['con']!);
    String disSqu90 = _formatPairLine('90 Squ', syn['squ90']!);
    String disSqu270 = _formatPairLine('270 Squ', syn['squ270']!);
    String disOpp = _formatPairLine('180 Opp', syn['opp']!);
    String disInc150 = _formatPairLine('150 Inc', syn['inc150']!);
    String disInc210 = _formatPairLine('210 Inc', syn['inc210']!);
    String dissonantCombined = [disCon,disSqu90,disSqu270,disOpp,disInc150,disInc210].join('\n');
    int squTotal = syn['squ90']!.length + syn['squ270']!.length;
    int incTotal = syn['inc150']!.length + syn['inc210']!.length;
    int disTotal = syn['con']!.length + squTotal + syn['opp']!.length + incTotal;
    String dissonantResult = ' (Con ${syn['con']!.length} + Squ $squTotal + Opp ${syn['opp']!.length} + Inc $incTotal) | Score $disTotal';
    int samyogaPos = rasiCountGirlToBoy;
    const samyogaPtsTable = [7,3,3,4,7,7,7,0,7,3,3,0];
    int samyogaBase = samyogaPtsTable[samyogaPos-1];
    int rashiSamyogaPts = samyogaBase*7+1;
    String rashiSamyogaRes = rashiSamyogaPts>=35 ? 'Excellent $rashiSamyogaPts/50' : rashiSamyogaPts>=25 ? 'Good $rashiSamyogaPts/50' : rashiSamyogaPts>=15 ? 'Average $rashiSamyogaPts/50' : 'Poor $rashiSamyogaPts/50';
    int rashiDoshaD = (boyRasiNum - girlRasiNum + 12) % 12;
    double rashiDoshaScore = [5.0,0.0,4.2,3.0,1.5,0.0,4.5,0.0,1.5,1.1,4.2,0.0][rashiDoshaD];
    bool rashiDoshaLordSame = ((girlRasiNum==1||girlRasiNum==8)&&(boyRasiNum==1||boyRasiNum==8)) || ((girlRasiNum==2||girlRasiNum==7)&&(boyRasiNum==2||boyRasiNum==7)) || ((girlRasiNum==3||girlRasiNum==6)&&(boyRasiNum==3||boyRasiNum==6)) || ((girlRasiNum==9||girlRasiNum==12)&&(boyRasiNum==9||boyRasiNum==12)) || ((girlRasiNum==10||girlRasiNum==11)&&(boyRasiNum==10||boyRasiNum==11));
    bool rashiDoshaCancel = ([1,3,4,5,7,8,9,11].contains(rashiDoshaD) && rashiDoshaLordSame) || rashiDoshaScore>=3.5;
    String rashiDoshaRes = rashiDoshaCancel ? 'Cancelled (Good)\n ${rashiDoshaScore.toStringAsFixed(1)}' : 'Bad';
    const navamsaTable = [36,21,17,26,21,26,31,36,26,26,21,6];
    int navamsaPts = navamsaTable[samyogaPos-1];
    String navamsaRes = navamsaPts>=32 ? 'Excellent $navamsaPts/50' : navamsaPts>=25 ? 'Very Good $navamsaPts/50' : navamsaPts>=21 ? 'Good $navamsaPts/50' : navamsaPts>=18 ? 'Average $navamsaPts/50' : 'Poor $navamsaPts/50';
    String navGirl = _isNavamsaDoshaNak(girlNakNum) ? 'Yes' : 'No Dosha';
    String navBoy = _isNavamsaDoshaNak(boyNakNum) ? 'Yes' : 'No Dosha';
    String navamsaDoshaRes = (navGirl==navBoy) ? 'Cancelled (Good) 1.1' : 'Dosha (Bad)';
    String vihangaRes = _vihangaRes(birdGirl, birdBoy);
    String panchRes = _panchRes(birdGirl, birdBoy);
    String connectionRes = disTotal>=60 ? 'Strong ($disTotal Aspects)' : disTotal>=35 ? 'Average ($disTotal Aspects)' : disTotal>=20 ? 'Poor ($disTotal Aspects)' : 'Very Poor ($disTotal Aspects)';
    double synRatio = disTotal==0 ? resScoreWeighted.toDouble() : resScoreWeighted/disTotal;
    String synCompatRes = synRatio>=2 ? 'Excellent (${synRatio.toStringAsFixed(3)} Ratio)' : synRatio>=1.3 ? 'Average (${synRatio.toStringAsFixed(3)} Ratio)' : synRatio>=0.8 ? 'Poor (${synRatio.toStringAsFixed(3)} Ratio)' : 'Very Poor (${synRatio.toStringAsFixed(3)} Ratio)';
    var gElem = _elemCount(girlMap); var bElem = _elemCount(boyMap);
    int gTotal = 10; int bTotal = 10;
    String gFire=_elemLabel(gElem['Fire']!,gTotal); String bFire=_elemLabel(bElem['Fire']!,bTotal);
    String gEarth=_elemLabel(gElem['Earth']!,gTotal); String bEarth=_elemLabel(bElem['Earth']!,bTotal);
    String gAir=_elemLabel(gElem['Air']!,gTotal); String bAir=_elemLabel(bElem['Air']!,bTotal);
    String gWater=_elemLabel(gElem['Water']!,gTotal); String bWater=_elemLabel(bElem['Water']!,bTotal);
    double gFirePer = gElem['Fire']!/gTotal*100; double bFirePer = bElem['Fire']!/bTotal*100;
    double gEarthPer = gElem['Earth']!/gTotal*100; double bEarthPer = bElem['Earth']!/bTotal*100;
    double gAirPer = gElem['Air']!/gTotal*100; double bAirPer = bElem['Air']!/bTotal*100;
    double gWaterPer = gElem['Water']!/gTotal*100; double bWaterPer = bElem['Water']!/bTotal*100;
    bool anyDefOrElev = [_elemRate(gFirePer),_elemRate(gEarthPer),_elemRate(gAirPer),_elemRate(gWaterPer),_elemRate(bFirePer),_elemRate(bEarthPer),_elemRate(bAirPer),_elemRate(bWaterPer)].any((e)=>e=='Deficient'||e=='Elevated');
    bool anyModerate = [_elemRate(gFirePer),_elemRate(gEarthPer),_elemRate(gAirPer),_elemRate(gWaterPer),_elemRate(bFirePer),_elemRate(bEarthPer),_elemRate(bAirPer),_elemRate(bWaterPer)].any((e)=>e=='Moderate');
    String balanceRes = anyDefOrElev ? 'Poor' : anyModerate ? 'Average' : 'Good';
    String fireRes = '${_elemRate((gFirePer+bFirePer)/2)} ${gFirePer.toStringAsFixed(0)}% | ${bFirePer.toStringAsFixed(0)}%';
    String earthRes = '${_elemRate((gEarthPer+bEarthPer)/2)} ${gEarthPer.toStringAsFixed(0)}% | ${bEarthPer.toStringAsFixed(0)}%';
    String airRes = '${_elemRate((gAirPer+bAirPer)/2)} ${gAirPer.toStringAsFixed(0)}% | ${bAirPer.toStringAsFixed(0)}%';
    String waterRes = '${_elemRate((gWaterPer+bWaterPer)/2)} ${gWaterPer.toStringAsFixed(0)}% | ${bWaterPer.toStringAsFixed(0)}%';
    int elemScore = [gElem['Fire']!,bElem['Fire']!].reduce((a,b)=>a<b?a:b) + [gElem['Earth']!,bElem['Earth']!].reduce((a,b)=>a<b?a:b) + [gElem['Air']!,bElem['Air']!].reduce((a,b)=>a<b?a:b) + [gElem['Water']!,bElem['Water']!].reduce((a,b)=>a<b?a:b);
    String elemSynergyRes = elemScore>=10 ? 'Excellent' : elemScore>=7 ? 'Very Good' : elemScore>=4 ? 'Good' : elemScore>=2 ? 'Average' : 'Poor';
    String modeGirl = _dominantMode(girlMap);
    String modeBoy = _dominantMode(boyMap);
    String modeSynergyRes = _modeRes(modeGirl, modeBoy);
    int modeOverlap = 0;
    {
      int gCard=0,gFix=0,gMut=0,bCard=0,bFix=0,bMut=0;
      for(var r in girlMap.values){ if([1,4,7,10].contains(r)) gCard++; else if([2,5,8,11].contains(r)) gFix++; else if(r!=0) gMut++; }
      for(var r in boyMap.values){ if([1,4,7,10].contains(r)) bCard++; else if([2,5,8,11].contains(r)) bFix++; else if(r!=0) bMut++; }
      modeOverlap = [gCard,bCard].reduce((a,b)=>a<b?a:b) + [gFix,bFix].reduce((a,b)=>a<b?a:b) + [gMut,bMut].reduce((a,b)=>a<b?a:b);
    }
    int elemCompatTotal = (balanceRes=='Good'?3:balanceRes=='Average'?2:1)*2 + elemScore + modeOverlap;
    String elemCompatRes = elemCompatTotal>=16 ? 'Excellent' : elemCompatTotal>=15 ? 'Very Good' : elemCompatTotal>=14 ? 'Good' : elemCompatTotal>=7 ? 'Average' : 'Poor';
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
    int easyC = [diffAS,diffSU,diffMO,diffME,diffVE,diffMA,diffJU,diffSA,diffRA,diffKE].where((d)=>d==0||d==2||d==4||d==8||d==10).length;
    int diffC = 10 - easyC;
    String overallRes = '$easyC/10 Easy | 0/10 Mixed | $diffC/10 Difficult';
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
      ['2','Vasya',vasyaGirl,vasyaBoy,vasyaPts.toString(),'Attraction'],
      ['3','Tara',taraGirl,taraBoy,taraPts.toString(),'Destiny'],
      ['4','Yoni',yoniGirl,yoniBoy,'${yoniPts}','Physical'],
      ['5','Maitri',lordGirl,lordBoy,maitriPts.toString(),'Mental Harmony'],
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
      ['24','Nakshatra Bhuta',nakBhutaGirl,nakBhutaBoy,_bhutaRes(nakBhutaGirl,nakBhutaBoy),'Spirituality'],
      ['25','Rashi Bhuta',rashiBhutaGirl,rashiBhutaBoy,_bhutaRes(rashiBhutaGirl,rashiBhutaBoy),'Mind Compatibility'],
      ['26','Rashi Samyoga',rashiBhutaGirl,rashiBhutaBoy,rashiSamyogaRes,'Family Unity'],
      ['27','Rashi Dosha',bRasi,gRasi,rashiDoshaRes,'Mental Conflict'],
      ['28','Navamsa Samyoga',bRasi,gRasi,navamsaRes,'Happiness'],
      ['29','Navamsa Dosha',navGirl,navBoy,navamsaDoshaRes,'Unhappiness'],
      ['30','Panchapakshi',birdGirl,birdBoy,panchRes,'Daily Activity'],
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
    return AshtakootaCalc(total: total, totalDouble: totalDouble, percent: percent, verdict: verdict, brideName: brideK.name, groomName: groomK.name, detailed: detailed, headerRows: header, girlDOB: girlDOBStr, boyDOB: boyDOBStr, girlTOB: girlTOBStr, boyTOB: boyTOBStr, girlPOB: girlPOBStr, boyPOB: boyPOBStr, girlRasi: bRasi, boyRasi: gRasi, girlNak: bNak, boyNak: gNak);
  }
}

class AshtakootaExport {
  static TableRow headerRow(String g,String b)=> TableRow(decoration: const BoxDecoration(color: Color(0xFFE1BEE7)), children: [const Padding(padding: EdgeInsets.all(6), child: Text('No', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold))), const Padding(padding: EdgeInsets.all(6), child: Text('Item', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))), Padding(padding: const EdgeInsets.all(6), child: Text(g, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), Padding(padding: const EdgeInsets.all(6), child: Text(b, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), const Padding(padding: EdgeInsets.all(6), child: Text('Result', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))), const Padding(padding: EdgeInsets.all(6), child: Text('Description', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold))),],);
  static TableRow dataRow(String no,String item,String girl,String boy,String res,String desc)=> TableRow(children: [Padding(padding: const EdgeInsets.all(5), child: Text(no, style: const TextStyle(fontSize: 13))), Padding(padding: const EdgeInsets.all(5), child: Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))), Padding(padding: const EdgeInsets.all(5), child: Text(girl, style: const TextStyle(fontSize: 12))), Padding(padding: const EdgeInsets.all(5), child: Text(boy, style: const TextStyle(fontSize: 12))), Padding(padding: const EdgeInsets.all(5), child: Text(res, style: const TextStyle(fontSize: 12))), Padding(padding: const EdgeInsets.all(5), child: Text(desc, style: const TextStyle(fontSize: 12))),]);
  static Future<void> exportPdf(AshtakootaCalc calc) async {
    final doc = pw.Document(); final font = await pdfTheme(scriptSample: 'Ashtakoota');
    List<List<String>> fullRows=[]; fullRows.add(['AshtaKoota Guna Milan - Advanced Synastry','','','','','']); fullRows.addAll(calc.headerRows); fullRows.add(['No','Item','Girl','Boy','Result','Description']);
    bool s1=false,s2=false,s3=false,s4=false,s5=false,s6=false,s7=false;
    String totalStr = calc.totalDouble == calc.total.toDouble() ? '${calc.total}' : calc.totalDouble.toStringAsFixed(1);
    List<List<String>> rs=[['36','AshtaKoota Result',calc.verdict,'${calc.percent}%',totalStr,''],['ROUNDING OFF','','','${calc.percent}%','${calc.total}','']];
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
    doc.addPage(pw.MultiPage(theme: font, pageFormat: PdfPageFormat.a4.landscape, build: (c)=>[pw.Text('AshtaKoota Guna Milan - Advanced Synastry', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)), pw.SizedBox(height: 6), pw.TableHelper.fromTextArray(headers: ['Girl','Boy'], data: calc.headerRows.map((r) => r.sublist(2)).toList(), headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), cellStyle: pw.TextStyle(fontSize: 10)), pw.SizedBox(height: 10), pw.TableHelper.fromTextArray(headers: ['No','Item','Girl','Boy','Result','Description'], data: fullRows.sublist(8), headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), cellStyle: pw.TextStyle(fontSize: 9), columnWidths: {0: const pw.FlexColumnWidth(0.6), 1: const pw.FlexColumnWidth(2), 2: const pw.FlexColumnWidth(1.8), 3: const pw.FlexColumnWidth(1.8), 4: const pw.FlexColumnWidth(1.5), 5: const pw.FlexColumnWidth(2.2)}, cellAlignments: {0: pw.Alignment.center, 1: pw.Alignment.centerLeft, 2: pw.Alignment.topLeft, 3: pw.Alignment.topLeft, 4: pw.Alignment.topLeft, 5: pw.Alignment.topLeft}),],)); await Printing.sharePdf(bytes: await doc.save(), filename: 'ashtakoota_${calc.brideName}_x_${calc.groomName}.pdf');
  }
  static Future<void> exportCsv(AshtakootaCalc calc) async {
    final buffer=StringBuffer(); buffer.writeln('AshtaKoota Guna Milan - Advanced Synastry'); for(var hr in calc.headerRows){ String v2 = hr.length > 2 ? hr[2] : ''; String v3 = hr.length > 3 ? hr[3] : ''; if(v2.isEmpty && v3.isEmpty) continue; buffer.writeln(',,${v2},${v3}'); } buffer.writeln('No,Item,Girl,Boy,Result,Description');
    bool s1=false,s2=false,s3=false,s4=false,s5=false,s6=false,s7=false;
    String totalStr = calc.totalDouble == calc.total.toDouble() ? '${calc.total}' : calc.totalDouble.toStringAsFixed(1);
    List<List<String>> rs=[['36','AshtaKoota Result',calc.verdict,'${calc.percent}%',totalStr,''],['ROUNDING OFF','','','${calc.percent}%','${calc.total}','']];
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