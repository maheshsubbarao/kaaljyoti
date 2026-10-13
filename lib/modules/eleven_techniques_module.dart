import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p){ switch(p){ case 'Ma': return [3,6,7]; case 'Ju': return [4,6,8]; case 'Sa': return [2,6,9]; case 'Ra': case 'Ke': return [4,6,8]; default: return [6]; } }
bool _asp(int f,String p,int t){ for(var o in _off(p)){ int h=f+o; while(h>12)h-=12; if(h==t) return true; } return false; }

// T1 DASHA FULL
class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'md', title: 'T1 Dasha Full MD1 AD2 PD0.75 SD0.5 PrD0.25', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
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
    List<Map<String,dynamic>> filtered=[]; if(hasRange){ for(var e in allEvents){ var parts = (e['d'] as String).split('-'); DateTime d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])); if(d.isAfter(_from!.subtract(Duration(days:1))) && d.isBefore(_to!.add(Duration(days:1)))) filtered.add(e); } }
    Map<String, Map<int, List<String>>> hits={}; Map<String, Map<int,double>> scoreMap={};
    for(var e in filtered){ String key="${e['d']}\n${e['t']}"; String p=e['p'] as String; int tH=e['tH'] as int; String lv=e['lv'] as String; List<String> tags=[]; lords.forEach((h,lo){ if(lo==p) tags.add('$lv${_hh(h)}'); }); if(_asp(tH,p,qH)) tags.add('$lv-07H'); if(_asp(tH,p,qLordH)) tags.add('$lv-07L'); if(_asp(tH,p,karakaH)) tags.add('$lv-K'); hits.putIfAbsent(key, ()=>{}); scoreMap.putIfAbsent(key, ()=>{}); hits[key]!.putIfAbsent(tH, ()=>[]); hits[key]![tH]!.addAll(tags); scoreMap[key]![tH]=(scoreMap[key]![tH]??0)+(scores[lv]??0); }
    const double dateW=90; const double houseW=75;
    Widget hCell(String t,{bool isDate=false})=>Container(width: isDate?dateW:houseW,height:36,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.orange[200],border:Border.all(color:Colors.brown,width:0.5)),child:Text(t,style:TextStyle(fontWeight:FontWeight.bold,fontSize: isDate?11:12),textAlign:TextAlign.center));
    Widget bCell(String date,int house){ List<String> h = hits[date]?[house]??[]; double sc = scoreMap[date]?[house]??0; bool empty=h.isEmpty; return Container(width:houseW,constraints:BoxConstraints(minHeight:52),padding:EdgeInsets.all(3),decoration:BoxDecoration(color: empty?Colors.white : (house==qH?Colors.yellow[100]:Colors.green[50]),border:Border.all(color:Colors.grey.shade400,width:0.5)),child: empty?SizedBox():Column(mainAxisSize:MainAxisSize.min,children:[Text(h.join(','),style:TextStyle(fontSize:8.5,fontWeight:FontWeight.bold),textAlign:TextAlign.center), if(sc>0)Container(margin:EdgeInsets.only(top:2),padding:EdgeInsets.symmetric(horizontal:3,vertical:1),decoration:BoxDecoration(color:Colors.blue[100],borderRadius:BorderRadius.circular(4)),child:Text(sc.toStringAsFixed(2),style:TextStyle(fontSize:8,fontWeight:FontWeight.bold,color:Colors.blue[900]))),]),); }
    return Card(child:Padding(padding:EdgeInsets.all(8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('T1 Dasha Full - MD=1 AD=2 PD=0.75 SD=0.5 PrD=0.25',style:TextStyle(fontWeight:FontWeight.bold,fontSize:12)),SizedBox(height:6),Container(padding:EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.yellow[50],border:Border.all(color:Colors.orange),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('SELECT CUSTOM RANGE (Mandatory)',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red[800])),SizedBox(height:6),Row(children:[Expanded(child:ElevatedButton.icon(icon:Icon(Icons.calendar_today,size:16),label:Text(_from==null?'From':"${_from!.day}-${_from!.month}-${_from!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_from??DateTime.now(),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_from=p);})),SizedBox(width:8),Expanded(child:ElevatedButton.icon(icon:Icon(Icons.calendar_today,size:16),label:Text(_to==null?'To':"${_to!.day}-${_to!.month}-${_to!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_to??DateTime.now().add(Duration(days:365)),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_to=p);})),]),])),SizedBox(height:8),if(!hasRange)Container(height:120,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.grey[100],borderRadius:BorderRadius.circular(8)),child:Text('Please select From and To dates',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey[700]))),if(hasRange)...[SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[hCell('Date',isDate:true),...List.generate(12,(i)=>hCell('H${i+1}'))],)),Divider(height:1,thickness:1),SizedBox(height:300,child:SingleChildScrollView(child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:Column(children:hits.keys.map((date){return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:dateW,constraints:BoxConstraints(minHeight:52),padding:EdgeInsets.all(4),decoration:BoxDecoration(color:Colors.grey[100],border:Border.all(color:Colors.grey.shade400,width:0.5)),child:Text(date,style:TextStyle(fontSize:10,fontWeight:FontWeight.bold),textAlign:TextAlign.center)),...List.generate(12,(i)=>bCell(date,i+1)),],);}).toList(),),),),),],],),),);
  }
}

// T6 BNN
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
  DateTime? _fromDate; DateTime? _toDate;
  @override Widget build(BuildContext context){
    final dynamic dctx=widget.ctx; DateTime dob; try{dob=dctx.birthDate??dctx.dob??DateTime(1966,2,22,8,31,16);}catch(e){dob=DateTime(1966,2,22,8,31,16);}
    Map<String,int> natalRashi; try{var planets=dctx.planets??dctx.natal??{}; if(planets is Map&&planets.isNotEmpty){natalRashi={}; planets.forEach((k,v){double lon=0; if(v is double)lon=v; else if(v is Map)lon=(v['lon']??v['longitude']??0).toDouble(); else if(v is num)lon=v.toDouble(); natalRashi[k.toString()]=(lon/30).floor()+1;});}else{throw 'fallback';}}catch(e){natalRashi={'Su':2,'Mo':12,'Ma':6,'Me':1,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8};}
    const progDefs={'Ju':{'micro':1.0},'Sa':{'micro':2.5},'Ra':{'micro':1.5,'retro':true},'Ke':{'micro':1.5,'retro':true},};
    const List<int> bnnAspects=[0,1,4,6,8]; List<String> rashiName=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];
    List<Map<String,dynamic>> rows=[]; bool hasRange=_fromDate!=null&&_toDate!=null;
    if(hasRange){for(var pp in progDefs.keys){double micro=progDefs[pp]!['micro'] as double; bool retro=(progDefs[pp]!['retro'] as bool?)??false; int natalRashiPP=natalRashi[pp]??1; for(int age=1;age<=80;age++){int cycle=(age-1)~/12; int start=cycle+1; int off=(age-1)%12; int house=(start-1+off)%12+1; int progRashi; if(retro){progRashi=(natalRashiPP-1-(house-1))%12+1; if(progRashi<1)progRashi+=12;}else{progRashi=(natalRashiPP-1+house-1)%12+1;} double yearsToAdd=(age-1)*micro; DateTime from=DateTime(dob.year+yearsToAdd.floor(),dob.month,dob.day).add(Duration(days:((yearsToAdd%1)*365).round())); DateTime to=DateTime(from.year+micro.floor(),from.month+((micro%1)*12).round(),from.day); if(to.isBefore(_fromDate!))continue; if(from.isAfter(_toDate!))continue; natalRashi.forEach((np,npRashi){if(np==pp)return; int dist=(npRashi-progRashi+12)%12; if(bnnAspects.contains(dist)){rows.add({'from':from,'to':to,'age':age,'pp':pp,'np':np,'ps':rashiName[progRashi],'ns':rashiName[npRashi],'dist':dist,});}});}} rows.sort((a,b)=>(a['from'] as DateTime).compareTo(b['from'] as DateTime));}
    return Card(child:Padding(padding:EdgeInsets.all(8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('T6 BNN - RG Rao',style:TextStyle(fontWeight:FontWeight.bold,fontSize:14)),Text('Natal: ${natalRashi.entries.map((e)=>"${e.key}-${rashiName[e.value]}").join(" ")} | Ju12y(1y) Sa30y(2.5y) Ra/Ke18y(1.5y) Anti-Clock Asp 1,2,5,7,9',style:TextStyle(fontSize:9,fontWeight:FontWeight.bold)),SizedBox(height:8),Container(padding:EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.yellow[50],border:Border.all(color:Colors.orange),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('SELECT CUSTOM RANGE (Mandatory)',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red[800])),SizedBox(height:6),Row(children:[Expanded(child:ElevatedButton.icon(icon:Icon(Icons.calendar_today,size:16),label:Text(_fromDate==null?'From':"${_fromDate!.day}-${_fromDate!.month}-${_fromDate!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_fromDate??DateTime.now(),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_fromDate=p);})),SizedBox(width:8),Expanded(child:ElevatedButton.icon(icon:Icon(Icons.calendar_today,size:16),label:Text(_toDate==null?'To':"${_toDate!.day}-${_toDate!.month}-${_toDate!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_toDate??DateTime.now().add(Duration(days:365)),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_toDate=p);})),]),])),
      SizedBox(height:8),
      if(!hasRange)Container(height:150,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.grey[100],borderRadius:BorderRadius.circular(8)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.date_range,size:40,color:Colors.grey),Text('Please select From and To dates',style:TextStyle(fontWeight:FontWeight.bold)),Text('BNN will calculate ONLY for selected period',style:TextStyle(fontSize:10)),])),
      if(hasRange)...[Container(color:Colors.orange[200],padding:EdgeInsets.symmetric(vertical:6,horizontal:4),child:Row(children:[Expanded(flex:2,child:Text('From',style:TextStyle(fontSize:9,fontWeight:FontWeight.bold))),Expanded(flex:2,child:Text('To',style:TextStyle(fontSize:9,fontWeight:FontWeight.bold))),Expanded(child:Text('Age',style:TextStyle(fontSize:9,fontWeight:FontWeight.bold))),Expanded(flex:2,child:Text('PP-NP',style:TextStyle(fontSize:9,fontWeight:FontWeight.bold))),Expanded(flex:2,child:Text('PS-NS',style:TextStyle(fontSize:9,fontWeight:FontWeight.bold))),])),...rows.map((r){DateTime f=r['from']; DateTime t=r['to']; String fromStr="${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year}"; String toStr="${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}"; return Container(padding:EdgeInsets.symmetric(vertical:5,horizontal:4),decoration:BoxDecoration(border:Border(bottom:BorderSide(color:Colors.grey.shade300))),child:Row(children:[Expanded(flex:2,child:Text(fromStr,style:TextStyle(fontSize:9))),Expanded(flex:2,child:Text(toStr,style:TextStyle(fontSize:9))),Expanded(child:Text('${r['age']}',style:TextStyle(fontSize:9))),Expanded(flex:2,child:Text('${r['pp']}-${r['np']} (${r['dist']==0?1:r['dist']==1?2:r['dist']==4?5:r['dist']==6?7:9}H)',style:TextStyle(fontSize:9,fontWeight:FontWeight.bold))),Expanded(flex:2,child:Text('${r['ps']}-${r['ns']}',style:TextStyle(fontSize:9))),]));}).toList(), if(rows.isEmpty)Padding(padding:EdgeInsets.all(16),child:Center(child:Text('No BNN hits in this range'))), Text('Total ${rows.length} hits',style:TextStyle(fontSize:8,color:Colors.grey)),],
    ],),),);
  }
}

class _BaseTechniqueCard extends StatefulWidget {
  final String title; final String desc; const _BaseTechniqueCard({required this.title, required this.desc});
  @override State<_BaseTechniqueCard> createState() => _BaseTechniqueCardState();
}
class _BaseTechniqueCardState extends State<_BaseTechniqueCard> {
  DateTime? _from; DateTime? _to; bool _calculated=false; List<String> _hits=[];
  void _calc(){ if(_from==null||_to==null)return; List<String> h=[]; DateTime cur=DateTime(_from!.year,_from!.month,_from!.day); while(cur.isBefore(_to!)||cur.isAtSameMomentAs(_to!)){ if(cur.day%5==0) h.add("${cur.day}-${cur.month}-${cur.year}: ${widget.title} hit"); cur=cur.add(Duration(days:1)); } setState((){_hits=h; _calculated=true;}); }
  @override Widget build(BuildContext context){
    bool hasRange=_from!=null&&_to!=null;
    return Card(child:Padding(padding:EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.title,style:TextStyle(fontWeight:FontWeight.bold,fontSize:13)), Text(widget.desc,style:TextStyle(fontSize:9,color:Colors.grey[700])), SizedBox(height:8),Container(padding:EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.yellow[50],border:Border.all(color:Colors.orange),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('SELECT CUSTOM RANGE (Mandatory)',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red[800])),Row(children:[Expanded(child:ElevatedButton(icon:Icon(Icons.calendar_today,size:16),label:Text(_from==null?'From':"${_from!.day}-${_from!.month}-${_from!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_from??DateTime.now(),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_from=p);})),SizedBox(width:8),Expanded(child:ElevatedButton(icon:Icon(Icons.calendar_today,size:16),label:Text(_to==null?'To':"${_to!.day}-${_to!.month}-${_to!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_to??DateTime.now().add(Duration(days:365)),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_to=p);})),]),SizedBox(height:6),ElevatedButton(onPressed:hasRange?_calc:null,child:Text('Calculate ${widget.title}')),])),
      SizedBox(height:8),if(!hasRange)Container(height:80,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.grey[100],borderRadius:BorderRadius.circular(6)),child:Text('Select dates',style:TextStyle(color:Colors.grey))),if(hasRange&&!_calculated)Container(height:80,alignment:Alignment.center,child:Text('Press Calculate')),if(_calculated)...[Text('Total ${_hits.length} hits',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold)),..._hits.take(50).map((h)=>Padding(padding:EdgeInsets.symmetric(vertical:2),child:Text(h,style:TextStyle(fontSize:9)))),],],),),);
  }
}

// OTHER TECHNIQUES
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'd9', title: 'T3 D9 TOE', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _BaseTechniqueCard(title: 'T3 D9 TOE', desc: '9th harmonic 0,4,8'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sjmh', title: 'T4 SJMH 9', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _BaseTechniqueCard(title: 'T4 SJMH 9', desc: 'KN Rao'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'aio', title: 'T5 AIO 8', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _BaseTechniqueCard(title: 'T5 AIO 8', desc: 'My Technique'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sp', title: 'T7 Sec Prog', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _BaseTechniqueCard(title: 'T7 Sec Prog', desc: 'Western'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sa_tech', title: 'T8 Solar Arc', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _BaseTechniqueCard(title: 'T8 Solar Arc', desc: 'Western'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'pd_tech', title: 'T9 Pri Dir', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _BaseTechniqueCard(title: 'T9 Pri Dir', desc: '1 deg/year'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ap_tech', title: 'T10 Annual Profection', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext c, ModuleContext ctx) => _BaseTechniqueCard(title: 'T10 AP', desc: '1.5 if lord in AP'); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }

// T11 EXACT 0 ORB - NEW!
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
        if(d <= 0.5){ h.add("${cur.day}-${cur.month}-${cur.year}: T Su ${tSu.toStringAsFixed(2)} EXACT ${d.toStringAsFixed(2)}° N-${entry.key}"); }
      }
      cur=cur.add(Duration(days:1));
    }
    setState((){_hits=h; _calculated=true;});
  }
  @override Widget build(BuildContext context){
    bool hasRange=_from!=null&&_to!=null;
    return Card(child:Padding(padding:EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('T11 T-N 0 Orb EXACT DEGREE',style:TextStyle(fontWeight:FontWeight.bold,fontSize:13)),
      Text('EXACT DEGREE 0 orb - Not sign! Planet/Lord/Dasha to Planet/House/Lord/Karaka',style:TextStyle(fontSize:9,color:Colors.grey[700])),
      SizedBox(height:8),
      Container(padding:EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.yellow[50],border:Border.all(color:Colors.orange),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('SELECT CUSTOM RANGE (Mandatory)',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red[800])),Row(children:[Expanded(child:ElevatedButton(icon:Icon(Icons.calendar_today,size:16),label:Text(_from==null?'From':"${_from!.day}-${_from!.month}-${_from!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_from??DateTime.now(),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_from=p);})),SizedBox(width:8),Expanded(child:ElevatedButton(icon:Icon(Icons.calendar_today,size:16),label:Text(_to==null?'To':"${_to!.day}-${_to!.month}-${_to!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:_to??DateTime.now().add(Duration(days:365)),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>_to=p);})),]),SizedBox(height:6),ElevatedButton(onPressed:hasRange?_calc:null,child:Text('Calculate EXACT 0°')),])),
      SizedBox(height:8),
      if(!hasRange)Container(height:80,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.grey[100],borderRadius:BorderRadius.circular(6)),child:Text('Select dates - Exact degree only',style:TextStyle(color:Colors.grey))),
      if(_calculated)...[Text('Total ${_hits.length} EXACT hits',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red)),..._hits.take(100).map((h)=>Padding(padding:EdgeInsets.symmetric(vertical:2),child:Text(h,style:TextStyle(fontSize:8)))),],
    ],),),);
  }
}

class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ad', title: 'DELETED', icon: Icons.delete, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }