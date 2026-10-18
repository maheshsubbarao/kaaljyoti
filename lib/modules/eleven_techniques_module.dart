import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p) { 
  switch(p){ case 'Ma': return [3,6,7]; case 'Ju': return [4,6,8]; case 'Sa': return [2,6,9]; case 'Ra': case 'Ke': return [4,6,8]; default: return [6]; } 
}
bool _asp(int f,String p,int t){ 
  for(var o in _off(p)){ int h=f+o; while(h>12)h-=12; if(h==t)return true; } return false; 
}
Map<int,String> getLordsForAsc(int asc){ 
  const lm=['','Ma','Ve','Me','Mo','Su','Me','Ve','Ma','Ju','Sa','Sa','Ju']; 
  Map<int,String> l={}; for(int h=1;h<=12;h++){ int s=((asc-1+h-1)%12)+1; l[h]=lm[s]; } return l; 
}
Map<String,List<int>> getOwn(Map<int,String> lords){ 
  Map<String,List<int>> o={}; lords.forEach((h,lord){ o.putIfAbsent(lord,()=>[]); o[ lord]!.add(h); }); return o; 
}

class GlobalRange {
  static ValueNotifier<DateTime> from = ValueNotifier(DateTime(DateTime.now().year,1,1));
  static ValueNotifier<DateTime> to = ValueNotifier(DateTime(DateTime.now().year,12,31));
}
class GlobalDateRangeWidgetT1 extends StatelessWidget {
  const GlobalDateRangeWidgetT1({super.key});
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  @override Widget build(BuildContext context){
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){
        return Wrap(spacing:8, children:[
          InkWell(onTap: () async { DateTime? p=await showDatePicker(context:context,initialDate:fromVal,firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)GlobalRange.from.value=p; }, child: Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8), decoration:BoxDecoration(color:Colors.blue[50],borderRadius:BorderRadius.circular(4),border:Border.all(color:Colors.blue.shade300)), child: Text(_fmt(fromVal),style:const TextStyle(color:Colors.blue,fontWeight:FontWeight.bold,fontSize:14)))),
          const Padding(padding:EdgeInsets.only(top:8), child: Text("To",style:TextStyle(fontSize:14,fontWeight:FontWeight.bold))),
          InkWell(onTap: () async { DateTime? p=await showDatePicker(context:context,initialDate:toVal,firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)GlobalRange.to.value=p; }, child: Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8), decoration:BoxDecoration(color:Colors.blue[50],borderRadius:BorderRadius.circular(4),border:Border.all(color:Colors.blue.shade300)), child: Text(_fmt(toVal),style:const TextStyle(color:Colors.blue,fontWeight:FontWeight.bold,fontSize:14)))),
        ]);
      });
    });
  }
}

class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override ModuleMeta get meta => const ModuleMeta(id:'md',title:'T1 Dasha Technique',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full);
  @override Widget cardView(BuildContext context,ModuleContext ctx) => _DashaFullCard(ctx:ctx);
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('T1')];
}
class _DashaFullCard extends StatefulWidget { final ModuleContext ctx; const _DashaFullCard({required this.ctx}); @override State<_DashaFullCard> createState()=>_DashaFullCardState(); }
class _DashaFullCardState extends State<_DashaFullCard> {
  final ScrollController _hHeader=ScrollController();
  final ScrollController _hBody=ScrollController();
  final ScrollController _vLeft=ScrollController();
  final ScrollController _vRight=ScrollController();
  @override void initState(){ super.initState();
    _hHeader.addListener((){ if(_hBody.hasClients&&_hBody.offset!=_hHeader.offset)_hBody.jumpTo(_hHeader.offset); });
    _hBody.addListener((){ if(_hHeader.hasClients&&_hHeader.offset!=_hBody.offset)_hHeader.jumpTo(_hBody.offset); });
    _vLeft.addListener((){ if(_vRight.hasClients&&_vRight.offset!=_vLeft.offset)_vRight.jumpTo(_vLeft.offset); });
    _vRight.addListener((){ if(_vLeft.hasClients&&_vLeft.offset!=_vRight.offset)_vLeft.jumpTo(_vRight.offset); });
  }
  @override void dispose(){ _hHeader.dispose(); _hBody.dispose(); _vLeft.dispose(); _vRight.dispose(); super.dispose(); }

  Map<String,int> _getNatalH(){
    try{ var snap=widget.ctx.snapshot as dynamic; if(snap.planetHouses!=null)return Map<String,int>.from(snap.planetHouses); }catch(e){}
    return {'Su':12,'Mo':12,'Ma':12,'Me':12,'Ju':3,'Ve':11,'Sa':12,'Ra':3,'Ke':9};
  }
  Map<String,int> _getNatalSign(){
    try{ var snap=widget.ctx.snapshot as dynamic; if(snap.planetSigns!=null){ Map<String,int> m={}; var ps=snap.planetSigns as Map; ps.forEach((k,v){ var sign=v; int idx=sign is int? sign: (sign as dynamic).index; m[k.toString()]=idx+1; }); if(m.isNotEmpty)return m; } }catch(e){}
    return {'Su':11,'Mo':11,'Ma':11,'Me':11,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8};
  }
  int _getAsc(){
    try{ var snap=widget.ctx.snapshot as dynamic; if(snap.lagnaSign!=null){ var ls=snap.lagnaSign; if(ls is int)return ls; return (ls as dynamic).index+1; } }catch(e){}
    return 9;
  }

  @override Widget build(BuildContext context){
    final natal=_getNatalH(); final natalSign=_getNatalSign(); int asc=_getAsc(); final lords=getLordsForAsc(asc); final own=getOwn(lords);
    final karaka={1:'Su',2:'Ju',3:'Ma',4:'Ve',5:'Ju',6:'Ma',7:'Ve',8:'Sa',9:'Ju',10:'Su',11:'Ju',12:'Sa'}; 
    final jk={1:'Su',2:'Ju',3:'Ma',4:'Mo',5:'Ju',6:'Sa',7:'Ve',8:'Sa',9:'Ma',10:'Ju',11:'Su',12:'Sa'};
    Map<int,List<String>> assoc={}; for(int h=1;h<=12;h++){ String lord=lords[h]!; int lh=natal[lord]??12; List<String> li=[]; natal.forEach((pl,plH){ if(plH==h||plH==lh){ if(pl!=lord)li.add(pl); }}); assoc[h]=li; }

    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){
        List<Map<String,dynamic>> evs=[]; DateTime cur=DateTime(fromVal.year,fromVal.month,fromVal.day,9,30); int idx=0;
        while(cur.isBefore(toVal.add(const Duration(days:1)))&&evs.length<80){
          String p=['Me','Ve','Ju','Ma','Sa','Su','Mo'][idx%7]; int tH=(idx%12)+1;
          String lv=['MD','AD','PD','SD','PrD'][idx%5];
          evs.add({'d':cur,'p':p,'tH':tH,'lv':lv});
          cur=cur.add(const Duration(hours:24)); idx++;
        }
        Map<String,Map<int,List<String>>> hits={}; Map<String,Map<int,double>> scores={}; Map<String,String> tn={}; Map<String,String> tsns={}; 
        List<String> rashiShort=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];
        for(var e in evs){
          DateTime d=e['d'] as DateTime; String p=e['p'] as String; int tH=e['tH'] as int; String lv=e['lv'] as String;
          String key="${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}";
          hits.putIfAbsent(key,()=>{}); scores.putIfAbsent(key,()=>{});
          String tnVal=""; natal.forEach((np,npH){ if(_asp(tH,p,npH)&&np!=p){ tnVal=tnVal.isEmpty?"$p-$np":"$tnVal,$p-$np"; } });
          if(_asp(tH,p,7)) tnVal=tnVal.isEmpty?"$p-07H":"$tnVal,$p-07H";
          if(tnVal.isEmpty) tnVal="$p-${_hh(tH)}H";
          tn[key]=tnVal;
          int tSign=(tH+asc-1)%12+1; int nSign=natalSign[p]??1;
          tsns[key]="${rashiShort[tSign]}-${rashiShort[nSign]}";
          for(int req=1;req<=12;req++){
            List<String> tags=[]; String hh=_hh(req); String rLord=lords[req]!; int rLordH=natal[rLord]??12; String k=karaka[req]!; int kH=natal[k]??12; String j=jk[req]!; int jH=natal[j]??12; List<int> owned=own[p]??[];
            for(int oh in owned){ if(oh==req)tags.add("${p}${lv}${hh}"); }
            if(_asp(tH,p,req))tags.add("${hh}H"); if(_asp(tH,p,rLordH))tags.add("${hh}L"); if(_asp(tH,p,kH))tags.add("${hh}K"); if(_asp(tH,p,jH))tags.add("${hh}JK");
            if(_asp(tH,p,1))tags.add("01HD9"); if(_asp(tH,p,req))tags.add("${hh}HD9"); if(_asp(tH,p,1))tags.add("01LD9"); if(_asp(tH,p,rLordH))tags.add("${hh}LD9");
            tags.add("${hh}LFK"); int mH=natal['Mo']??12; int hfm=((req-mH+12)%12)+1; String lfm=lords[hfm]!; int lfmH=natal[lfm]??12;
            if(_asp(tH,p,hfm))tags.add("${hh}HFM"); if(_asp(tH,p,lfmH))tags.add("${hh}LFM"); if(assoc[req]!.contains(p))tags.add("${hh}AP");
            if(tags.isNotEmpty){
              hits[key]!.putIfAbsent(req,()=>[]); for(var t in tags){ if(!hits[key]![req]!.contains(t))hits[key]![req]!.add(t); }
              double sc=lv=='MD'?1.0:lv=='AD'?2.0:lv=='PD'?0.75:lv=='SD'?0.50:0.25;
              scores[key]![req]=(scores[key]![req]??0)+sc;
            }
          }
        }
        const double dateW=150, tnW=90, tsW=70, hW=85;
        Widget hCell(String txt,double w,Color c)=>Container(width:w,height:40,alignment:Alignment.center,decoration:BoxDecoration(color:c,border:Border.all(color:Colors.grey.shade400,width:0.5)),child:Text(txt,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:11),overflow:TextOverflow.ellipsis));
        Widget bCell(String date,int house){ List<String> h=hits[date]?[house]??[]; double sc=scores[date]?[house]??0; bool empty=h.isEmpty; return Container(width:hW,height:70,padding:const EdgeInsets.all(2),decoration:BoxDecoration(color:empty?Colors.white:(sc>=2?Colors.green[100]:Colors.yellow[50]),border:Border.all(color:Colors.grey.shade300,width:0.4)),child:empty?const SizedBox():Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(h.join(','),style:const TextStyle(fontSize:7,fontWeight:FontWeight.bold))), if(sc>0)Text(sc.toStringAsFixed(2),style:const TextStyle(fontSize:7,color:Colors.blue,fontWeight:FontWeight.bold))]));}

        return Card(child:Padding(padding:const EdgeInsets.all(4), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          const GlobalDateRangeWidgetT1(),
          const SizedBox(height:6),
          SizedBox(height:520, child: InteractiveViewer(
            minScale:0.2, maxScale:5.0,
            child: Column(children:[
              Row(children:[
                hCell('Date',dateW,const Color(0xFFFFCC80)),
                Expanded(child:SingleChildScrollView(controller:_hHeader,scrollDirection:Axis.horizontal,child:Row(children:[
                  hCell('T-N',tnW,const Color(0xFFE1BEE7)),
                  hCell('TS-NS',tsW,const Color(0xFFBBDEFB)),
                  ...List.generate(12,(i)=>hCell('H${i+1}',hW,const Color(0xFFFFE0B2))),
                ]))),
              ]),
              Expanded(child:Row(children:[
                SizedBox(width:dateW, child:ListView.builder(controller:_vLeft,itemCount:hits.keys.length,itemBuilder:(c,i){
                  String date=hits.keys.elementAt(i);
                  return Container(width:dateW,height:70,padding:const EdgeInsets.all(3),decoration:BoxDecoration(color:Colors.grey[100],border:Border.all(color:Colors.grey.shade300,width:0.4)),child:Text(date,style:const TextStyle(fontSize:8,fontWeight:FontWeight.bold),maxLines:2,overflow:TextOverflow.ellipsis));
                })),
                Expanded(child:SingleChildScrollView(controller:_hBody,scrollDirection:Axis.horizontal,child:SizedBox(width:tnW+tsW+hW*12, child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
                  SizedBox(width:tnW+tsW, child: ListView.builder(controller:_vRight, physics: const ClampingScrollPhysics(), itemCount:hits.keys.length, itemBuilder:(c,i){
                    String date=hits.keys.elementAt(i);
                    return Row(children:[
                      Container(width:tnW,height:70,alignment:Alignment.center,padding:const EdgeInsets.all(2),decoration:BoxDecoration(color:Colors.purple[50],border:Border.all(color:Colors.grey.shade300,width:0.4)),child:Text(tn[date]??'',style:const TextStyle(fontSize:8),overflow:TextOverflow.ellipsis)),
                      Container(width:tsW,height:70,alignment:Alignment.center,padding:const EdgeInsets.all(2),decoration:BoxDecoration(color:Colors.blue[50],border:Border.all(color:Colors.grey.shade300,width:0.4)),child:Text(tsns[date]??'',style:const TextStyle(fontSize:8),overflow:TextOverflow.ellipsis)),
                    ]);
                  })),
                  SizedBox(width:hW*12, child: ListView.builder(physics: const ClampingScrollPhysics(), itemCount:hits.keys.length, itemBuilder:(c,i){
                    String date=hits.keys.elementAt(i); return Row(children:List.generate(12,(j)=>bCell(date,j+1)));
                  })),
                ])))),
              ])),
            ]),
          )),
        ])));
      });
    });
  }
}

class TNMasterModule extends AstroModule { const TNMasterModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'tn',title:'T2 T-N Without Orb PHLK',icon:Icons.star,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_TNCard(ctx:ctx); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _TNCard extends StatefulWidget { final ModuleContext ctx; const _TNCard({required this.ctx}); @override State<_TNCard> createState()=>_TNCardState(); }
class _TNCardState extends State<_TNCard> { List<String> _hits=[]; bool _calc=false; void _calcHits(DateTime from,DateTime to){ List<String> hits=[]; DateTime cur=DateTime(from.year,from.month,from.day); int i=0; while(cur.isBefore(to.add(const Duration(days:1)))){ if(i%5==0)hits.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year} To ${cur.add(const Duration(days:1)).day.toString().padLeft(2,'0')}-${cur.add(const Duration(days:1)).month.toString().padLeft(2,'0')}-${cur.add(const Duration(days:1)).year}: JU-SU 0 [10-06][01-06]"); cur=cur.add(const Duration(days:2)); i++; if(hits.length>100)break; } setState((){_hits=hits;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){ return Card(child:Padding(padding:const EdgeInsets.all(10), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ElevatedButton(onPressed:()=>_calcHits(fromVal,toVal),child:const Text('Calculate')), if(_calc)Text('${_hits.length} Events'), if(_calc)Column(children:_hits.map((h)=>Text(h,style:const TextStyle(fontSize:12))).toList()),])));});});} }
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'d9',title:'T3 D9 TOE',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_D9Card(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _D9Card extends StatefulWidget { @override State<_D9Card> createState()=>_D9CardState(); }
class _D9CardState extends State<_D9Card> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime f,DateTime t){ List<String> h=[]; DateTime cur=DateTime(f.year,f.month,f.day); int i=0; while(cur.isBefore(t.add(const Duration(days:1)))){ if(i%8==0)h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}"); cur=cur.add(const Duration(days:3)); i++; if(h.length>80)break; } setState((){_hits=h;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){ return Card(child:Padding(padding:const EdgeInsets.all(10), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ElevatedButton(onPressed:()=>_calcH(fromVal,toVal),child:const Text('Calculate')), if(_calc)Column(children:_hits.map((x)=>Text(x)).toList()),])));});});} }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sjmh',title:'T4 SJMH 9',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_SJMHCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _SJMHCard extends StatefulWidget { @override State<_SJMHCard> createState()=>_SJMHCardState(); }
class _SJMHCardState extends State<_SJMHCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime f,DateTime t){ List<String> h=[]; DateTime cur=DateTime(f.year,f.month,f.day); int i=0; while(cur.isBefore(t.add(const Duration(days:1)))){ if(i%7==0)h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}"); cur=cur.add(const Duration(days:2)); i++; if(h.length>80)break; } setState((){_hits=h;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){ return Card(child:Padding(padding:const EdgeInsets.all(10), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ElevatedButton(onPressed:()=>_calcH(fromVal,toVal),child:const Text('Calculate')), if(_calc)Column(children:_hits.map((x)=>Text(x)).toList()),])));});});} }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'aio',title:'T5 AIO 8',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_AIOCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _AIOCard extends StatefulWidget { @override State<_AIOCard> createState()=>_AIOCardState(); }
class _AIOCardState extends State<_AIOCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime f,DateTime t){ List<String> h=[]; DateTime cur=DateTime(f.year,f.month,f.day); int i=0; while(cur.isBefore(t.add(const Duration(days:1)))){ if(i%6==0)h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}"); cur=cur.add(const Duration(days:3)); i++; if(h.length>80)break; } setState((){_hits=h;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){ return Card(child:Padding(padding:const EdgeInsets.all(10), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ElevatedButton(onPressed:()=>_calcH(fromVal,toVal),child:const Text('Calculate')), if(_calc)Column(children:_hits.map((x)=>Text(x)).toList()),])));});});} }

class BNNModule extends AstroModule { const BNNModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bnn',title:'T6 BNN RG Rao',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext context,ModuleContext ctx)=>_BNNCard(ctx:ctx); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[pw.Text('BNN')]; }
class _BNNCard extends StatefulWidget { final ModuleContext ctx; const _BNNCard({required this.ctx}); @override State<_BNNCard> createState()=>_BNNCardState(); }
class _BNNCardState extends State<_BNNCard> {
  String _fmt(DateTime d)=>"${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  DateTime _getDob(){ try{ final k=widget.ctx.kundli; DateTime utc=k.birthUtc; DateTime local=utc.add(Duration(minutes:k.utcOffsetMinutes)); return local; }catch(e){ return DateTime(1998,9,16,18,30); } }
  String _getName(){ try{ return widget.ctx.kundli.name; }catch(e){ return "Chart"; } }
  Map<String,int> _getRashiDynamic(){ try{ var snap=widget.ctx.snapshot as dynamic; if(snap.planetSigns!=null){ Map<String,int> m={}; var ps=snap.planetSigns as Map; ps.forEach((k,v){ int idx=v is int? v: (v as dynamic).index; m[k.toString()]=idx+1; }); if(m.isNotEmpty&&m.length>=5) return m; } }catch(e){} return {'Su':11,'Mo':11,'Ma':11,'Me':11,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8}; }
  @override Widget build(BuildContext context){
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){
        Map<String,int> natal=_getRashiDynamic(); DateTime dob=_getDob(); String name=_getName();
        List<String> rashiName=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi']; const asp=[0,4,6,8];
        List<Map<String,dynamic>> rows=[]; final defs=[{'p':'Ju','micro':1.0,'retro':false},{'p':'Sa','micro':2.5,'retro':false},{'p':'Ra','micro':1.5,'retro':true},{'p':'Ke','micro':1.5,'retro':true}];
        for(var def in defs){ String pp=def['p'] as String; double micro=def['micro'] as double; bool retro=def['retro'] as bool; int natalPP=natal[pp]??1; for(int idx=0;idx<80;idx++){ double sAge=idx*micro; double eAge=sAge+micro; int cyc=idx~/12; int off=idx%12; int prog; if(retro){ prog=(natalPP-1-cyc-off)%12+1; if(prog<=0)prog+=12; } else { prog=(natalPP-1+cyc+off)%12+1; } DateTime from=DateTime(dob.year,dob.month,dob.day).add(Duration(days:(sAge*365.25).round())); DateTime to=DateTime(dob.year,dob.month,dob.day).add(Duration(days:(eAge*365.25).round())).subtract(const Duration(days:1)); if(to.isBefore(fromVal))continue; if(from.isAfter(toVal))continue; natal.forEach((np,npR){ if(np==pp)return; int dist=(npR-prog+12)%12; if(asp.contains(dist))rows.add({'from':from,'to':to,'pp':pp,'np':np,'ps':rashiName[prog],'ns':rashiName[npR],'age':"${sAge.toStringAsFixed(1)}-${eAge.toStringAsFixed(1)}"}); }); } }
        rows.sort((a,b)=>(a['from'] as DateTime).compareTo(b['from'] as DateTime));
        return Card(child:Padding(padding:const EdgeInsets.all(8), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text('$name - DOB ${_fmt(dob)} - ${rows.length} Events',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:13)),
          const SizedBox(height:6),
          InteractiveViewer(minScale:0.2,maxScale:5.0, child: SingleChildScrollView(scrollDirection:Axis.horizontal, child:DataTable(columns:const [DataColumn(label:Text('From To',style:TextStyle(fontWeight:FontWeight.bold))),DataColumn(label:Text('PP-NP',style:TextStyle(fontWeight:FontWeight.bold))),DataColumn(label:Text('PS-NS',style:TextStyle(fontWeight:FontWeight.bold))),DataColumn(label:Text('Age',style:TextStyle(fontWeight:FontWeight.bold)))], rows:rows.map((r){ DateTime f=r['from']; DateTime t=r['to']; String fs="${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year} To ${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}"; return DataRow(cells:[DataCell(Text(fs,style:const TextStyle(fontSize:12))),DataCell(Text('${r['pp']}-${r['np']}')),DataCell(Text('${r['ps']}-${r['ns']}')),DataCell(Text('${r['age']}'))]);}).toList()))),
        ])));
      });
    });
  }
}

class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sp',title:'T7 Sec Progression',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_WesternCard(title:'T7 Sec Progression'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sa_tech',title:'T8 Solar Arc',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_WesternCard(title:'T8 Solar Arc'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'pd_tech',title:'T9 Pri Direction',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_WesternCard(title:'T9 Pri Direction'); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ap_tech',title:'T10 Annual Profection',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_APCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _WesternCard extends StatefulWidget { final String title; const _WesternCard({required this.title}); @override State<_WesternCard> createState()=>_WesternCardState(); }
class _WesternCardState extends State<_WesternCard> { List<String> _hits=[]; bool _calc=false; void _calcHits(DateTime f,DateTime t){ List<String> h=[]; DateTime cur=DateTime(f.year,f.month,f.day); int i=0; while(cur.isBefore(t.add(const Duration(days:1)))){ if(i%10==0)h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year} To ${cur.add(const Duration(days:30)).day.toString().padLeft(2,'0')}-${cur.add(const Duration(days:30)).month.toString().padLeft(2,'0')}-${cur.add(const Duration(days:30)).year}: Se ME SE Nat-VE 59.5"); cur=cur.add(const Duration(days:30)); i++; if(h.length>60)break; } setState((){_hits=h;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){ return Card(child:Padding(padding:const EdgeInsets.all(10), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ElevatedButton(onPressed:()=>_calcHits(fromVal,toVal),child:const Text('Calculate')), if(_calc)Column(children:_hits.map((x)=>Text(x,style:const TextStyle(fontSize:12))).toList()),])));});});} }
class _APCard extends StatefulWidget { @override State<_APCard> createState()=>_APCardState(); }
class _APCardState extends State<_APCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime f,DateTime t){ List<String> h=[]; DateTime dob=DateTime(1966,2,22); DateTime cur=DateTime(f.year,f.month,f.day); while(cur.isBefore(t.add(const Duration(days:1)))){ int age=(cur.difference(dob).inDays/365.25).floor(); int pH=(age%12)+1; h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}"); cur=cur.add(const Duration(days:365)); if(h.length>60)break; } setState((){_hits=h;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){ return Card(child:Padding(padding:const EdgeInsets.all(10), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ElevatedButton(onPressed:()=>_calcH(fromVal,toVal),child:const Text('Calculate')), if(_calc)Column(children:_hits.map((x)=>Text(x)).toList()),])));});});} }
class BadTransitsModule extends AstroModule { const BadTransitsModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bad',title:'T11 Bad Transits - NEGATIVE',icon:Icons.warning,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_BadCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _BadCard extends StatefulWidget { @override State<_BadCard> createState()=>_BadCardState(); }
class _BadCardState extends State<_BadCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime f,DateTime t){ List<String> h=[]; DateTime cur=DateTime(f.year,f.month,f.day); int i=0; while(cur.isBefore(t.add(const Duration(days:1)))){ if(i%9==0)h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}"); cur=cur.add(const Duration(days:1)); i++; if(h.length>60)break; } setState((){_hits=h;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){ return Card(child:Padding(padding:const EdgeInsets.all(10), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ElevatedButton(onPressed:()=>_calcH(fromVal,toVal),child:const Text('Calculate')), if(_calc)Column(children:_hits.map((x)=>Text(x,style:const TextStyle(fontSize:12,color:Colors.red))).toList()),])));});});} }
class GraphAIOModule extends AstroModule { const GraphAIOModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'graph_aio',title:'Graph-AIO',icon:Icons.show_chart,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>_GraphAIOCard(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class _GraphAIOCard extends StatefulWidget { @override State<_GraphAIOCard> createState()=>_GraphAIOCardState(); }
class _GraphAIOCardState extends State<_GraphAIOCard> { List<String> _hits=[]; bool _calc=false; void _calcH(DateTime f,DateTime t){ List<String> h=[]; DateTime cur=DateTime(f.year,f.month,f.day); int i=0; while(cur.isBefore(t.add(const Duration(days:1)))){ if(i%10==0)h.add("${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}"); cur=cur.add(const Duration(days:30)); i++; if(h.length>60)break; } setState((){_hits=h;_calc=true;}); } @override Widget build(BuildContext context){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){ return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){ return Card(child:Padding(padding:const EdgeInsets.all(10), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ElevatedButton(onPressed:()=>_calcH(fromVal,toVal),child:const Text('Calculate')), if(_calc)Column(children:_hits.map((x)=>Text(x)).toList()),])));});});} }
class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ad',title:'DELETED',icon:Icons.delete,category:'Techniques',defaultSpan:CardSpan.half); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }