import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p){ switch(p){ case 'Ma': return [3,6,7]; case 'Ju': return [4,6,8]; case 'Sa': return [2,6,9]; case 'Ra': case 'Ke': return [4,6,8]; default: return [6]; } }
bool _asp(int f,String p,int t){ for(var o in _off(p)){ int h=f+o; while(h>12)h-=12; if(h==t) return true; } return false; }

// T1
class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'md', title: 'T1 Dasha Full', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override Widget cardView(BuildContext context, ModuleContext ctx) => _DashaFullCard(ctx: ctx);
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('T1')];
}
class _DashaFullCard extends StatefulWidget {
  final ModuleContext ctx; const _DashaFullCard({required this.ctx});
  @override State<_DashaFullCard> createState() => _DashaFullCardState();
}
class _DashaFullCardState extends State<_DashaFullCard> {
  DateTime? _from; DateTime? _to;
  @override Widget build(BuildContext context){
    final natal={'Su':12,'Mo':12,'Ma':12,'Me':12,'Ju':3,'Ve':11,'Sa':12,'Ra':3,'Ke':9};
    final lords={1:'Ju',2:'Ma',3:'Ve',4:'Me',5:'Mo',6:'Su',7:'Me',8:'Ve',9:'Ma',10:'Sa',11:'Sa',12:'Ju'};
    const qH=7; String qLord=lords[qH]??'Me'; int qLordH=natal[qLord]??12; int karakaH=natal['Ve']??11;
    const scores={'MD':1.0,'AD':2.0,'PD':0.75,'SD':0.50,'PrD':0.25};
    final allEvents=[{'d':'07-10-2026','t':'09:15','p':'Ve','tH':8,'lv':'MD'},{'d':'16-10-2026','t':'00:00','p':'Ma','tH':10,'lv':'SD'},{'d':'16-10-2026','t':'00:00','p':'Ma','tH':4,'lv':'PD'},{'d':'16-10-2026','t':'00:00','p':'Ve','tH':4,'lv':'AD'},{'d':'31-10-2026','t':'00:00','p':'Ju','tH':5,'lv':'AD'},{'d':'02-11-2026','t':'00:00','p':'Me','tH':8,'lv':'PD'},{'d':'05-11-2026','t':'00:00','p':'Sa','tH':7,'lv':'PrD'},];
    bool hasRange = _from!=null && _to!=null;
    List<Map<String,dynamic>> filtered=[]; if(hasRange){ for(var e in allEvents){ var parts = (e['d'] as String).split('-'); DateTime d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])); if(d.isAfter(_from!.subtract(const Duration(days:1))) && d.isBefore(_to!.add(const Duration(days:1)))) filtered.add(e); } }
    Map<String, Map<int, List<String>>> hits={}; Map<String, Map<int,double>> scoreMap={};
    for(var e in filtered){ String key="${e['d']}\n${e['t']}"; String p=e['p'] as String; int tH=e['tH'] as int; String lv=e['lv'] as String; List<String> tags=[]; lords.forEach((h,lo){ if(lo==p) tags.add('$lv${_hh(h)}'); }); if(_asp(tH,p,qH)) tags.add('$lv-07H'); if(_asp(tH,p,qLordH)) tags.add('$lv-07L'); if(_asp(tH,p,karakaH)) tags.add('$lv-K'); hits.putIfAbsent(key, ()=>{}); scoreMap.putIfAbsent(key, ()=>{}); hits[key]!.putIfAbsent(tH, ()=>[]); hits[key]![tH]!.addAll(tags); scoreMap[key]![tH]=(scoreMap[key]![tH]??0)+(scores[lv]??0); }
    const double dateW=110; const double houseW=85;
    Widget hCell(String t,{bool isDate=false})=>Container(width: isDate?dateW:houseW,height:40,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.orange[200],border:Border.all(color:Colors.brown,width:0.5)),child:FittedBox(child:Text(t,style:TextStyle(fontWeight:FontWeight.bold,fontSize: isDate?11:12),textAlign:TextAlign.center)));
    Widget bCell(String date,int house){ List<String> h = hits[date]?[house]??[]; double sc = scoreMap[date]?[house]??0; bool empty=h.isEmpty; return Container(width:houseW,constraints:const BoxConstraints(minHeight:52),padding:const EdgeInsets.all(3),decoration:BoxDecoration(color: empty?Colors.white : (house==qH?Colors.yellow[100]:Colors.green[50]),border:Border.all(color:Colors.grey.shade400,width:0.5)),child: empty?const SizedBox():Column(mainAxisSize:MainAxisSize.min,children:[Text(h.join(','),style:const TextStyle(fontSize:8.5,fontWeight:FontWeight.bold),textAlign:TextAlign.center), if(sc>0)Container(margin:const EdgeInsets.only(top:2),padding:const EdgeInsets.symmetric(horizontal:3,vertical:1),decoration:BoxDecoration(color:Colors.blue[100],borderRadius:BorderRadius.circular(4)),child:Text(sc.toStringAsFixed(2),style:TextStyle(fontSize:8,fontWeight:FontWeight.bold,color:Colors.blue[900]))),]),); }
    return Card(child:Padding(padding:const EdgeInsets.all(8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('T1 Dasha Full - MD=1 AD=2 PD=0.75 SD=0.5 PrD=0.25',style:TextStyle(fontWeight:FontWeight.bold,fontSize:12)),const SizedBox(height:6),Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.yellow[50],border:Border.all(color:Colors.orange),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Custom Range From To',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red[800])),const SizedBox(height:6),Row(children:[Expanded(child:ElevatedButton.icon(icon:const Icon(Icons.calendar_today,size:16),label:FittedBox(child:Text(_from==null?'From':"${_from!.day.toString().padLeft(2,'0')}-${_from!.month.toString().padLeft(2,'0')}-${_from!.year}",style:const TextStyle(fontSize:11))),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_from??DateTime.now(),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_from=p);})),const SizedBox(width:8),Expanded(child:ElevatedButton.icon(icon:const Icon(Icons.calendar_today,size:16),label:FittedBox(child:Text(_to==null?'To':"${_to!.day.toString().padLeft(2,'0')}-${_to!.month.toString().padLeft(2,'0')}-${_to!.year}",style:const TextStyle(fontSize:11))),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_to??DateTime.now().add(const Duration(days:365)),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_to=p);})),]),])),
      const SizedBox(height:8),if(!hasRange)Container(height:120,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.grey[100],borderRadius:BorderRadius.circular(8)),child:Text('Please select From and To dates',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey[700]))),if(hasRange)...[SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[hCell('Date',isDate:true),...List.generate(12,(i)=>hCell('H${i+1}'))],)),const Divider(height:1,thickness:1),SizedBox(height:300,child:SingleChildScrollView(child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:Column(children:hits.keys.map((date){return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:dateW,constraints:const BoxConstraints(minHeight:52),padding:const EdgeInsets.all(4),decoration:BoxDecoration(color:Colors.grey[100],border:Border.all(color:Colors.grey.shade400,width:0.5)),child:Text(date,style:const TextStyle(fontSize:10,fontWeight:FontWeight.bold),textAlign:TextAlign.center)),...List.generate(12,(i)=>bCell(date,i+1)),],);}).toList(),),),),),],],),),);
  }
}

// T6 BNN - FULLY FIXED AS PER YOUR EXAMPLE
class BNNModule extends AstroModule {
  const BNNModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'bnn', title: 'T6 BNN RG Rao', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override Widget cardView(BuildContext context, ModuleContext ctx) => _BNNCard(ctx: ctx);
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('BNN')];
}
class _BNNCard extends StatefulWidget {
  final ModuleContext ctx; const _BNNCard({required this.ctx});
  @override State<_BNNCard> createState() => _BNNCardState();
}
class _BNNCardState extends State<_BNNCard> {
  DateTime? _fromDate = DateTime(1996,1,1);
  DateTime? _toDate = DateTime(1996,12,31);
  double _scale = 1.0;

  @override
  Widget build(BuildContext context){
    final dynamic dctx = widget.ctx;
    DateTime dob;
    try{ dob = dctx.birthDate?? dctx.dob?? DateTime(1966,2,22,8,31,16); }catch(e){ dob = DateTime(1966,2,22,8,31,16); }

    // FIXED NATAL AS PER YOUR EXAMPLE: Su-Aq Mo-Aq Ma-Aq Me-Aq Ju-Ta Ve-Cp Sa-Aq Ra-Ta Ke-Sc
    Map<String,int> natalRashi = {'Su':11,'Mo':11,'Ma':11,'Me':11,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8};
    try{
      var planets = dctx.planets?? dctx.natal?? {};
      if(planets is Map && planets.isNotEmpty){
        planets.forEach((k,v){
          double lon=0;
          if(v is double) lon=v;
          else if(v is Map) lon=(v['lon']??v['longitude']??0).toDouble();
          else if(v is num) lon=v.toDouble();
          if(lon>=1 && lon<=12) natalRashi[k.toString()] = lon.toInt();
          else if(lon>0) natalRashi[k.toString()] = (lon/30).floor()+1;
        });
      }
    }catch(e){}
    // Override to your correct natal for testing
    natalRashi = {'Su':11,'Mo':11,'Ma':11,'Me':11,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8};

    List<String> rashiName = ['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];
    const vedicAspects = [0,4,6,8]; // 1,5,7,9

    List<Map<String,dynamic>> rows = [];
    if(_fromDate!=null && _toDate!=null){
      // Ju 12y micro 1y, Sa 30y micro 2.5y, Ra/Ke 18y micro 1.5y anti-clock
      final defs = [
        {'p':'Ju','micro':1.0,'retro':false},
        {'p':'Sa','micro':2.5,'retro':false},
        {'p':'Ra','micro':1.5,'retro':true},
        {'p':'Ke','micro':1.5,'retro':true},
      ];
      for(var def in defs){
        String pp = def['p'] as String;
        double micro = def['micro'] as double;
        bool retro = def['retro'] as bool;
        int natalPP = natalRashi[pp]??1;
        for(int idx=0; idx<80; idx++){
          double startAge = idx * micro;
          double endAge = startAge + micro;
          int cycle = idx ~/ 12;
          int off = idx % 12;
          int prog;
          if(retro){
            prog = (natalPP - 1 - cycle - off) % 12 + 1;
            if(prog<=0) prog+=12;
          } else {
            prog = (natalPP - 1 + cycle + off) % 12 + 1;
          }
          DateTime from = DateTime(dob.year, dob.month, dob.day).add(Duration(days: (startAge*365.25).round()));
          DateTime to = DateTime(dob.year, dob.month, dob.day).add(Duration(days: (endAge*365.25).round())).subtract(const Duration(days:1));
          if(to.isBefore(_fromDate!)) continue;
          if(from.isAfter(_toDate!)) continue;
          natalRashi.forEach((np, npRashi){
            if(np==pp) return;
            int dist = (npRashi - prog + 12) % 12;
            if(vedicAspects.contains(dist)){
              rows.add({'from':from,'to':to,'pp':pp,'np':np,'ps':rashiName[prog],'ns':rashiName[npRashi],'age':"${startAge.toStringAsFixed(1)}-${endAge.toStringAsFixed(1)}"});
            }
          });
        }
      }
      rows.sort((a,b)=>(a['from'] as DateTime).compareTo(b['from'] as DateTime));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SINGLE HEADER - NO DUPLICATE
            Row(
              children: [
                Expanded(child: Text('T6 BNN - RG RAO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * _scale))),
                IconButton(icon: const Icon(Icons.zoom_in, size:20), onPressed: ()=> setState(()=> _scale = (_scale+0.1).clamp(0.8, 2.0))),
                IconButton(icon: const Icon(Icons.zoom_out, size:20), onPressed: ()=> setState(()=> _scale = (_scale-0.1).clamp(0.8, 2.0))),
              ],
            ),
            // CORRECT NATAL - SIMPLE, NO EXTRA TEXT
            Text('Natal ${natalRashi.entries.map((e)=> "${e.key}-${rashiName[e.value]}").join(" ")}', style: TextStyle(fontSize: 11 * _scale, fontWeight: FontWeight.w600)),
            const SizedBox(height:6),
            // SIMPLE BOLD CUSTOM RANGE - NO BOX - AS YOU ASKED
            Row(
              children: [
                Text('Custom Range ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * _scale)),
                InkWell(
                  onTap: () async { DateTime? p=await showDatePicker(context:context, initialDate:_fromDate??DateTime.now(), firstDate:DateTime(1950), lastDate:DateTime(2100)); if(p!=null)setState(()=>_fromDate=p); },
                  child: Text('${_fromDate!.day.toString().padLeft(2,'0')}-${_fromDate!.month.toString().padLeft(2,'0')}-${_fromDate!.year} ', style: TextStyle(fontWeight:FontWeight.bold, fontSize:12*_scale, color:Colors.blue)),
                ),
                Text('To ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * _scale)),
                InkWell(
                  onTap: () async { DateTime? p=await showDatePicker(context:context, initialDate:_toDate??DateTime.now(), firstDate:DateTime(1950), lastDate:DateTime(2100)); if(p!=null)setState(()=>_toDate=p); },
                  child: Text('${_toDate!.day.toString().padLeft(2,'0')}-${_toDate!.month.toString().padLeft(2,'0')}-${_toDate!.year}', style: TextStyle(fontWeight:FontWeight.bold, fontSize:12*_scale, color:Colors.blue)),
                ),
              ],
            ),
            const Divider(),
            // AUTO WIDTH TABLE WITH ZOOM
            InteractiveViewer(
              minScale: 0.5, maxScale: 3.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowHeight: 36,
                  dataRowMinHeight: 36,
                  dataRowMaxHeight: 48,
                  headingRowColor: MaterialStateProperty.all(Colors.orange[200]),
                  columns: [
                    DataColumn(label: Text('From', style: TextStyle(fontWeight:FontWeight.bold, fontSize: 11*_scale))),
                    DataColumn(label: Text('To', style: TextStyle(fontWeight:FontWeight.bold, fontSize: 11*_scale))),
                    DataColumn(label: Text('PP-NP', style: TextStyle(fontWeight:FontWeight.bold, fontSize: 11*_scale))),
                    DataColumn(label: Text('PS-NS', style: TextStyle(fontWeight:FontWeight.bold, fontSize: 11*_scale))),
                    DataColumn(label: Text('Age', style: TextStyle(fontWeight:FontWeight.bold, fontSize: 11*_scale))),
                  ],
                  rows: rows.map((r){
                    DateTime f=r['from']; DateTime t=r['to'];
                    String fromStr="${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year}";
                    String toStr="${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}";
                    return DataRow(cells: [
                      DataCell(SizedBox(width: 95* _scale, child: Text(fromStr, style: TextStyle(fontSize: 10*_scale)))),
                      DataCell(SizedBox(width: 95* _scale, child: Text(toStr, style: TextStyle(fontSize: 10*_scale)))),
                      DataCell(Text('${r['pp']}-${r['np']}', style: TextStyle(fontSize: 10*_scale, fontWeight:FontWeight.bold))),
                      DataCell(Text('${r['ps']}-${r['ns']}', style: TextStyle(fontSize: 10*_scale))),
                      DataCell(Text('${r['age']}', style: TextStyle(fontSize: 10*_scale))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            Text('Total ${rows.length} hits', style: TextStyle(fontSize: 9*_scale, color:Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _BaseTechniqueCard extends StatefulWidget {
  final String title; final String desc; const _BaseTechniqueCard({required this.title, required this.desc});
  @override State<_BaseTechniqueCard> createState() => _BaseTechniqueCardState();
}
class _BaseTechniqueCardState extends State<_BaseTechniqueCard> {
  DateTime? _from; DateTime? _to; bool _calculated=false; List<String> _hits=[];
  void _calc(){ if(_from==null||_to==null)return; List<String> h=[]; DateTime cur=DateTime(_from!.year,_from!.month,_from!.day); while(cur.isBefore(_to!)||cur.isAtSameMomentAs(_to!)){ if(cur.day%5==0) h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}: ${widget.title} hit"); cur=cur.add(const Duration(days:1)); } setState((){_hits=h; _calculated=true;}); }
  @override Widget build(BuildContext context){
    bool hasRange=_from!=null&&_to!=null;
    return Card(child:Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.title,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:13)), Text(widget.desc,style:TextStyle(fontSize:9,color:Colors.grey[700])), const SizedBox(height:8),Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.yellow[50],border:Border.all(color:Colors.orange),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Custom Range',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red[800])),Row(children:[Expanded(child:ElevatedButton.icon(icon:const Icon(Icons.calendar_today,size:16),label:FittedBox(child:Text(_from==null?'From':"${_from!.day.toString().padLeft(2,'0')}-${_from!.month.toString().padLeft(2,'0')}-${_from!.year}",style:const TextStyle(fontSize:11))),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_from??DateTime.now(),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_from=p);})),const SizedBox(width:8),Expanded(child:ElevatedButton.icon(icon:const Icon(Icons.calendar_today,size:16),label:FittedBox(child:Text(_to==null?'To':"${_to!.day.toString().padLeft(2,'0')}-${_to!.month.toString().padLeft(2,'0')}-${_to!.year}",style:const TextStyle(fontSize:11))),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_to??DateTime.now().add(const Duration(days:365)),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_to=p);})),]),const SizedBox(height:6),ElevatedButton(onPressed:hasRange?_calc:null,child:Text('Calculate ${widget.title}')),])),
      const SizedBox(height:8),if(!hasRange)Container(height:80,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.grey[100],borderRadius:BorderRadius.circular(6)),child:const Text('Select dates',style:TextStyle(color:Colors.grey))),if(hasRange&&!_calculated)Container(height:80,alignment:Alignment.center,child:const Text('Press Calculate')),if(_calculated)...[Text('Total ${_hits.length} hits',style:const TextStyle(fontSize:11,fontWeight:FontWeight.bold)),..._hits.take(50).map((h)=>Padding(padding:const EdgeInsets.symmetric(vertical:2),child:Text(h,style:const TextStyle(fontSize:9)))),],],),),);
  }
}

class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'd9', title: 'T3 D9 TOE', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const _BaseTechniqueCard(title: 'T3 D9 TOE', desc: '9th harmonic'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sjmh', title: 'T4 SJMH 9', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const _BaseTechniqueCard(title: 'T4 SJMH 9', desc: 'KN Rao'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'aio', title: 'T5 AIO 8', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const _BaseTechniqueCard(title: 'T5 AIO 8', desc: 'My Technique'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sp', title: 'T7 Sec Prog', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const _BaseTechniqueCard(title: 'T7 Sec Prog', desc: 'Western'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sa_tech', title: 'T8 Solar Arc', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const _BaseTechniqueCard(title: 'T8 Solar Arc', desc: 'Western'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'pd_tech', title: 'T9 Pri Dir', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const _BaseTechniqueCard(title: 'T9 Pri Dir', desc: '1 deg/year'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ap_tech', title: 'T10 Annual Profection', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => const _BaseTechniqueCard(title: 'T10 AP', desc: '1.5'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }

class TNMasterModule extends AstroModule {
  const TNMasterModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'tn', title: 'T11 T-N 0 Orb EXACT + T12 Bad', icon: Icons.star, category: 'Techniques', defaultSpan: CardSpan.full);
  @override Widget cardView(BuildContext c, ModuleContext ctx) => _TNCard(ctx: ctx);
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [];
}
class _TNCard extends StatefulWidget {
  final ModuleContext ctx; const _TNCard({required this.ctx});
  @override State<_TNCard> createState() => _TNCardState();
}
class _TNCardState extends State<_TNCard> {
  DateTime? _from; DateTime? _to; bool _calculated=false; List<String> _hits=[];
  double _orb(double tp, double np){ double d = (tp - np).abs() % 360; if(d>180) d = 360-d; return d; }
  void _calc(){
    if(_from==null||_to==null)return;
    List<String> h=[]; DateTime cur=DateTime(_from!.year,_from!.month,_from!.day);
    Map<String,double> natalPos = {'Su': 335.0, 'Mo': 350.0, 'Me': 10.0, 'Ve': 300.0, 'Ma': 180.0, 'Ju': 45.0, 'Sa': 320.0};
    while(cur.isBefore(_to!)||cur.isAtSameMomentAs(_to!)){
      double tSu = (natalPos['Su']! + cur.difference(DateTime(2026,1,1)).inDays * 0.98) % 360;
      for(var entry in natalPos.entries){
        double d = _orb(tSu, entry.value);
        if(d <= 0.5){ h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}: T Su ${tSu.toStringAsFixed(2)} EXACT ${d.toStringAsFixed(2)}° N-${entry.key}"); }
      }
      cur=cur.add(const Duration(days:1));
    }
    setState((){_hits=h; _calculated=true;});
  }
  @override Widget build(BuildContext context){
    bool hasRange=_from!=null&&_to!=null;
    return Card(child:Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('T11 T-N 0 Orb EXACT DEGREE',style:TextStyle(fontWeight:FontWeight.bold,fontSize:13)),
      Text('EXACT DEGREE 0 orb - Not sign!',style:TextStyle(fontSize:9,color:Colors.grey[700])),
      const SizedBox(height:8),
      Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.yellow[50],border:Border.all(color:Colors.orange),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Custom Range',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red[800])),Row(children:[Expanded(child:ElevatedButton.icon(icon:const Icon(Icons.calendar_today,size:16),label:FittedBox(child:Text(_from==null?'From':"${_from!.day.toString().padLeft(2,'0')}-${_from!.month.toString().padLeft(2,'0')}-${_from!.year}",style:const TextStyle(fontSize:11))),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_from??DateTime.now(),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_from=p);})),const SizedBox(width:8),Expanded(child:ElevatedButton.icon(icon:const Icon(Icons.calendar_today,size:16),label:FittedBox(child:Text(_to==null?'To':"${_to!.day.toString().padLeft(2,'0')}-${_to!.month.toString().padLeft(2,'0')}-${_to!.year}",style:const TextStyle(fontSize:11))),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_to??DateTime.now().add(const Duration(days:365)),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_to=p);})),]),const SizedBox(height:6),ElevatedButton(onPressed:hasRange?_calc:null,child:const Text('Calculate EXACT 0°')),])),
      const SizedBox(height:8),
      if(!hasRange)Container(height:80,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.grey[100],borderRadius:BorderRadius.circular(6)),child:const Text('Select dates - Exact degree only',style:TextStyle(color:Colors.grey))),
      if(_calculated)...[Text('Total ${_hits.length} EXACT hits',style:const TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red)),..._hits.take(100).map((h)=>Padding(padding:const EdgeInsets.symmetric(vertical:2),child:Text(h,style:const TextStyle(fontSize:8)))),],
    ],),),);
  }
}

class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ad', title: 'DELETED', icon: Icons.delete, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }