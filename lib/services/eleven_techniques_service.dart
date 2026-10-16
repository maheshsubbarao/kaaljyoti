import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p) {
  switch (p.toUpperCase()) {
    case 'MA': return [3, 6, 7];
    case 'JU': return [4, 6, 8];
    case 'SA': return [2, 6, 9];
    case 'RA': case 'KE': return [4, 6, 8];
    default: return [6];
  }
}
bool _asp(int f, String p, int t) {
  for (var o in _off(p)) { int h = f + o; while (h > 12) h -= 12; if (h == t) return true; }
  return false;
}

class GlobalRange {
  static ValueNotifier<DateTime> from = ValueNotifier(DateTime(1996, 7, 1));
  static ValueNotifier<DateTime> to = ValueNotifier(DateTime(1996, 10, 31));
}
class GlobalDateRangeWidget extends StatelessWidget {
  const GlobalDateRangeWidget({super.key});
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange[50], border: Border.all(color: Colors.orange, width: 1.5), borderRadius: BorderRadius.circular(8)),
          child: Wrap(spacing: 12, children: [
            const Text("From:", style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: fromVal, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (p!=null) GlobalRange.from.value = p; }, child: Text(_fmt(fromVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14))),
            const Text("To:", style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: toVal, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (p!=null) GlobalRange.to.value = p; }, child: Text(_fmt(toVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14))),
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
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 1)),
      child: InteractiveViewer(
        minScale: 0.3,
        maxScale: 5.0,
        boundaryMargin: const EdgeInsets.all(20),
        panEnabled: true,
        scaleEnabled: true,
        child: child,
      ),
    );
  }
}

class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'md', title: 'T1 Dasha Technique', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext context, ModuleContext ctx) => _DashaTechniqueCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('T1 Dasha Technique')];
}

class _DashaTechniqueCard extends StatefulWidget {
  final ModuleContext ctx;
  const _DashaTechniqueCard({required this.ctx});
  @override
  State<_DashaTechniqueCard> createState() => _DashaTechniqueCardState();
}

class _DashaTechniqueCardState extends State<_DashaTechniqueCard> {
  final ScrollController _hCtrl = ScrollController();
  @override
  void dispose() { _hCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final Map<String,int> natalPos = {'SU':12,'MO':12,'MA':12,'ME':12,'JU':3,'VE':11,'SA':12,'RA':3,'KE':9};
    final Map<int,String> houseLord = {1:'JU',2:'MA',3:'VE',4:'ME',5:'MO',6:'SU',7:'ME',8:'VE',9:'MA',10:'SA',11:'SA',12:'JU'};
    final Map<int,String> karaka = {1:'SU',2:'JU',3:'MA',4:'VE',5:'JU',6:'MA',7:'VE',8:'SA',9:'JU',10:'SU',11:'JU',12:'SA'};
    final Map<int,String> jk = {1:'JU',2:'MO',3:'MA',4:'SA',5:'ME',6:'SU',7:'VE',8:'SU',9:'MA',10:'MO',11:'JU',12:'SU'};
    final Map<int,String> houseSign = {1:'Pi',2:'Ar',3:'Ta',4:'Ge',5:'Cn',6:'Le',7:'Vi',8:'Li',9:'Sc',10:'Sg',11:'Cp',12:'Aq'};
    final Map<int,String> housePos = {1:'H3',2:'H12',3:'H11',4:'H12',5:'H12',6:'H12',7:'H12',8:'H11',9:'H12',10:'H3',11:'H12',12:'H12'};
    Map<int, List<String>> assoc = {};
    for(int h=1; h<=12; h++){
      String lord = houseLord[h]!;
      int lordH = natalPos[lord]??12;
      List<String> list=[];
      natalPos.forEach((pl, plH){ if((plH==h || plH==lordH) && pl!=lord) list.add(pl); });
      assoc[h]=list;
    }
    final Map<String,String> dashaRunning = {'MD':'ME','AD':'VE','PD':'JU','SD':'MA','PrD':'SA'};
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        List<Map<String,dynamic>> rows = [];
        DateTime cur = DateTime(fromVal.year, fromVal.month, fromVal.day);
        int dayIdx=0;
        while((cur.isBefore(toVal) || cur.isAtSameMomentAs(toVal)) && rows.length < 200) {
          dashaRunning.forEach((level, tPlanet){
            int tHouse = ((natalPos[tPlanet]! -1 + (dayIdx ~/ 8)) %12)+1;
            for(int reqH=1; reqH<=12; reqH++){
              String lord = houseLord[reqH]!; int lordH = natalPos[lord]!;
              String kPlanet = karaka[reqH]!; int kH = natalPos[kPlanet]!;
              String jkPlanet = jk[reqH]!; int jkH = natalPos[jkPlanet]!;
              int moonHouse = natalPos['MO']!; int houseFromMoon = ((reqH - moonHouse +12)%12)+1; String lordFromMoon = houseLord[houseFromMoon]!; int lordFromMoonH = natalPos[lordFromMoon]!;
              List<String> tags=[];
              List<int> owned = [];
              houseLord.forEach((hNo, l){ if(l==tPlanet) owned.add(hNo); });
              if(owned.contains(reqH)){
                tags.add("${tPlanet}${level}${_hh(reqH)}");
              }
              if(_asp(tHouse, tPlanet, reqH)){ tags.add("${_hh(reqH)}H"); tags.add("${_hh(reqH)}HD9"); tags.add("01HD9"); }
              if(_asp(tHouse, tPlanet, lordH)){ tags.add("${_hh(reqH)}L"); tags.add("${_hh(reqH)}LD9"); tags.add("01LD9"); }
              if(_asp(tHouse, tPlanet, kH)){ tags.add("${_hh(reqH)}K"); tags.add("${_hh(reqH)}LFK"); }
              if(_asp(tHouse, tPlanet, jkH)){ tags.add("${_hh(reqH)}JK"); }
              if(_asp(tHouse, tPlanet, houseFromMoon)){ tags.add("${_hh(reqH)}HFM"); }
              if(_asp(tHouse, tPlanet, lordFromMoonH)){ tags.add("${_hh(reqH)}LFM"); }
              if(assoc[reqH]!.contains(tPlanet)){ tags.add("${_hh(reqH)}AP"); }
              if(tags.isNotEmpty){
                String tnStr = "$tPlanet-$lord";
                String tsnsStr = "${houseSign[tHouse]}-${houseSign[reqH]}";
                rows.add({ 'dateStr': "${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}", 'tn': tnStr, 'tsns': tsnsStr, 'reqH': reqH, 'tags': tags.toSet().toList(), });
              }
            }
          });
          cur = cur.add(const Duration(days: 1)); dayIdx++;
        }
        Map<String, Map<int, List<String>>> grouped = {};
        Map<String, Map<String,String>> metaInfo = {};
        for(var r in rows){
          String d = r['dateStr']; int reqH = r['reqH'];
          grouped.putIfAbsent(d, ()=>{}); grouped[d]!.putIfAbsent(reqH, ()=>[]); grouped[d]![reqH]!.addAll(r['tags']);
          metaInfo.putIfAbsent(d, ()=>{'tn': r['tn'], 'tsns': r['tsns']});
        }
        const double dateW=110, tnW=80, tsnsW=80, houseW=95;
        Widget headerCell(String txt, double w, Color col) => Container(width:w, padding:const EdgeInsets.symmetric(vertical:8, horizontal:2), decoration:BoxDecoration(color:col, border:Border.all(color:Colors.brown, width:0.7)), alignment:Alignment.center, child:Text(txt, style:const TextStyle(fontWeight:FontWeight.bold, fontSize:11), textAlign:TextAlign.center));
        Widget dataCell(String txt, double w, Color col) => Container(width:w, padding:const EdgeInsets.all(4), decoration:BoxDecoration(color:col, border:Border.all(color:Colors.grey.shade400, width:0.5)), child:Text(txt, style:const TextStyle(fontSize:10, fontWeight:FontWeight.bold)));
        return Card(child: Padding(padding:const EdgeInsets.all(6), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          const GlobalDateRangeWidget(),
          const SizedBox(height:8),
          Text("Total ${rows.length} dynamic Transit->Natal hits", style:const TextStyle(fontWeight:FontWeight.bold, fontSize:11, color:Colors.green)),
          const SizedBox(height:6),
          ZoomWrapper(
            child: Scrollbar(controller: _hCtrl, thumbVisibility:true, child: SingleChildScrollView(controller: _hCtrl, scrollDirection: Axis.horizontal, child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
              Row(children:[ headerCell('HS', dateW, Colors.orange[100]!), headerCell('', tnW, Colors.orange[100]!), headerCell('', tsnsW, Colors.orange[100]!),...List.generate(12, (i)=>headerCell(houseSign[i+1]!, houseW, Colors.yellow[100]!)) ]),
              Row(children:[ headerCell('HL', dateW, Colors.orange[100]!), headerCell('', tnW, Colors.orange[100]!), headerCell('', tsnsW, Colors.orange[100]!),...List.generate(12, (i)=>headerCell(houseLord[i+1]!, houseW, Colors.yellow[100]!)) ]),
              Row(children:[ headerCell('K', dateW, Colors.orange[100]!), headerCell('', tnW, Colors.orange[100]!), headerCell('', tsnsW, Colors.orange[100]!),...List.generate(12, (i)=>headerCell(karaka[i+1]!, houseW, Colors.yellow[100]!)) ]),
              Row(children:[ headerCell('JK', dateW, Colors.orange[100]!), headerCell('', tnW, Colors.orange[100]!), headerCell('', tsnsW, Colors.orange[100]!),...List.generate(12, (i)=>headerCell(jk[i+1]!, houseW, Colors.yellow[100]!)) ]),
              Row(children:[ headerCell('HP', dateW, Colors.orange[100]!), headerCell('', tnW, Colors.orange[100]!), headerCell('', tsnsW, Colors.orange[100]!),...List.generate(12, (i)=>headerCell(housePos[i+1]!, houseW, Colors.yellow[100]!)) ]),
              const Divider(height:2, thickness:1.5),
              Row(children:[ headerCell('Date', dateW, Colors.deepOrange[200]!), headerCell('T-N', tnW, Colors.deepOrange[200]!), headerCell('TS-NS', tsnsW, Colors.deepOrange[200]!),...List.generate(12, (i)=>headerCell('${i+1}', houseW, Colors.deepOrange[200]!)) ]),
             ...grouped.keys.take(80).map((dateStr){
                var m = metaInfo[dateStr]!;
                return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children:[
                  dataCell(dateStr, dateW, Colors.grey[100]!),
                  dataCell(m['tn']!, tnW, Colors.grey[100]!),
                  dataCell(m['tsns']!, tsnsW, Colors.grey[100]!),
                 ...List.generate(12, (i){
                    int hNo=i+1; var tags = grouped[dateStr]?[hNo]?? [];
                    if(tags.isEmpty) return Container(width:houseW, decoration:BoxDecoration(color:Colors.white, border:Border.all(color:Colors.grey.shade300, width:0.5)));
                    return Container(width:houseW, padding:const EdgeInsets.all(3), decoration:BoxDecoration(color:Colors.green[50], border:Border.all(color:Colors.grey.shade400, width:0.5)), child:Text(tags.join('\n'), style:const TextStyle(fontSize:9, fontWeight:FontWeight.bold)));
                  }),
                ]));
              }).toList(),
            ])))),
        ])));
      });
    });
  }
}

class TNMasterModule extends AstroModule { const TNMasterModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'tn', title:'T2 T-N 0 Orb PHLK', icon:Icons.star, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T2 Use full file'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'d9', title:'T3 D9 TOE', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T3'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sjmh', title:'T4 SJMH 9', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T4'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'aio', title:'T5 AIO 8', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T5'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class BNNModule extends AstroModule { const BNNModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bnn', title:'T6 BNN RG Rao', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext context, ModuleContext ctx)=>const Text('T6'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[pw.Text('BNN')]; }
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sp', title:'T7 Sec Prog', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T7'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sa_tech', title:'T8 Solar Arc', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T8'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'pd_tech', title:'T9 Pri Dir', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T9'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ap_tech', title:'T10 Annual Profection', icon:Icons.auto_awesome, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T10'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class BadTransitsModule extends AstroModule { const BadTransitsModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bad', title:'T11 Bad Transits Neg', icon:Icons.warning, category:'Techniques', defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const Text('T11'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ad', title:'DELETED', icon:Icons.delete, category:'Techniques', defaultSpan:CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx)=>const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }