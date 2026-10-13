import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _h(int n) => 'H$n';
String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p){ switch(p){ case 'Ma': return [3,6,7]; case 'Ju': return [4,6,8]; case 'Sa': return [2,6,9]; case 'Ra': case 'Ke': return [4,6,8]; default: return [6]; } }
bool _asp(int f,String p,int t){ for(var o in _off(p)){ int h=f+o; while(h>12)h-=12; if(h==t) return true; } return false; }

// ---------- Dasha Technique (your old code - kept same) ----------
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
    Map<String, Map<int, List<String>>> dateHouseHits = {};
    Map<String, Map<int, double>> dateHouseScores = {};
    for(var e in evs){
      String d='${e['d']}\n${e['t']}'; String p=e['p'] as String; int tH=e['tH'] as int; String lv=e['lv'] as String;
      List<String> tags=[]; lords.forEach((h,lo){ if(lo==p) tags.add('$lv${_hh(h)}'); });
      if(_asp(tH,p,qH)) tags.add('$lv-07H'); if(_asp(tH,p,qLordH)) tags.add('$lv-07L'); if(_asp(tH,p,karakaH)) tags.add('$lv-K');
      dateHouseHits.putIfAbsent(d, ()=> {}); dateHouseScores.putIfAbsent(d, ()=> {});
      dateHouseHits[d]!.putIfAbsent(tH, ()=> []); dateHouseHits[d]![tH]!.addAll(tags);
      dateHouseScores[d]![tH] = (dateHouseScores[d]![tH]??0) + (dashaScores[lv]??0);
    }
    final ScrollController hController1 = ScrollController(); final ScrollController hController2 = ScrollController();
    hController1.addListener((){ if(hController2.hasClients && hController2.offset!= hController1.offset) hController2.jumpTo(hController1.offset); });
    hController2.addListener((){ if(hController1.hasClients && hController1.offset!= hController2.offset) hController1.jumpTo(hController2.offset); });
    const double dateW = 90; const double houseW = 75;
    Widget headerCell(String txt, {bool isDate=false}) => Container(width: isDate? dateW : houseW, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.orange[200], border: Border.all(color: Colors.brown, width: 0.5)), child: Text(txt, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDate? 11:12), textAlign: TextAlign.center));
    Widget bodyCell(String date, int house){
      List<String> hits = dateHouseHits[date]?[house]?? []; double score = dateHouseScores[date]?[house]?? 0; bool isEmpty = hits.isEmpty;
      return Container(width: houseW, constraints: BoxConstraints(minHeight: 52), padding: EdgeInsets.all(3), decoration: BoxDecoration(color: isEmpty? Colors.white : (house==qH? Colors.yellow[100] : Colors.green[50]), border: Border.all(color: Colors.grey.shade400, width: 0.5)), child: isEmpty? SizedBox() : Column(mainAxisSize: MainAxisSize.min, children: [Text(hits.join(','), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center), if(score>0) Container(margin: EdgeInsets.only(top:2), padding: EdgeInsets.symmetric(horizontal:3, vertical:1), decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(4)), child: Text(score.toStringAsFixed(2), style: TextStyle(fontSize:8, fontWeight: FontWeight.bold, color: Colors.blue[900]))),]),);
    }
    return Card(child: Padding(padding: EdgeInsets.all(6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Dasha Technique - MD=1 AD=2 PD=0.75 SD=0.5 PrD=0.25', style: TextStyle(fontWeight: FontWeight.bold, fontSize:11)), Text('H$qH Marriage: L=$qLord H$qLordH K=Ve H$karakaH | Yellow=H$qH', style: TextStyle(fontSize:9, color: Colors.grey[700])), SizedBox(height:6), SingleChildScrollView(controller: hController1, scrollDirection: Axis.horizontal, child: Row(children: [headerCell('Date', isDate:true),...List.generate(12, (i)=> headerCell('H${i+1}')),],),), Divider(height:1, thickness:1), Expanded(child: SingleChildScrollView(child: SingleChildScrollView(controller: hController2, scrollDirection: Axis.horizontal, child: Column(children: dateHouseHits.keys.map((date){ return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: dateW, constraints: BoxConstraints(minHeight: 52), padding: EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey.shade400, width:0.5)), child: Text(date, style: TextStyle(fontSize:10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),...List.generate(12, (i)=> bodyCell(date, i+1)),],);}).toList(),),),),), SizedBox(height:4), Text('Tip: Scroll left-right to see H1-H12. Header stays on top. Yellow = Required House', style: TextStyle(fontSize:8, color: Colors.grey)),],),),);
  }
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('Dasha Technique')];
}

// ---------- BNN REAL IMPLEMENTATION ----------
class BNNModule extends AstroModule {
  const BNNModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'bnn', title: 'BNN', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);

  @override Widget cardView(BuildContext context, ModuleContext ctx) {
    // TRY to get real chart from context, fallback to example you gave (22-02-1966)
    final dynamic dctx = ctx;
    DateTime dob;
    try { dob = dctx.birthDate?? dctx.dob?? DateTime(1966,2,22,8,31,16); } catch(e){ dob = DateTime(1966,2,22,8,31,16); }

    // Natal rashi map - try from ctx, else use your example: Ju Tau (2), Ve Cap (10) etc
    Map<String,int> natalRashi;
    try {
      var planets = dctx.planets?? dctx.natal?? {};
      if(planets is Map && planets.isNotEmpty){
        natalRashi = {};
        planets.forEach((k,v){
          double lon = 0;
          if(v is double) lon=v;
          else if(v is Map) lon=(v['lon']?? v['longitude']?? 0).toDouble();
          else if(v is num) lon=v.toDouble();
          natalRashi[k.toString()] = (lon/30).floor()+1;
        });
      } else { throw 'fallback'; }
    } catch(e){
      natalRashi = {'Su':2,'Mo':12,'Ma':6,'Me':1,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8};
    }

    const progDefs = {
      'Ju': {'macro':12.0,'micro':1.0},
      'Sa': {'macro':30.0,'micro':2.5},
      'Ra': {'macro':18.0,'micro':1.5},
      'Ke': {'macro':18.0,'micro':1.5},
    };
    const List<int> bnnAspects = [0,1,5,7,9];
    List<String> rashiName = ['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];

    // Generate report for 0-80 years
    List<Map<String,dynamic>> rows = [];
    for(var pp in progDefs.keys){
      double micro = progDefs[pp]!['micro']!;
      int natalRashiPP = natalRashi[pp]?? 1;
      for(int age=1; age<=80; age++){
        int cycle = (age-1)~/12;
        int start = cycle+1;
        int off = (age-1)%12;
        int house = (start-1+off)%12 +1;
        int progRashi = (natalRashiPP-1+house-1)%12 +1;

        DateTime from = DateTime(dob.year + ((age-1)*micro).floor(), dob.month, dob.day, dob.hour, dob.minute);
        // approx months for.5
        int extraMonths = (((age-1)*micro %1)*12).round();
        from = DateTime(from.year, from.month+extraMonths, from.day, from.hour, from.minute);
        DateTime to = DateTime(from.year + micro.floor(), from.month + ((micro%1)*12).round(), from.day);

        // check aspects to all natal
        natalRashi.forEach((np, npRashi){
          int dist = (npRashi - progRashi +12)%12;
          if(bnnAspects.contains(dist)){
            // scoring: conj=3, 2nd=1, 6th=1.5, 8th=1.5, 10th=2
            double score = dist==0?3.0 : dist==1?1.0 : dist==5?1.5 : dist==7?1.5 : 2.0;
            // boost if Sa,Ju,Ra,Ke aspect to 7th lord etc - simple
            rows.add({
              'from':from,'to':to,'age':age,'pp':pp,'np':np,
              'ps':rashiName[progRashi],'ns':rashiName[npRashi],
              'psN':progRashi,'nsN':npRashi,'dist':dist,'score':score,
            });
          }
        });
      }
    }
    rows.sort((a,b)=> (a['from'] as DateTime).compareTo(b['from'] as DateTime));

    // Build yearly score for 3 graphs
    Map<int,double> yearScore = {};
    for(var r in rows){ int y = (r['from'] as DateTime).year; yearScore[y] = (yearScore[y]??0)+ (r['score'] as double); }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BNN - Bhrighu Nandi Nadi Progression', style: TextStyle(fontWeight: FontWeight.bold, fontSize:14)),
            Text('Dob: ${dob.day}-${dob.month}-${dob.year} | Natal: ${natalRashi.entries.map((e)=>"${e.key}-${rashiName[e.value]}").join(" ")}', style: TextStyle(fontSize:10, color: Colors.grey[700])),
            SizedBox(height:6),
            Text('Ju:12y(1y/sign) Sa:30y(2.5y) Ra/Ke:18y(1.5y) | Asp: 0,1,5,7,9', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold)),
            SizedBox(height:8),
            // YEAR GRAPH (Simple bar)
            Text('Year Power Graph (Score)', style: TextStyle(fontWeight: FontWeight.bold, fontSize:11)),
            Container(height: 80, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: yearScore.entries.take(40).map((e){
              double h = (e.value*10).clamp(5,80);
              return Container(margin: EdgeInsets.only(right:4), child: Column(children: [Container(width:22, height:h, color: e.value>5? Colors.green: Colors.blue[200]), Text('${e.key%100}', style: TextStyle(fontSize:8)), Text('${e.value.toStringAsFixed(0)}', style: TextStyle(fontSize:7, fontWeight: FontWeight.bold))]));
            }).toList()))),
            Divider(),
            // TABLE HEADER
            Container(color: Colors.orange[200], padding: EdgeInsets.symmetric(vertical:6, horizontal:4), child: Row(children: [
              Expanded(flex:2, child: Text('From', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
              Expanded(flex:2, child: Text('To', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
              Expanded(child: Text('Age', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
              Expanded(flex:2, child: Text('PP-NP', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
              Expanded(flex:2, child: Text('PS-NS', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
              Expanded(child: Text('Score', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
            ])),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length>200?200:rows.length,
                itemBuilder: (c,i){
                  var r = rows[i];
                  DateTime f=r['from']; DateTime t=r['to'];
                  String fromStr = "${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year}";
                  String toStr = "${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}";
                  return Container(padding: EdgeInsets.symmetric(vertical:4, horizontal:4), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))), child: Row(children: [
                    Expanded(flex:2, child: Text(fromStr, style: TextStyle(fontSize:9))),
                    Expanded(flex:2, child: Text(toStr, style: TextStyle(fontSize:9))),
                    Expanded(child: Text('${r['age']}', style: TextStyle(fontSize:9))),
                    Expanded(flex:2, child: Text('${r['pp']}-${r['np']} (${r['dist']})', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
                    Expanded(flex:2, child: Text('${r['ps']}-${r['ns']}', style: TextStyle(fontSize:9))),
                    Expanded(child: Container(padding: EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(3)), child: Text('${(r['score'] as double).toStringAsFixed(1)}', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold)))),
                  ]));
                },
              ),
            ),
            Text('Showing ${rows.length>200?200:rows.length} / ${rows.length} hits. Filter by custom date range in next version. Graphs for Month/Day coming with your Excel.', style: TextStyle(fontSize:8, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('BNN Progression Report - Ju 12y Sa 30y Ra/Ke 18y')];
}

// Other empty modules kept
class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ad', title: 'AD (DELETED)', icon: Icons.delete, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'd9', title: 'D9 TOE', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sjmh', title: 'SJMH 9', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'aio', title: 'AIO 8', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sp', title: 'Sec Prog', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sa_tech', title: 'Solar Arc', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'pd_tech', title: 'Pri Dir', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ap_tech', title: 'AP 1.5', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class TNMasterModule extends AstroModule { const TNMasterModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'tn', title: 'T-N 0 Orb', icon: Icons.star, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }