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
    const qH=7;
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
    const double dateW = 90; const double houseW = 75;
    Widget headerCell(String txt, {bool isDate=false}) => Container(width: isDate? dateW : houseW, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.orange[200], border: Border.all(color: Colors.brown, width: 0.5)), child: Text(txt, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDate? 11:12), textAlign: TextAlign.center));
    Widget bodyCell(String date, int house){
      List<String> hits = dateHouseHits[date]?[house]?? []; double score = dateHouseScores[date]?[house]?? 0; bool isEmpty = hits.isEmpty;
      return Container(width: houseW, constraints: BoxConstraints(minHeight: 52), padding: EdgeInsets.all(3), decoration: BoxDecoration(color: isEmpty? Colors.white : (house==qH? Colors.yellow[100] : Colors.green[50]), border: Border.all(color: Colors.grey.shade400, width: 0.5)), child: isEmpty? SizedBox() : Column(mainAxisSize: MainAxisSize.min, children: [Text(hits.join(','), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center), if(score>0) Container(margin: EdgeInsets.only(top:2), padding: EdgeInsets.symmetric(horizontal:3, vertical:1), decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(4)), child: Text(score.toStringAsFixed(2), style: TextStyle(fontSize:8, fontWeight: FontWeight.bold, color: Colors.blue[900]))),]),);
    }
    return Card(child: Padding(padding: EdgeInsets.all(6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Dasha Technique', style: TextStyle(fontWeight: FontWeight.bold, fontSize:11)), SizedBox(height:6), SingleChildScrollView(controller: hController1, scrollDirection: Axis.horizontal, child: Row(children: [headerCell('Date', isDate:true),...List.generate(12, (i)=> headerCell('H${i+1}')),],),), Divider(height:1, thickness:1), SizedBox(height: 300, child: SingleChildScrollView(child: SingleChildScrollView(controller: hController2, scrollDirection: Axis.horizontal, child: Column(children: dateHouseHits.keys.map((date){ return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: dateW, constraints: BoxConstraints(minHeight: 52), padding: EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey.shade400, width:0.5)), child: Text(date, style: TextStyle(fontSize:10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),...List.generate(12, (i)=> bodyCell(date, i+1)),],);}).toList(),),),),),],),),);
  }
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('Dasha Technique')];
}

class BNNModule extends AstroModule {
  const BNNModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'bnn', title: 'BNN', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override Widget cardView(BuildContext context, ModuleContext ctx) => _BNNCard(ctx: ctx);
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('BNN')];
}

class _BNNCard extends StatefulWidget {
  final ModuleContext ctx;
  const _BNNCard({required this.ctx});
  @override State<_BNNCard> createState() => _BNNCardState();
}

class _BNNCardState extends State<_BNNCard> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _fromDate = null; // MANDATORY - No default from DOB
    _toDate = null;
  }

  @override
  Widget build(BuildContext context) {
    final dynamic dctx = widget.ctx;
    DateTime dob;
    try { dob = dctx.birthDate?? dctx.dob?? DateTime(1966,2,22,8,31,16); } catch(e){ dob = DateTime(1966,2,22,8,31,16); }
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
      'Ju': {'micro':1.0},
      'Sa': {'micro':2.5},
      'Ra': {'micro':1.5, 'retro': true},
      'Ke': {'micro':1.5, 'retro': true},
    };
    const List<int> bnnAspects = [0,1,4,6,8];
    List<String> rashiName = ['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];

    List<Map<String,dynamic>> rows = [];
    bool hasRange = _fromDate!=null && _toDate!=null;

    if(hasRange){
      for(var pp in progDefs.keys){
        double micro = progDefs[pp]!['micro'] as double;
        bool retro = (progDefs[pp]!['retro'] as bool?)?? false;
        int natalRashiPP = natalRashi[pp]?? 1;
        for(int age=1; age<=80; age++){
          int cycle = (age-1)~/12;
          int start = cycle+1;
          int off = (age-1)%12;
          int house = (start-1+off)%12 +1;
          int progRashi;
          if(retro){
            progRashi = (natalRashiPP-1 - (house-1)) % 12 +1;
          } else {
            progRashi = (natalRashiPP-1+house-1)%12 +1;
          }
          double yearsToAdd = (age-1)*micro;
          DateTime from = DateTime(dob.year + yearsToAdd.floor(), dob.month, dob.day).add(Duration(days: ((yearsToAdd %1)*365).round()));
          DateTime to = DateTime(from.year + micro.floor(), from.month + ((micro%1)*12).round(), from.day);
          if(to.isBefore(_fromDate!)) continue;
          if(from.isAfter(_toDate!)) continue;
          natalRashi.forEach((np, npRashi){
            if(np == pp) return;
            int dist = (npRashi - progRashi +12)%12;
            if(bnnAspects.contains(dist)){
              rows.add({'from':from,'to':to,'age':age,'pp':pp,'np':np,'ps':rashiName[progRashi],'ns':rashiName[npRashi],'psN':progRashi,'nsN':npRashi,'dist':dist,'house': house,});
            }
          });
        }
      }
      rows.sort((a,b)=> (a['from'] as DateTime).compareTo(b['from'] as DateTime));
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BNN - Bhrighu Nandi Nadi', style: TextStyle(fontWeight: FontWeight.bold, fontSize:14)),
            Text('Dob: ${dob.day}-${dob.month}-${dob.year} | Natal: ${natalRashi.entries.map((e)=>"${e.key}-${rashiName[e.value]}").join(" ")}', style: TextStyle(fontSize:10, color: Colors.grey[700])),
            SizedBox(height:4),
            Text('Ju:12y(1y) Sa:30y(2.5y) Ra/Ke:18y(1.5y) Anti-Clock | Asp: 1,2,5,7,9', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold, color: Colors.brown)),
            SizedBox(height:10),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.yellow[50], border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELECT CUSTOM DATE RANGE (Mandatory)', style: TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: Colors.red[800])),
                  SizedBox(height:6),
                  Row(children: [
                    Expanded(child: ElevatedButton.icon(
                      icon: Icon(Icons.calendar_today, size:16),
                      label: Text(_fromDate==null?'From Date':"${_fromDate!.day}-${_fromDate!.month}-${_fromDate!.year}", style: TextStyle(fontSize:11)),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(context: context, initialDate: _fromDate?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100));
                        if(picked!=null) setState(()=> _fromDate = picked);
                      },
                    )),
                    SizedBox(width:8),
                    Expanded(child: ElevatedButton.icon(
                      icon: Icon(Icons.calendar_today, size:16),
                      label: Text(_toDate==null?'To Date':"${_toDate!.day}-${_toDate!.month}-${_toDate!.year}", style: TextStyle(fontSize:11)),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(context: context, initialDate: _toDate?? DateTime.now().add(Duration(days:365)), firstDate: DateTime(1950), lastDate: DateTime(2100));
                        if(picked!=null) setState(()=> _toDate = picked);
                      },
                    )),
                  ]),
                  if(hasRange) Padding(
                    padding: EdgeInsets.only(top:6),
                    child: Row(children: [
                      Text('Range: ${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year} to ${_toDate!.day}/${_toDate!.month}/${_toDate!.year}', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold)),
                      Spacer(),
                      InkWell(onTap: ()=> setState((){ _fromDate=null; _toDate=null; }), child: Text('Clear', style: TextStyle(fontSize:10, color: Colors.red, fontWeight: FontWeight.bold))),
                    ]),
                  ),
                ],
              ),
            ),
            SizedBox(height:10),
            if(!hasRange)
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.date_range, size:40, color: Colors.grey),
                  SizedBox(height:8),
                  Text('Please select From and To dates', style: TextStyle(fontSize:13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  Text('BNN will calculate only for selected period', style: TextStyle(fontSize:10, color: Colors.grey[600])),
                  Text('(Not from birth date)', style: TextStyle(fontSize:9, color: Colors.red)),
                ]),
              ),
            if(hasRange)...[
              Container(color: Colors.orange[200], padding: EdgeInsets.symmetric(vertical:6, horizontal:4), child: Row(children: [
                Expanded(flex:2, child: Text('From', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
                Expanded(flex:2, child: Text('To', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Age', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
                Expanded(flex:2, child: Text('PP-NP', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
                Expanded(flex:2, child: Text('PS-NS', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
              ])),
              // SCROLL FIXED - Using Column
             ...rows.map((r){
                DateTime f=r['from']; DateTime t=r['to'];
                String fromStr = "${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year}";
                String toStr = "${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}";
                return Container(padding: EdgeInsets.symmetric(vertical:5, horizontal:4), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))), child: Row(children: [
                  Expanded(flex:2, child: Text(fromStr, style: TextStyle(fontSize:9))),
                  Expanded(flex:2, child: Text(toStr, style: TextStyle(fontSize:9))),
                  Expanded(child: Text('${r['age']}', style: TextStyle(fontSize:9))),
                  Expanded(flex:2, child: Text('${r['pp']}-${r['np']} (${r['dist']==0?1:r['dist']==1?2:r['dist']==4?5:r['dist']==6?7:9}H)', style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))),
                  Expanded(flex:2, child: Text('${r['ps']}-${r['ns']}', style: TextStyle(fontSize:9))),
                ]));
              }).toList(),
              if(rows.isEmpty) Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No BNN hits in this range. Try wider range.', style: TextStyle(color: Colors.grey)))),
              SizedBox(height:6),
              Text('Total ${rows.length} hits in selected range | Ra/Ke Anti-Clock OK | Asp 1,2,5,7,9', style: TextStyle(fontSize:8, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ad', title: 'AD (DELETED)', icon: Icons.delete, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'd9', title: 'D9 TOE', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sjmh', title: 'SJMH 9', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'aio', title: 'AIO 8', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sp', title: 'Sec Prog', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sa_tech', title: 'Solar Arc', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'pd_tech', title: 'Pri Dir', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ap_tech', title: 'AP 1.5', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class TNMasterModule extends AstroModule { const TNMasterModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'tn', title: 'T-N 0 Orb', icon: Icons.star, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }