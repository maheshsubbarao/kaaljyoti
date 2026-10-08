import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _h(int n) => 'H$n';
String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p){ switch(p){ case 'Ma': return [3,6,7]; case 'Ju': return [4,6,8]; case 'Sa': return [2,6,9]; case 'Ra': case 'Ke': return [4,6,8]; default: return [6]; } }
bool _asp(int f,String p,int t){ for(var o in _off(p)){ int h=f+o; while(h>12)h-=12; if(h==t) return true; } return false; }

class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'md', title: 'Dasha Technique', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);

  @override Widget cardView(BuildContext context, ModuleContext ctx) {
    final natal={'Su':12,'Mo':12,'Ma':12,'Me':12,'Ju':3,'Ve':11,'Sa':12,'Ra':3,'Ke':9};
    final lords={1:'Ju',2:'Ma',3:'Ve',4:'Me',5:'Mo',6:'Su',7:'Me',8:'Ve',9:'Ma',10:'Sa',11:'Sa',12:'Ju'};
    const moonH=12; const qH=7;
    String qLord=lords[qH]??'Me'; int qLordH=natal[qLord]??12; int karakaH=natal['Ve']??11;

    const dashaScores = {'MD':1.0,'AD':2.0,'PD':0.75,'SD':0.50,'PrD':0.25};

    final evs=[
      {'d':'07-10-2026','t':'09:15','p':'Ve','tH':8,'sg':'Li','lv':'MD','from':'','to':'Ve'},
      {'d':'16-10-2026','t':'00:00','p':'Ma','tH':10,'sg':'Cp','lv':'SD','from':'Mo','to':'Ma'},
      {'d':'16-10-2026','t':'00:00','p':'Ma','tH':4,'sg':'Ar','lv':'PD','from':'Mo','to':'Ma'},
      {'d':'16-10-2026','t':'00:00','p':'Ve','tH':4,'sg':'Li','lv':'AD','from':'','to':'Ve'},
      {'d':'31-10-2026','t':'00:00','p':'Ju','tH':5,'sg':'Cn','lv':'AD','from':'','to':'Ju'},
      {'d':'02-11-2026','t':'00:00','p':'Me','tH':8,'sg':'Li','lv':'PD','from':'','to':'Me'},
    ];

    // Build date->house map
    Map<String, Map<int, List<String>>> dateHouseHits = {};
    Map<String, Map<int, double>> dateHouseScores = {};
    for(var e in evs){
      String d='${e['d']}\n${e['t']}'; String p=e['p'] as String; int tH=e['tH'] as int; String lv=e['lv'] as String;
      List<String> tags=[];
      lords.forEach((h,lo){ if(lo==p) tags.add('$lv${_hh(h)}'); });
      if(_asp(tH,p,qH)) tags.add('$lv-07H');
      if(_asp(tH,p,qLordH)) tags.add('$lv-07L');
      if(_asp(tH,p,karakaH)) tags.add('$lv-K');
      dateHouseHits.putIfAbsent(d, ()=> {});
      dateHouseScores.putIfAbsent(d, ()=> {});
      dateHouseHits[d]!.putIfAbsent(tH, ()=> []);
      dateHouseHits[d]![tH]!.addAll(tags);
      dateHouseScores[d]![tH] = (dateHouseScores[d]![tH]??0) + (dashaScores[lv]??0);
    }

    // Controllers for sync horizontal scroll
    final ScrollController hController1 = ScrollController();
    final ScrollController hController2 = ScrollController();
    // Sync
    hController1.addListener((){ if(hController2.hasClients && hController2.offset!= hController1.offset) hController2.jumpTo(hController1.offset); });
    hController2.addListener((){ if(hController1.hasClients && hController1.offset!= hController2.offset) hController1.jumpTo(hController2.offset); });

    const double dateW = 90; const double houseW = 75;

    Widget headerCell(String txt, {bool isDate=false}) => Container(
      width: isDate? dateW : houseW, height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.orange[200], border: Border.all(color: Colors.brown, width: 0.5)),
      child: Text(txt, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDate? 11:12), textAlign: TextAlign.center),
    );

    Widget bodyCell(String date, int house){
      List<String> hits = dateHouseHits[date]?[house]?? [];
      double score = dateHouseScores[date]?[house]?? 0;
      bool isEmpty = hits.isEmpty;
      return Container(
        width: houseW, constraints: BoxConstraints(minHeight: 52),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isEmpty? Colors.white : (house==qH? Colors.yellow[100] : Colors.green[50]),
          border: Border.all(color: Colors.grey.shade400, width: 0.5),
        ),
        child: isEmpty? SizedBox() : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hits.join(','), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            if(score>0) Container(margin: EdgeInsets.only(top:2), padding: EdgeInsets.symmetric(horizontal:3, vertical:1), decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(4)), child: Text(score.toStringAsFixed(2), style: TextStyle(fontSize:8, fontWeight: FontWeight.bold, color: Colors.blue[900]))),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dasha Technique - MD=1 AD=2 PD=0.75 SD=0.5 PrD=0.25', style: TextStyle(fontWeight: FontWeight.bold, fontSize:11)),
            Text('H$qH Marriage: L=$qLord H$qLordH K=Ve H$karakaH | Yellow=H$qH', style: TextStyle(fontSize:9, color: Colors.grey[700])),
            SizedBox(height:6),
            // FROZEN HEADER - Horizontal scroll only
            SingleChildScrollView(
              controller: hController1,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  headerCell('Date', isDate:true),
                 ...List.generate(12, (i)=> headerCell('H${i+1}')),
                ],
              ),
            ),
            Divider(height:1, thickness:1),
            // BODY - Vertical scroll + horizontal scroll synced
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  controller: hController2,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: dateHouseHits.keys.map((date){
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: dateW, constraints: BoxConstraints(minHeight: 52),
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey.shade400, width:0.5)),
                            child: Text(date, style: TextStyle(fontSize:10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                         ...List.generate(12, (i)=> bodyCell(date, i+1)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height:4),
            Text('Tip: Scroll left-right to see H1-H12. Header stays on top. Yellow = Required House', style: TextStyle(fontSize:8, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('Dasha Technique')];
}

class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ad', title: 'AD (DELETED)', icon: Icons.delete, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'd9', title: 'D9 TOE', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sjmh', title: 'SJMH 9', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'aio', title: 'AIO 8', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class BNNModule extends AstroModule { const BNNModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'bnn', title: 'BNN', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sp', title: 'Sec Prog', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sa_tech', title: 'Solar Arc', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'pd_tech', title: 'Pri Dir', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ap_tech', title: 'AP 1.5', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class TNMasterModule extends AstroModule { const TNMasterModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'tn', title: 'T-N 0 Orb', icon: Icons.star, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }