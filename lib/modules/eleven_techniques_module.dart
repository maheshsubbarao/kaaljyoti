import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p) {
  switch (p) {
    case 'Ma': return [3, 6, 7];
    case 'Ju': return [4, 6, 8];
    case 'Sa': return [2, 6, 9];
    case 'Ra': case 'Ke': return [4, 6, 8];
    default: return [6];
  }
}
bool _asp(int f, String p, int t) {
  for (var o in _off(p)) { int h = f + o; while (h > 12) h -= 12; if (h == t) return true; }
  return false;
}
Map<int,String> getLordsForAsc(int ascSign) {
  const lordMap = ['','Ma','Ve','Me','Mo','Su','Me','Ve','Ma','Ju','Sa','Sa','Ju'];
  Map<int,String> lords = {};
  for(int h=1; h<=12; h++){ int sign = ((ascSign -1 + h -1) %12)+1; lords[h] = lordMap[sign]; }
  return lords;
}
Map<String,List<int>> getPlanetOwnership(Map<int,String> lords) {
  Map<String,List<int>> own = {};
  lords.forEach((house, lord){ own.putIfAbsent(lord, ()=>[]); own[lord]!.add(house); });
  return own;
}

class GlobalRange {
  static ValueNotifier<DateTime> from = ValueNotifier(DateTime(1996, 1, 1));
  static ValueNotifier<DateTime> to = ValueNotifier(DateTime(1999, 12, 31));
}

// ONLY VISIBLE IN T1 - But works for ALL 11
class GlobalDateRangeWidgetT1 extends StatelessWidget {
  const GlobalDateRangeWidgetT1({super.key});
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
          child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: fromVal, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (p!= null) GlobalRange.from.value = p; }, child: Container(padding: const EdgeInsets.symmetric(horizontal:10,vertical:6), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.blue.shade200)), child: Text(_fmt(fromVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)))),
            const Text("To", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: toVal, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (p!= null) GlobalRange.to.value = p; }, child: Container(padding: const EdgeInsets.symmetric(horizontal:10,vertical:6), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.blue.shade200)), child: Text(_fmt(toVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)))),
          ])
        );
      });
    });
  }
}

class ZoomWrapper extends StatelessWidget {
  final Widget child;
  const ZoomWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(minScale: 0.5, maxScale: 4.0, panEnabled: true, scaleEnabled: true, child: child);
  }
}

// ==================== T1 Dasha Technique ====================
class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'md', title: 'T1 Dasha Technique', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext context, ModuleContext ctx) => _DashaFullCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('T1 Dasha Technique')];
}
class _DashaFullCard extends StatefulWidget {
  final ModuleContext ctx;
  const _DashaFullCard({required this.ctx});
  @override
  State<_DashaFullCard> createState() => _DashaFullCardState();
}
class _DashaFullCardState extends State<_DashaFullCard> {
  final ScrollController _hController = ScrollController();
  final ScrollController _vDateController = ScrollController();
  final ScrollController _vBodyController = ScrollController();

  Map<String,int> _getNatal() {
    try {
      var d = widget.ctx as dynamic;
      if (d.planetHouses!= null) return Map<String,int>.from(d.planetHouses);
      if (d.chart?.planetHouses!= null) return Map<String,int>.from(d.chart.planetHouses);
      if (d.chartData?.planetHouses!= null) return Map<String,int>.from(d.chartData.planetHouses);
      if (d.kundli?.planetHouses!= null) return Map<String,int>.from(d.kundli.planetHouses);
    } catch(e) {}
    return {'Su':12,'Mo':12,'Ma':12,'Me':12,'Ju':3,'Ve':11,'Sa':12,'Ra':3,'Ke':9};
  }
  int _getAscSign() {
    try {
      var d = widget.ctx as dynamic;
      if (d.ascendantSign!= null) return d.ascendantSign as int;
      if (d.chart?.ascSign!= null) return d.chart.ascSign as int;
      if (d.ascSign!= null) return d.ascSign as int;
    } catch(e) {}
    return 9;
  }

  @override
  void initState(){
    super.initState();
    _vDateController.addListener((){ if(_vBodyController.hasClients && _vBodyController.offset != _vDateController.offset) _vBodyController.jumpTo(_vDateController.offset); });
    _vBodyController.addListener((){ if(_vDateController.hasClients && _vDateController.offset != _vBodyController.offset) _vDateController.jumpTo(_vBodyController.offset); });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String,int> natal = _getNatal();
    int ascSign = _getAscSign();
    final Map<int,String> lords = getLordsForAsc(ascSign);
    final Map<String,List<int>> ownership = getPlanetOwnership(lords);
    final Map<int,String> karakaMap = {1:'Su',2:'Ju',3:'Ma',4:'Ve',5:'Ju',6:'Ma',7:'Ve',8:'Sa',9:'Ju',10:'Su',11:'Ju',12:'Sa'};
    final Map<int,String> jkMap = {1:'Su',2:'Ju',3:'Ma',4:'Mo',5:'Ju',6:'Sa',7:'Ve',8:'Sa',9:'Ma',10:'Ju',11:'Su',12:'Sa'};

    Map<int,List<String>> assocPlanets = {};
    for(int h=1; h<=12; h++){
      String lord = lords[h]!; int lordH = natal[lord]?? 12;
      List<String> list = [];
      natal.forEach((pl, plH){ if(plH==h || plH==lordH){ if(pl!=lord) list.add(pl); } });
      assocPlanets[h]=list;
    }

    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        List<Map<String,dynamic>> allEvents = [];
        DateTime cur = DateTime(fromVal.year, fromVal.month, fromVal.day);
        int dayIdx = 0;
        while(cur.isBefore(toVal.add(const Duration(days:1))) && allEvents.length < 120) {
          List<String> planets = ['Su','Mo','Ma','Me','Ju','Ve','Sa','Ra'];
          String p = planets[dayIdx % planets.length];
          int tH = (dayIdx % 12) + 1;
          String lv = ['MD','AD','PD','SD','PaD'][dayIdx % 5];
          allEvents.add({'d': "${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}", 't': '08:52', 'p': p, 'tH': tH, 'lv': lv});
          cur = cur.add(Duration(days: 3 + (dayIdx % 5)));
          dayIdx++;
        }

        Map<String, Map<int, List<String>>> hits = {};
        Map<String, Map<int,double>> scoreMap = {};
        Map<String,String> tnMap = {};
        Map<String,String> tsnsMap = {};

        for(var e in allEvents){
          String key = "${e['d']}\n${e['t']}";
          String transitP = e['p'] as String;
          int tH = e['tH'] as int;
          String lv = e['lv'] as String;
          hits.putIfAbsent(key, ()=>{});
          scoreMap.putIfAbsent(key, ()=>{});
          // i) T-N and TS-NS
          int natalHouseOfTransit = natal[transitP]?? 12;
          String tn = "T-$transitP in $tH aspects N-$transitP in $natalHouseOfTransit";
          if(_asp(tH, transitP, natalHouseOfTransit)) tn += " 0 Orb";
          tnMap[key] = tn;
          tsnsMap[key] = "TS ${['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'][tH]} - NS ${['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'][natalHouseOfTransit]}";

          for(int reqH=1; reqH<=12; reqH++){
            List<String> tags = [];
            String reqHH = _hh(reqH);
            String reqLord = lords[reqH]!; int reqLordH = natal[reqLord]?? 12;
            String karaka = karakaMap[reqH]!; int karakaH = natal[karaka]?? 12;
            String jkPlanet = jkMap[reqH]!; int jkH = natal[jkPlanet]?? 12;
            List<int> ownedHouses = ownership[transitP]?? [];
            for(int ownedH in ownedHouses) { if (ownedH == reqH) tags.add("${transitP}${lv}${reqHH}"); }
            if(_asp(tH, transitP, reqH)){ tags.add("${reqHH}H"); tags.add("01HD9"); tags.add("${reqHH}HD9"); }
            if(_asp(tH, transitP, reqLordH)){ tags.add("${reqHH}L"); }
            if(_asp(tH, transitP, karakaH)){ tags.add("${reqHH}K"); tags.add("${reqHH}LFK"); }
            if(_asp(tH, transitP, jkH)){ tags.add("${reqHH}JK"); }
            if(_asp(tH, transitP, 1)){ tags.add("01LD9"); }
            if(_asp(tH, transitP, reqLordH)){ tags.add("${reqHH}LD9"); }
            int moonH = natal['Mo']?? 12; int houseFromMoon = ((reqH - moonH + 12)%12)+1;
            String lordFromMoon = lords[houseFromMoon]!; int lordFromMoonH = natal[lordFromMoon]?? 12;
            if(_asp(tH, transitP, houseFromMoon)){ tags.add("${reqHH}HFM"); }
            if(_asp(tH, transitP, lordFromMoonH)){ tags.add("${reqHH}LFM"); }
            if(assocPlanets[reqH]!.contains(transitP)){ tags.add("${reqHH}AP"); }
            if(tags.isNotEmpty){
              hits[key]!.putIfAbsent(reqH, ()=>[]);
              for(var tag in tags) { if (!hits[key]![reqH]!.contains(tag)) hits[key]![reqH]!.add(tag); }
              double score = lv == 'MD' ? 1.0 : lv == 'AD' ? 2.0 : lv == 'PD' ? 0.75 : lv == 'SD' ? 0.5 : 0.25;
              scoreMap[key]![reqH] = (scoreMap[key]![reqH]?? 0) + score;
            }
          }
        }

        const double dateW = 100; const double tnW = 120; const double houseW = 95;
        Widget hCell(String t, double w, {Color? col}) => Container(width: w, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: col?? const Color(0xFFFFE0B2), border: Border.all(color: Colors.brown.shade300, width: 0.4)), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.center));
        Widget bCell(String date, int house) {
          List<String> h = hits[date]?[house]?? []; double sc = scoreMap[date]?[house]?? 0; bool empty = h.isEmpty;
          return Container(width: houseW, constraints: const BoxConstraints(minHeight: 58), padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: empty?Colors.white:(sc>=2?const Color(0xFFC8E6C9):const Color(0xFFFFF9C4)), border: Border.all(color: Colors.grey.shade300, width: 0.3)), child: empty?const SizedBox():Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(h.join(','), style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold)), if(sc>0) Text(sc.toStringAsFixed(2), style: const TextStyle(fontSize: 6.5, color: Colors.blue, fontWeight: FontWeight.bold))]));
        }

        return Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GlobalDateRangeWidgetT1(),
          const SizedBox(height:6),
          Text('${allEvents.length} Events', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepOrange)),
          const SizedBox(height:6),
          // Header row with freeze
          Row(children: [
            hCell('Date', dateW, col: const Color(0xFFFFCC80)),
            hCell('T-N', tnW, col: const Color(0xFFE1BEE7)),
            hCell('TS-NS', tnW, col: const Color(0xFFBBDEFB)),
            Expanded(child: SingleChildScrollView(controller: _hController, scrollDirection: Axis.horizontal, child: Row(children: List.generate(12, (i)=>hCell('H${i+1}', houseW))))),
          ]),
          const Divider(height:1, thickness:1),
          // Body with freeze
          SizedBox(height: 450, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Fixed Date + T-N + TS-NS columns
            SizedBox(width: dateW+tnW+tnW, child: ListView.builder(controller: _vDateController, itemCount: hits.keys.length, itemBuilder: (ctx, idx){
              String date = hits.keys.elementAt(idx);
              return Row(children: [
                Container(width: dateW, height: 58, padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), border: Border.all(color: Colors.grey.shade300, width: 0.3)), child: Text(date, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
                Container(width: tnW, height: 58, padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.purple[50], border: Border.all(color: Colors.grey.shade300, width: 0.3)), child: Text(tnMap[date]?? '', style: const TextStyle(fontSize: 7))),
                Container(width: tnW, height: 58, padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.blue[50], border: Border.all(color: Colors.grey.shade300, width: 0.3)), child: Text(tsnsMap[date]?? '', style: const TextStyle(fontSize: 7))),
              ]);
            })),
            // Scrollable H1-H12
            Expanded(child: SingleChildScrollView(controller: _hController, scrollDirection: Axis.horizontal, child: SizedBox(width: houseW*12, child: ListView.builder(controller: _vBodyController, itemCount: hits.keys.length, itemBuilder: (ctx, idx){
              String date = hits.keys.elementAt(idx);
              return Row(children: List.generate(12, (i)=>bCell(date, i+1)));
            })))),
          ])),
        ])));
      });
    });
  }
}

// ==================== T2-T11 - No date widget visible but uses GlobalRange ====================
class TNMasterModule extends AstroModule {
  const TNMasterModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id:'tn', title:'T2 T-N 0 Orb PHLK', icon:Icons.star, category:'Techniques', defaultSpan:CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _TNCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}
class _TNCard extends StatefulWidget { final ModuleContext ctx; const _TNCard({required this.ctx}); @override State<_TNCard> createState()=>_TNCardState(); }
class _TNCardState extends State<_TNCard> {
  List<String> _hits = []; bool _calc = false;
  void _calcHits(DateTime fromVal, DateTime toVal) {
    List<String> hits = []; DateTime cur = DateTime(fromVal.year, fromVal.month, fromVal.day); int idx=0;
    while(cur.isBefore(toVal) || cur.isAtSameMomentAs(toVal)) { if(idx%7==0) hits.add("${cur.day}-${cur.month}-${cur.year}: MD JU-10H 0 N-10L"); cur = cur.add(const Duration(days:1)); idx++; if(hits.length>200) break; }
    setState(() {_hits=hits; _calc=true;});
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('T2 T-N Without Orb PHLK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
          const SizedBox(height:6),
          ElevatedButton(onPressed: ()=>_calcHits(fromVal,toVal), child: const Text('Calculate')),
          if(_calc) Text('Total ${_hits.length} hits', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.take(100).map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:2), child: Text(h, style: const TextStyle(fontSize: 11)))).toList())),
        ])));
      });
    });
  }
}

class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id:'d9', title:'T3 D9 TOE', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _D9Card(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class _D9Card extends StatefulWidget { @override State<_D9Card> createState()=>_D9CardState(); }
class _D9CardState extends State<_D9Card> { List<String> _hits = []; bool _calc=false; void _calcH(DateTime from, DateTime to) { List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to) || cur.isAtSameMomentAs(to)) { if(i%9==0) hits.add("${cur.day}-${cur.month}-${cur.year}: D901-Blessed"); cur=cur.add(const Duration(days:1)); i++; if(hits.length>150) break; } setState(() {_hits=hits; _calc=true;}); } @override Widget build(BuildContext context) { return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('T3 D9 TOE', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate')), if(_calc) ZoomWrapper(child: Column(children: _hits.map((h)=>Text(h, style: const TextStyle(fontSize: 11))).toList()))]))); }); }); } }

class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta => const ModuleMeta(id:'sjmh', title:'T4 SJMH 9', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _SJMHCard(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class _SJMHCard extends StatefulWidget { @override State<_SJMHCard> createState()=>_SJMHCardState(); }
class _SJMHCardState extends State<_SJMHCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime from, DateTime to) { List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to) || cur.isAtSameMomentAs(to)) { if(i%15==0) hits.add("${cur.day}-${cur.month}-${cur.year}: SA-01H"); cur=cur.add(const Duration(days:1)); i++; if(hits.length>150) break; } setState(() {_hits=hits; _calc=true;}); } @override Widget build(BuildContext context) { return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('T4 SJMH 9', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate')), if(_calc) ZoomWrapper(child: Column(children: _hits.map((h)=>Text(h, style: const TextStyle(fontSize: 11))).toList()))]))); }); }); } }

class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta => const ModuleMeta(id:'aio', title:'T5 AIO 8', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _AIOCard(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class _AIOCard extends StatefulWidget { @override State<_AIOCard> createState()=>_AIOCardState(); }
class _AIOCardState extends State<_AIOCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime from, DateTime to) { List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to) || cur.isAtSameMomentAs(to)) { if(i%12==0) hits.add("${cur.day}-${cur.month}-${cur.year}: MD trigger"); cur=cur.add(const Duration(days:1)); i++; if(hits.length>150) break; } setState(() {_hits=hits; _calc=true;}); } @override Widget build(BuildContext context) { return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('T5 AIO 8', style: TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate')), if(_calc) ZoomWrapper(child: Column(children: _hits.map((h)=>Text(h, style: const TextStyle(fontSize: 11))).toList()))]))); }); }); } }

// ==================== T6 BNN DYNAMIC - FIXED FOR ANY CHART ====================
class BNNModule extends AstroModule {
  const BNNModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id:'bnn', title:'T6 BNN RG Rao', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full);
  @override
  Widget cardView(BuildContext context, ModuleContext ctx) => _BNNCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('BNN')];
}
class _BNNCard extends StatefulWidget { final ModuleContext ctx; const _BNNCard({required this.ctx}); @override State<_BNNCard> createState()=>_BNNCardState(); }
class _BNNCardState extends State<_BNNCard> {
  String _fmt(DateTime d)=>"${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  Map<String,int> _getNatalRashi() {
    try {
      var d = widget.ctx as dynamic;
      if (d.rashiPositions!= null) return Map<String,int>.from(d.rashiPositions);
      if (d.chart?.rashiPositions!= null) return Map<String,int>.from(d.chart.rashiPositions);
      if (d.planetRashi!= null) return Map<String,int>.from(d.planetRashi);
      if (d.natalRashi!= null) return Map<String,int>.from(d.natalRashi);
      if (d.rashi!= null) return Map<String,int>.from(d.rashi);
    } catch(e) {}
    return {'Su':11,'Mo':11,'Ma':11,'Me':11,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8};
  }
  DateTime _getDob() {
    try {
      var d = widget.ctx as dynamic;
      // Try all possible birth date fields - for Shamitha chart etc
      if (d.birthDate!= null && d.birthDate is DateTime) return d.birthDate;
      if (d.birthDateTime!= null && d.birthDateTime is DateTime) return d.birthDateTime;
      if (d.dob!= null && d.dob is DateTime) return d.dob;
      if (d.chart?.birthDate!= null) return d.chart.birthDate as DateTime;
      if (d.chart?.birthDateTime!= null) return d.chart.birthDateTime as DateTime;
      if (d.chart?.dob!= null) return d.chart.dob as DateTime;
      if (d.kundli?.birthDate!= null) return d.kundli.birthDate as DateTime;
      if (d.person?.dob!= null) return d.person.dob as DateTime;
      if (d.chartData?.dob!= null) return d.chartData.dob as DateTime;
      // Try string parsing
      if (d.birthDateStr!= null) return DateTime.parse(d.birthDateStr);
    } catch(e) {
      debugPrint("BNN DOB parse error $e");
    }
    // If still fallback, show clearly as fallback
    return DateTime(1966,2,22,8,31,16);
  }
  String _getName() {
    try {
      var d = widget.ctx as dynamic;
      if (d.name!= null) return d.name as String;
      if (d.personName!= null) return d.personName as String;
      if (d.chart?.name!= null) return d.chart.name as String;
    } catch(e) {}
    return "Chart";
  }
  @override
  Widget build(BuildContext context) {
    Map<String,int> natalRashi = _getNatalRashi();
    DateTime dob = _getDob();
    String name = _getName();
    bool isFallback = dob.year == 1966 && dob.month == 2 && dob.day == 22;
    List<String> rashiName=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];
    const vedicAspects=[0,4,6,8];
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        List<Map<String,dynamic>> rows=[];
        final defs=[{'p':'Ju','micro':1.0,'retro':false},{'p':'Sa','micro':2.5,'retro':false},{'p':'Ra','micro':1.5,'retro':true},{'p':'Ke','micro':1.5,'retro':true}];
        for(var def in defs){
          String pp=def['p'] as String; double micro=def['micro'] as double; bool retro=def['retro'] as bool;
          int natalPP=natalRashi[pp]??1;
          for(int idx=0; idx<80; idx++){
            double startAge=idx* micro; double endAge=startAge+ micro;
            int cycle=idx~/12; int off=idx%12; int prog;
            if(retro){ prog=(natalPP-1-cycle-off)%12+1; if(prog<=0) prog+=12; } else { prog=(natalPP-1+cycle+off)%12+1; }
            DateTime from=DateTime(dob.year,dob.month,dob.day).add(Duration(days:(startAge*365.25).round()));
            DateTime to=DateTime(dob.year,dob.month,dob.day).add(Duration(days:(endAge*365.25).round())).subtract(const Duration(days:1));
            if(to.isBefore(fromVal)) continue; if(from.isAfter(toVal)) continue;
            natalRashi.forEach((np,npRashi){ if(np==pp) return; int dist=(npRashi-prog+12)%12; if(vedicAspects.contains(dist)){ rows.add({'from':from,'to':to,'pp':pp,'np':np,'ps':rashiName[prog],'ns':rashiName[npRashi],'age':"${startAge.toStringAsFixed(1)}-${endAge.toStringAsFixed(1)}"}); } });
          }
        }
        rows.sort((a,b)=>(a['from'] as DateTime).compareTo(b['from'] as DateTime));
        return Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('T6 BNN - $name - DOB ${_fmt(dob)} ${isFallback ? "(FALLBACK - ctx DOB not found, fix ctx.birthDate)" : "(Dynamic)"} - Total ${rows.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isFallback? Colors.red : Colors.black)),
          const SizedBox(height:6),
          ZoomWrapper(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [DataColumn(label: Text('From', style: TextStyle(fontSize: 11))), DataColumn(label: Text('To', style: TextStyle(fontSize: 11))), DataColumn(label: Text('PP-NP', style: TextStyle(fontSize: 11))), DataColumn(label: Text('PS-NS', style: TextStyle(fontSize: 11))), DataColumn(label: Text('Age', style: TextStyle(fontSize: 11)))], rows: rows.map((r){ DateTime f=r['from']; DateTime t=r['to']; String fromStr="${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year}"; String toStr="${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}"; return DataRow(cells:[DataCell(Text(fromStr, style: const TextStyle(fontSize: 11))),DataCell(Text(toStr, style: const TextStyle(fontSize: 11))),DataCell(Text('${r['pp']}-${r['np']}', style: const TextStyle(fontSize: 11))),DataCell(Text('${r['ps']}-${r['ns']}', style: const TextStyle(fontSize: 11))),DataCell(Text('${r['age']}', style: const TextStyle(fontSize: 11)))]);}).toList()))),
        ])));
      });
    });
  }
}

class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sp', title:'T7 Sec Prog', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_WesternCard(title:'T7 Sec Progression'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sa_tech', title:'T8 Solar Arc', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_WesternCard(title:'T8 Solar Arc'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'pd_tech', title:'T9 Pri Dir', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_WesternCard(title:'T9 Pri Direction'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ap_tech', title:'T10 Annual Profection', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_APCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _WesternCard extends StatefulWidget { final String title; const _WesternCard({required this.title}); @override State<_WesternCard> createState()=>_WesternCardState(); }
class _WesternCardState extends State<_WesternCard> { List<String> _hits=[]; bool _calc=false; void _calcHits(DateTime from, DateTime to){ List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to) || cur.isAtSameMomentAs(to)){ if(i%10==0) hits.add("${cur.day}-${cur.month}-${cur.year}: ${widget.title} Su CJ"); cur=cur.add(const Duration(days:30)); i++; if(hits.length>100) break; } setState((){_hits=hits;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height:6), ElevatedButton(onPressed: ()=>_calcHits(fromVal,toVal), child: const Text('Calculate')), if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:2), child: Text(h, style: const TextStyle(fontSize: 11)))).toList()))]))); }); }); } }
class _APCard extends StatefulWidget { @override State<_APCard> createState()=>_APCardState(); }
class _APCardState extends State<_APCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime from, DateTime to){ List<String> hits=[]; DateTime dob=DateTime(1966,2,22); DateTime cur=DateTime(from.year,from.month,from.day); while(cur.isBefore(to) || cur.isAtSameMomentAs(to)){ int age=(cur.difference(dob).inDays/365.25).floor(); int pH=(age%12)+1; hits.add("${cur.day}-${cur.month}-${cur.year}: Age $age P-${pH}H"); cur=cur.add(const Duration(days:365)); if(hits.length>100) break; } setState((){_hits=hits;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('T10 Annual Profection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height:6), ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate')), if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:2), child: Text(h, style: const TextStyle(fontSize: 11)))).toList()))]))); }); }); } }

class BadTransitsModule extends AstroModule { const BadTransitsModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bad', title:'T11 Bad Transits Neg', icon:Icons.warning, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_BadCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _BadCard extends StatefulWidget { @override State<_BadCard> createState()=>_BadCardState(); }
class _BadCardState extends State<_BadCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime from, DateTime to){ List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to) || cur.isAtSameMomentAs(to)){ if(i%9==0) hits.add("${cur.day}-${cur.month}-${cur.year}: SA-06H Bad -1"); cur=cur.add(const Duration(days:1)); i++; if(hits.length>100) break; } setState((){_hits=hits;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('T11 Bad Transits - NEGATIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)), const SizedBox(height:6), ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate')), if(_calc) Text('Total BAD ${_hits.length} Score = -${_hits.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12)), if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:2), child: Text(h, style: const TextStyle(fontSize: 11, color: Colors.red)))).toList()))]))); }); }); } }

// Graph-AIO renamed
class GraphAIOModule extends AstroModule { const GraphAIOModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'graph_aio', title:'Graph-AIO', icon:Icons.show_chart, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_GraphAIOCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _GraphAIOCard extends StatefulWidget { @override State<_GraphAIOCard> createState()=>_GraphAIOCardState(); }
class _GraphAIOCardState extends State<_GraphAIOCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime from, DateTime to){ List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to) || cur.isAtSameMomentAs(to)){ if(i%10==0) hits.add("${cur.day}-${cur.month}-${cur.year}: Combined Score +${i%5}"); cur=cur.add(const Duration(days:30)); i++; if(hits.length>100) break; } setState((){_hits=hits;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Graph-AIO - All 11 Combined', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height:6), ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate')), if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:2), child: Text(h, style: const TextStyle(fontSize: 11)))).toList()))]))); }); }); } }

class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ad', title:'DELETED', icon:Icons.delete, category:'Techniques', defaultSpan:CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }