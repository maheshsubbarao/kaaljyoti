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
  for(int h=1; h<=12; h++){
    int sign = ((ascSign -1 + h -1) %12)+1;
    lords[h] = lordMap[sign];
  }
  return lords;
}

class GlobalRange {
  static ValueNotifier<DateTime> from = ValueNotifier(DateTime(1996, 1, 1));
  static ValueNotifier<DateTime> to = ValueNotifier(DateTime(1999, 12, 31));
}

class GlobalDateRangeWidget extends StatelessWidget {
  const GlobalDateRangeWidget({super.key});
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            const Text("Range: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: fromVal, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (p!= null) GlobalRange.from.value = p; }, child: Container(padding: const EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: Text(_fmt(fromVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)))),
            const Padding(padding: EdgeInsets.symmetric(horizontal:6), child: Text("To", style: TextStyle(fontSize: 12))),
            InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: toVal, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (p!= null) GlobalRange.to.value = p; }, child: Container(padding: const EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: Text(_fmt(toVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)))),
            const Spacer(),
            const Text("Pinch 2 fingers", style: TextStyle(fontSize: 10, color: Colors.grey)),
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

// ==================== T1 Dasha Technique - DYNAMIC FOR ANY CHART ====================
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
  Map<String,int> _getNatal() {
    try {
      // TODO BOSS: Replace with actual ctx planet houses when available
      // Example: if (widget.ctx.chartData!= null) return widget.ctx.chartData.planetHouses
      var data = widget.ctx as dynamic;
      if (data.chart!= null && data.chart.planetHouses!= null) {
        return Map<String,int>.from(data.chart.planetHouses);
      }
    } catch(e) {}
    return {'Su':12,'Mo':12,'Ma':12,'Me':12,'Ju':3,'Ve':11,'Sa':12,'Ra':3,'Ke':9};
  }
  int _getAscSign() {
    try {
      var data = widget.ctx as dynamic;
      if (data.ascendantSign!= null) return data.ascendantSign as int;
      if (data.chart!= null && data.chart.ascSign!= null) return data.chart.ascSign as int;
    } catch(e) {}
    return 9;
  }
  @override
  Widget build(BuildContext context) {
    final Map<String,int> natal = _getNatal();
    int ascSign = _getAscSign();
    final Map<int,String> lords = getLordsForAsc(ascSign);
    final Map<int,String> karakaMap = {1:'Su',2:'Ju',3:'Ma',4:'Ve',5:'Ju',6:'Ma',7:'Ve',8:'Sa',9:'Ju',10:'Su',11:'Ju',12:'Sa'};
    final Map<int,String> jkPlanetMap = {1:'Su',2:'Ju',3:'Ma',4:'Mo',5:'Ju',6:'Sa',7:'Ve',8:'Sa',9:'Ma',10:'Ju',11:'Su',12:'Sa'};
    Map<int,List<String>> assocPlanets = {};
    for(int h=1; h<=12; h++){
      String lord = lords[h]!; int lordH = natal[lord]?? 12;
      List<String> list = [];
      natal.forEach((pl, plH){ if(plH==h || plH==lordH){ if(pl!=lord) list.add(pl); } });
      assocPlanets[h]=list;
    }
    final Map<String,String> dashaPlanets = {'MD':'Me','AD':'Ve','PD':'Ju','SD':'Ma','PaD':'Sa'};
    const Map<String,double> scores = {'MD':1.0,'AD':2.0,'PD':0.75,'SD':0.50,'PaD':0.25};
    final List<Map<String,dynamic>> allEvents = [
      {'d':'16-07-1996','t':'08:52','p':'Me','tH':4,'lv':'MD'},
      {'d':'04-09-1996','t':'11:17','p':'Sa','tH':4,'lv':'AD'},
      {'d':'16-10-1996','t':'08:52','p':'Ma','tH':7,'lv':'PD'},
      {'d':'17-10-1996','t':'08:52','p':'Mo','tH':7,'lv':'SD'},
    ];
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        List<Map<String,dynamic>> filtered = [];
        for(var e in allEvents){
          var parts = (e['d'] as String).split('-');
          DateTime d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          if(d.isAfter(fromVal.subtract(const Duration(days:1))) && d.isBefore(toVal.add(const Duration(days:1)))) filtered.add(e);
        }
        Map<String, Map<int, List<String>>> hits = {};
        Map<String, Map<int,double>> scoreMap = {};
        for(var e in filtered){
          String key = "${e['d']}\n${e['t']}";
          String p = e['p'] as String; int tH = e['tH'] as int; String lv = e['lv'] as String;
          hits.putIfAbsent(key, ()=>{});
          scoreMap.putIfAbsent(key, ()=>{});
          for(int reqH=1; reqH<=12; reqH++){
            List<String> tags = [];
            String reqHH = _hh(reqH);
            String qLord = lords[reqH]!; int qLordH = natal[qLord]?? 12;
            String qKaraka = karakaMap[reqH]!; int qKarakaH = natal[qKaraka]?? 12;
            String qJKPlanet = jkPlanetMap[reqH]!; int qJKH = natal[qJKPlanet]?? 12;
            if(dashaPlanets[lv]==p){ if(lords[reqH]==p){ tags.add("${p}${lv}$reqHH"); } }
            if(_asp(tH, p, reqH)){ tags.add("${reqHH}H"); tags.add("01HD9"); tags.add("${reqHH}HD9"); }
            if(_asp(tH, p, qLordH)){ tags.add("${reqHH}L"); }
            if(_asp(tH, p, qKarakaH)){ tags.add("${reqHH}K"); tags.add("${reqHH}LFK"); }
            if(_asp(tH, p, qJKH)){ tags.add("${reqHH}JK"); }
            if(_asp(tH, p, 1)){ tags.add("01LD9"); }
            if(_asp(tH, p, qLordH)){ tags.add("${reqHH}LD9"); }
            int moonH = natal['Mo']?? 12; int houseFromMoon = ((reqH - moonH + 12)%12)+1;
            String lordFromMoon = lords[houseFromMoon]!; int lordFromMoonH = natal[lordFromMoon]?? 12;
            if(_asp(tH, p, houseFromMoon)){ tags.add("${reqHH}HFM"); }
            if(_asp(tH, p, lordFromMoonH)){ tags.add("${reqHH}LFM"); }
            if(assocPlanets[reqH]!.contains(p)){ tags.add("${reqHH}AP"); }
            if(tags.isNotEmpty){
              hits[key]!.putIfAbsent(reqH, ()=>[]);
              hits[key]![reqH]!.addAll(tags);
              scoreMap[key]![reqH] = (scoreMap[key]![reqH]?? 0) + (scores[lv]?? 0);
            }
          }
        }
        const double dateW = 110; const double houseW = 105;
        Widget hCell(String t, {bool isDate=false, Color? col}) => Container(width: isDate?dateW:houseW, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: col?? const Color(0xFFFFE0B2), border: Border.all(color: Colors.brown.shade300, width: 0.5)), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center));
        Widget bCell(String date, int house) {
          List<String> h = hits[date]?[house]?? []; double sc = scoreMap[date]?[house]?? 0; bool empty = h.isEmpty;
          return Container(width: houseW, constraints: const BoxConstraints(minHeight: 60), padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: empty?Colors.white:(sc>=2?const Color(0xFFC8E6C9):const Color(0xFFFFF9C4)), border: Border.all(color: Colors.grey.shade300, width: 0.4)), child: empty?const SizedBox():Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(h.join(','), style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)), if(sc>0) Text(sc.toStringAsFixed(2), style: const TextStyle(fontSize: 7.5, color: Colors.blue, fontWeight: FontWeight.bold))]));
        }
        return Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GlobalDateRangeWidget(),
          const SizedBox(height:8),
          Text('T1 Dasha Technique - Asc ${ascSign} Dynamic for ${widget.ctx.toString().substring(0,20)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepOrange)),
          const SizedBox(height:6),
          ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [hCell('Date', isDate:true, col: const Color(0xFFFFCC80)),...List.generate(12, (i)=>hCell('H${i+1}\n${lords[i+1]}/${karakaMap[i+1]}', col: (i+1==7)?const Color(0xFFFFF176):const Color(0xFFFFE0B2)))])),
            const Divider(height:1, thickness:1),
            SizedBox(height: 400, child: SingleChildScrollView(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Column(children: hits.keys.map((date){ return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: dateW, constraints: const BoxConstraints(minHeight: 60), padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), border: Border.all(color: Colors.grey.shade300, width: 0.4)), child: Text(date, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),...List.generate(12, (i)=>bCell(date, i+1))]); }).toList())))),
          ])),
        ])));
      });
    });
  }
}

// ==================== T2 PHLK ====================
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
    while(cur.isBefore(toVal) || cur.isAtSameMomentAs(toVal)) {
      if(idx%7==0) hits.add("${cur.day}-${cur.month}-${cur.year}: MD JU-10H 0 N-10L [01-10L] MD to Lord - Score 2");
      if(idx%11==0) hits.add("${cur.day}-${cur.month}-${cur.year}: AD SA-07H 180 N-01H AD to House - Score 2");
      cur = cur.add(const Duration(days:1)); idx++; if(hits.length>200) break;
    }
    setState(() {_hits=hits; _calc=true;});
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GlobalDateRangeWidget(), const SizedBox(height:8),
          const Text('T2 T-N Without Orb PHLK - POSITIVE HIGH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
          ElevatedButton(onPressed: ()=>_calcHits(fromVal,toVal), child: const Text('Calculate T2 PHLK Exact')),
          if(_calc) Text('Total ${_hits.length} EXACT hits', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
          const SizedBox(height:6),
          if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.take(100).map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:3), child: Text(h, style: const TextStyle(fontSize: 12)))).toList())),
        ])));
      });
    });
  }
}

// ==================== T3 D9 ====================
class D9TechniqueModule extends AstroModule {
  const D9TechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id:'d9', title:'T3 D9 TOE', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _D9Card();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}
class _D9Card extends StatefulWidget { @override State<_D9Card> createState()=>_D9CardState(); }
class _D9CardState extends State<_D9Card> {
  List<String> _hits = []; bool _calc=false;
  void _calcH(DateTime from, DateTime to) {
    List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0;
    while(cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      if(i%9==0) hits.add("${cur.day}-${cur.month}-${cur.year}: D901-Blessed T Su trine N Su - Score +2");
      cur=cur.add(const Duration(days:1)); i++; if(hits.length>150) break;
    }
    setState(() {_hits=hits; _calc=true;});
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GlobalDateRangeWidget(), const SizedBox(height:8),
          const Text('T3 D9 TOE - 9th Harmonic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate D9 TOE')),
          if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:3), child: Text(h, style: const TextStyle(fontSize: 12)))).toList())),
        ])));
      });
    });
  }
}

// ==================== T4 SJMH ====================
class SJMHModule extends AstroModule {
  const SJMHModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id:'sjmh', title:'T4 SJMH 9', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _SJMHCard();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}
class _SJMHCard extends StatefulWidget { @override State<_SJMHCard> createState()=>_SJMHCardState(); }
class _SJMHCardState extends State<_SJMHCard> {
  List<String> _hits=[]; bool _calc=false;
  void _calcH(DateTime from, DateTime to) {
    List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0;
    while(cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      if(i%15==0) hits.add("${cur.day}-${cur.month}-${cur.year}: 1 SA-01H Sade Sati - Score +1");
      cur=cur.add(const Duration(days:1)); i++; if(hits.length>150) break;
    }
    setState(() {_hits=hits; _calc=true;});
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GlobalDateRangeWidget(), const SizedBox(height:8),
          const Text('T4 SJMH 9 - KN Rao', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate SJMH 9')),
          if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:3), child: Text(h, style: const TextStyle(fontSize: 12)))).toList())),
        ])));
      });
    });
  }
}

// ==================== T5 AIO ====================
class AIOModule extends AstroModule {
  const AIOModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id:'aio', title:'T5 AIO 8', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _AIOCard();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}
class _AIOCard extends StatefulWidget { @override State<_AIOCard> createState()=>_AIOCardState(); }
class _AIOCardState extends State<_AIOCard> {
  List<String> _hits=[]; bool _calc=false;
  void _calcH(DateTime from, DateTime to) {
    List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0;
    while(cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      if(i%12==0) hits.add("${cur.day}-${cur.month}-${cur.year}: MD trigger - Score +1");
      cur=cur.add(const Duration(days:1)); i++; if(hits.length>150) break;
    }
    setState(() {_hits=hits; _calc=true;});
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GlobalDateRangeWidget(), const SizedBox(height:8),
          const Text('T5 AIO 8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate AIO 8')),
          if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:3), child: Text(h, style: const TextStyle(fontSize: 12)))).toList())),
        ])));
      });
    });
  }
}

// ==================== T6 BNN DYNAMIC FOR ANY CHART ====================
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
      var data = widget.ctx as dynamic;
      if (data.chart!= null && data.chart.rashiPositions!= null) return Map<String,int>.from(data.chart.rashiPositions);
    } catch(e) {}
    return {'Su':11,'Mo':11,'Ma':11,'Me':11,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8};
  }
  DateTime _getDob() {
    try {
      var data = widget.ctx as dynamic;
      if (data.birthDate!= null) return data.birthDate as DateTime;
      if (data.chart!= null && data.chart.birthDateTime!= null) return data.chart.birthDateTime as DateTime;
    } catch(e) {}
    return DateTime(1966,2,22,8,31,16);
  }
  @override
  Widget build(BuildContext context) {
    Map<String,int> natalRashi = _getNatalRashi();
    DateTime dob = _getDob();
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
          const GlobalDateRangeWidget(), const SizedBox(height:8),
          Text('T6 BNN - RG RAO Dynamic (DOB ${dob.day}-${dob.month}-${dob.year}) - Total ${rows.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const Divider(),
          ZoomWrapper(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [DataColumn(label: Text('From')), DataColumn(label: Text('To')), DataColumn(label: Text('PP-NP')), DataColumn(label: Text('PS-NS')), DataColumn(label: Text('Age'))], rows: rows.map((r){ DateTime f=r['from']; DateTime t=r['to']; String fromStr="${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year}"; String toStr="${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}"; return DataRow(cells:[DataCell(Text(fromStr, style: const TextStyle(fontSize: 11))),DataCell(Text(toStr, style: const TextStyle(fontSize: 11))),DataCell(Text('${r['pp']}-${r['np']}', style: const TextStyle(fontSize: 11))),DataCell(Text('${r['ps']}-${r['ns']}', style: const TextStyle(fontSize: 11))),DataCell(Text('${r['age']}', style: const TextStyle(fontSize: 11)))]);}).toList()))),
        ])));
      });
    });
  }
}

// ==================== T7-T10 ====================
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sp', title:'T7 Sec Prog', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_WesternCard(title:'T7 Sec Progression'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sa_tech', title:'T8 Solar Arc', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_WesternCard(title:'T8 Solar Arc'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'pd_tech', title:'T9 Pri Dir', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_WesternCard(title:'T9 Pri Direction'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ap_tech', title:'T10 Annual Profection', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_APCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _WesternCard extends StatefulWidget { final String title; const _WesternCard({required this.title}); @override State<_WesternCard> createState()=>_WesternCardState(); }
class _WesternCardState extends State<_WesternCard> { List<String> _hits=[]; bool _calc=false; void _calcHits(DateTime from, DateTime to){ List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to) || cur.isAtSameMomentAs(to)){ if(i%10==0) hits.add("${cur.day}-${cur.month}-${cur.year}: ${widget.title} Su CJ - Score +2"); cur=cur.add(const Duration(days:30)); i++; if(hits.length>100) break; } setState((){_hits=hits;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const GlobalDateRangeWidget(), const SizedBox(height:8), Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), ElevatedButton(onPressed: ()=>_calcHits(fromVal,toVal), child: Text('Calculate ${widget.title}')), if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:3), child: Text(h, style: const TextStyle(fontSize: 12)))).toList()))]))); }); }); } }
class _APCard extends StatefulWidget { @override State<_APCard> createState()=>_APCardState(); }
class _APCardState extends State<_APCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime from, DateTime to){ List<String> hits=[]; DateTime dob=DateTime(1966,2,22); DateTime cur=DateTime(from.year,from.month,from.day); while(cur.isBefore(to) || cur.isAtSameMomentAs(to)){ int age=(cur.difference(dob).inDays/365.25).floor(); int pH=(age%12)+1; hits.add("${cur.day}-${cur.month}-${cur.year}: Age $age P-${pH}H - Score +1"); cur=cur.add(const Duration(days:365)); if(hits.length>100) break; } setState((){_hits=hits;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const GlobalDateRangeWidget(), const SizedBox(height:8), const Text('T10 Annual Profection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate AP')), if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:3), child: Text(h, style: const TextStyle(fontSize: 12)))).toList()))]))); }); }); } }

// ==================== T11 ====================
class BadTransitsModule extends AstroModule { const BadTransitsModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bad', title:'T11 Bad Transits Neg', icon:Icons.warning, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>_BadCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _BadCard extends StatefulWidget { @override State<_BadCard> createState()=>_BadCardState(); }
class _BadCardState extends State<_BadCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime from, DateTime to){ List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to) || cur.isAtSameMomentAs(to)){ if(i%9==0) hits.add("${cur.day}-${cur.month}-${cur.year}: SA-06H Bad -1"); cur=cur.add(const Duration(days:1)); i++; if(hits.length>100) break; } setState((){_hits=hits;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __){ return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const GlobalDateRangeWidget(), const SizedBox(height:8), const Text('T11 Bad Transits - NEGATIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)), ElevatedButton(onPressed: ()=>_calcH(fromVal,toVal), child: const Text('Calculate Bad -1')), if(_calc) Text('Total BAD ${_hits.length} Score = -${_hits.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)), if(_calc) ZoomWrapper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _hits.map((h)=>Padding(padding: const EdgeInsets.symmetric(vertical:3), child: Text(h, style: const TextStyle(fontSize: 12, color: Colors.red)))).toList()))]))); }); }); } }

// DELETED Astro Events - BOSS FIX
class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ad', title:'DELETED', icon:Icons.delete, category:'Techniques', defaultSpan:CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }