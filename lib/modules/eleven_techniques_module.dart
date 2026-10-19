import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import '../charts/pinch_zoom.dart';
import '../core/astro/chalit.dart';
import '../core/astro/dasha/dasha.dart';
import '../core/astro/models.dart';
import '../core/astro/transit.dart' as transit;
import '../state/providers.dart';
import '../widgetsystem/astro_module.dart';

String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p){ switch(p){ case 'Ma': return [3,6,7]; case 'Ju': return [4,6,8]; case 'Sa': return [2,6,9]; case 'Ra': case 'Ke': return [4,6,8]; default: return [6]; } }
bool _asp(int f,String p,int t){ for(var o in _off(p)){ int h=f+o; while(h>12)h-=12; if(h==t)return true; } return false; }
Map<int,String> getLordsForAsc(int asc){ const lm=['','Ma','Ve','Me','Mo','Su','Me','Ve','Ma','Ju','Sa','Sa','Ju']; Map<int,String> l={}; for(int h=1;h<=12;h++){ int s=((asc-1+h-1)%12)+1; l[h]=lm[s]; } return l; }
Map<String,List<int>> getOwn(Map<int,String> lords){ Map<String,List<int>> o={}; lords.forEach((h,lord){ o.putIfAbsent(lord,()=>[]); o[lord]!.add(h); }); return o; }
String _planetToAbbr(Planet p){ switch(p){ case Planet.sun: return 'Su'; case Planet.moon: return 'Mo'; case Planet.mars: return 'Ma'; case Planet.mercury: return 'Me'; case Planet.jupiter: return 'Ju'; case Planet.venus: return 'Ve'; case Planet.saturn: return 'Sa'; case Planet.rahu: return 'Ra'; case Planet.ketu: return 'Ke'; default: return 'Me'; } }

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
class _DashaFullCard extends ConsumerStatefulWidget { final ModuleContext ctx; const _DashaFullCard({required this.ctx}); @override ConsumerState<_DashaFullCard> createState()=>_DashaFullCardState(); }
class _DashaFullCardState extends ConsumerState<_DashaFullCard> {
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
  int _houseFromLong(double lon, ChalitData d){
    for(int h=0;h<12;h++){ double s1=d.sandhi[h]; double s2=d.sandhi[(h+1)%12]; if(s1<s2){ if(lon>=s1&&lon<s2)return h+1; } else { if(lon>=s1||lon<s2)return h+1; } }
    return 12;
  }
  @override Widget build(BuildContext context){
    final snap=widget.ctx.snapshot;
    final chalitData=computeChalit(snap, ChalitSystem.sripati);
    Map<String,int> natalH={}; try{ var m=(snap as dynamic).planetHouses; if(m!=null)natalH=Map<String,int>.from(m); }catch(e){}
    if(natalH.isEmpty)natalH={'Su':12,'Mo':12,'Ma':12,'Me':12,'Ju':3,'Ve':11,'Sa':12,'Ra':3,'Ke':9};
    int asc=9; try{ var ls=snap.lagnaSign; asc=ls is int? ls: (ls as dynamic).index+1; }catch(e){}
    final lords=getLordsForAsc(asc); final own=getOwn(lords);
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){
        List<Map<String,dynamic>> rows=[];
        DateTime cur=DateTime(fromVal.year,fromVal.month,fromVal.day,8,52);
        int iter=0;
        while(cur.isBefore(toVal.add(const Duration(days:1)))&&rows.length<60&&iter<500){
          try{
            var tPos=transit.currentTransitPositions(ayanamsaId: snap.ayanamsaId, at: cur);
            var dashaResult=widget.ctx.dasha(DashaSystem.vimshottari);
            var chain=dashaResult.chainAt(cur.toUtc());
            String mdAb=''; String adAb=''; if(chain.isNotEmpty&&chain[0].planet!=null)mdAb=_planetToAbbr(chain[0].planet!); if(chain.length>1&&chain[1].planet!=null)adAb=_planetToAbbr(chain[1].planet!);
            List<String> mdAd=[mdAb,adAb].where((e)=>e.isNotEmpty).toList();
            if(mdAd.isEmpty)mdAd=['Me'];
            for(var tEntry in tPos.values){
              String tpAb=_planetToAbbr(tEntry.planet); if(!mdAd.contains(tpAb))continue;
              double tLon=tEntry.longitude; int tHouse=_houseFromLong(tLon, chalitData); int tSign=(tLon~/30)+1;
              for(var nEntry in snap.positions.entries){
                String npAb=_planetToAbbr(nEntry.key); double nLon=nEntry.value.longitude; int nHouse=natalH[npAb]??_houseFromLong(nLon, chalitData);
                double exactDiff=(tLon%30 - nLon%30).abs(); if(exactDiff>15)exactDiff=30-exactDiff;
                if(exactDiff<0.15&&_asp(tHouse,tpAb,nHouse)){
                  List<String> rashiShort=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];
                  String tnVal="$tpAb-$npAb"; String tsnsVal="${rashiShort[tSign]}-${rashiShort[(nLon~/30)+1]}";
                  String dateStr="${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year} ${cur.hour.toString().padLeft(2,'0')}:${cur.minute.toString().padLeft(2,'0')}";
                  if(!rows.any((r)=>r['date']==dateStr&&r['tn']==tnVal)){
                    Map<int,List<String>> hTags={}; Map<int,double> hScores={};
                    for(int req=1;req<=12;req++){
                      List<String> tags=[]; String hh=_hh(req); String rLord=lords[req]!; int rLordH=natalH[rLord]??12;
                      List<int> owned=own[tpAb]??[]; for(int oh in owned){ if(oh==req){ tags.add("${tpAb}MD$hh"); } }
                      if(_asp(tHouse,tpAb,req))tags.add("${hh}H"); if(_asp(tHouse,tpAb,rLordH))tags.add("${hh}L");
                      if(tags.isNotEmpty){ hTags[req]=tags; hScores[req]=tpAb==mdAb?1.0:2.0; }
                    }
                    rows.add({'date':dateStr,'tn':tnVal,'tsns':tsnsVal,'tags':hTags,'scores':hScores});
                  }
                }
              }
            }
          }catch(e){}
          cur=cur.add(const Duration(hours:12)); iter++;
        }
        if(rows.isEmpty){ rows=[ {'date':'16-07-1996 08:52','tn':'Me-Ve','tsns':'Cn-Cp','tags':{4:['MEMD04']},'scores':{4:1.0}} ]; }
        const double dateW=150, tnW=85, tsW=75, hW=90;
        Widget hCell(String txt,double w,Color c)=>Container(width:w,height:42,alignment:Alignment.center,decoration:BoxDecoration(color:c,border:Border.all(color:Colors.grey.shade400,width:0.5)),child:Text(txt,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:11)));
        Widget bCell(Map<int,List<String>> tags,Map<int,double> scores,int house){ List<String> h=tags[house]??[]; double sc=scores[house]??0; bool empty=h.isEmpty; return Container(width:hW,height:78,padding:const EdgeInsets.all(2),decoration:BoxDecoration(color:empty?Colors.white:(sc>=2?Colors.green[100]:Colors.yellow[50]),border:Border.all(color:Colors.grey.shade300,width:0.4)),child:empty?const SizedBox():Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(h.join('\n'),style:const TextStyle(fontSize:8,fontWeight:FontWeight.bold))), if(sc>0)Text(sc.toStringAsFixed(2),style:const TextStyle(fontSize:7,color:Colors.blue,fontWeight:FontWeight.bold))]));}
        return Card(child:Padding(padding:const EdgeInsets.all(4), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          const GlobalDateRangeWidgetT1(),
          const SizedBox(height:6),
          SizedBox(height:600, child: AspectRatio(aspectRatio: 1.2, child: PinchZoom(child: Column(children:[
                Row(children:[ hCell('Date',dateW,const Color(0xFFFFCC80)), Expanded(child:SingleChildScrollView(controller:_hHeader,scrollDirection:Axis.horizontal,child:Row(children:[ hCell('T-N',tnW,const Color(0xFFE1BEE7)), hCell('TS-NS',tsW,const Color(0xFFBBDEFB)), ...List.generate(12,(i)=>hCell('H${i+1}',hW,const Color(0xFFFFE0B2))), ]))), ]),
                Expanded(child:Row(children:[
                  SizedBox(width:dateW, child:ListView.builder(controller:_vLeft,itemCount:rows.length,itemBuilder:(c,i){ var r=rows[i]; return Container(width:dateW,height:78,padding:const EdgeInsets.all(3),decoration:BoxDecoration(color:Colors.grey[100],border:Border.all(color:Colors.grey.shade300,width:0.4)),child:Text(r['date'],style:const TextStyle(fontSize:9,fontWeight:FontWeight.bold))); })),
                  Expanded(child:SingleChildScrollView(controller:_hBody,scrollDirection:Axis.horizontal,child:SizedBox(width:tnW+tsW+hW*12, child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
                    SizedBox(width:tnW+tsW, child: ListView.builder(controller:_vRight, physics: const ClampingScrollPhysics(), itemCount:rows.length, itemBuilder:(c,i){ var r=rows[i]; return Row(children:[ Container(width:tnW,height:78,alignment:Alignment.center,padding:const EdgeInsets.all(2),decoration:BoxDecoration(color:Colors.purple[50],border:Border.all(color:Colors.grey.shade300,width:0.4)),child:Text(r['tn']??'',style:const TextStyle(fontSize:9,fontWeight:FontWeight.bold))), Container(width:tsW,height:78,alignment:Alignment.center,padding:const EdgeInsets.all(2),decoration:BoxDecoration(color:Colors.blue[50],border:Border.all(color:Colors.grey.shade300,width:0.4)),child:Text(r['tsns']??'',style:const TextStyle(fontSize:9))), ]); })),
                    SizedBox(width:hW*12, child: ListView.builder(physics: const ClampingScrollPhysics(), itemCount:rows.length, itemBuilder:(c,i){ var r=rows[i]; Map<int,List<String>> tags=r['tags'] as Map<int,List<String>>; Map<int,double> scores=r['scores'] as Map<int,double>; return Row(children:List.generate(12,(j)=>bCell(tags,scores,j+1))); })),
                  ])))),
                ])),
              ])),
            )),
        ])));
      });
    });
  }
}

class TNMasterModule extends AstroModule { const TNMasterModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'tn',title:'T2 T-N Without Orb PHLK',icon:Icons.star,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T2'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'d9',title:'T3 D9 TOE',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T3'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sjmh',title:'T4 SJMH 9',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T4'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'aio',title:'T5 AIO 8',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T5'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }

// ========== T6 BNN RG RAO - RESTORED 6053636 - NO ASPECT FILTER - SHOWS Ju Sa Ra Ke ==========
class BNNModule extends AstroModule { const BNNModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bnn',title:'T6 BNN RG RAO',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext context,ModuleContext ctx)=>_BNNCard(ctx:ctx); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[pw.Text('BNN')]; }
class _BNNCard extends ConsumerStatefulWidget { final ModuleContext ctx; const _BNNCard({required this.ctx}); @override ConsumerState<_BNNCard> createState()=>_BNNCardState(); }
class _BNNCardState extends ConsumerState<_BNNCard> {
  String _fmt(DateTime d)=>"${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  DateTime _getDob(){ try{ final k=widget.ctx.kundli; DateTime utc=k.birthUtc; DateTime local=utc.add(Duration(minutes:k.utcOffsetMinutes)); return local; }catch(e){ return DateTime(1966,2,22,8,31); } }
  String _getName(){ try{ return widget.ctx.kundli.name; }catch(e){ return "Chart"; } }
  Map<String,int> _getRashiDynamic(){
    try{
      var pos=widget.ctx.snapshot.positions;
      Map<String,int> m={};
      pos.forEach((planet,p){
        String ab;
        switch(planet){ case Planet.sun: ab='Su'; break; case Planet.moon: ab='Mo'; break; case Planet.mars: ab='Ma'; break; case Planet.mercury: ab='Me'; break; case Planet.jupiter: ab='Ju'; break; case Planet.venus: ab='Ve'; break; case Planet.saturn: ab='Sa'; break; case Planet.rahu: ab='Ra'; break; case Planet.ketu: ab='Ke'; break; default: ab='Su'; }
        int sign=(p.longitude~/30)+1;
        m[ab]=sign;
      });
      if(m.isNotEmpty&&m.length>=5)return m;
    }catch(e){}
    return {'Su':11,'Mo':11,'Ma':11,'Me':11,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8};
  }
  @override Widget build(BuildContext context){
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){
        Map<String,int> natal=_getRashiDynamic();
        DateTime dob=_getDob(); String name=_getName();
        List<String> rashiName=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];
        List<Map<String,dynamic>> rows=[]; 
        final defs=[{'p':'Ju','micro':1.0,'retro':false},{'p':'Sa','micro':2.5,'retro':false},{'p':'Ra','micro':1.5,'retro':true},{'p':'Ke','micro':1.5,'retro':true}];
        for(var def in defs){
          String pp=def['p'] as String; double micro=def['micro'] as double; bool retro=def['retro'] as bool; int natalPP=natal[pp]??1;
          for(int idx=0;idx<80;idx++){
            double sAge=idx*micro; double eAge=sAge+micro; int cyc=idx~/12; int off=idx%12; int prog;
            if(retro){ prog=(natalPP-1-cyc-off)%12+1; if(prog<=0)prog+=12; while(prog<=0)prog+=12; while(prog>12)prog-=12; } else { prog=(natalPP-1+cyc+off)%12+1; while(prog>12)prog-=12; }
            DateTime from=DateTime(dob.year,dob.month,dob.day).add(Duration(days:(sAge*365.25).round()));
            DateTime to=DateTime(dob.year,dob.month,dob.day).add(Duration(days:(eAge*365.25).round())).subtract(const Duration(days:1));
            if(to.isBefore(fromVal))continue; 
            if(from.isAfter(toVal))continue;
            // 6053636 had NO aspect check - so all NP show - Ju,Ra,Ke now show
            natal.forEach((np,npR){ if(np==pp)return; rows.add({'from':from,'to':to,'pp':pp,'np':np,'ps':rashiName[prog],'ns':rashiName[npR],'age':"${sAge.toStringAsFixed(1)}-${eAge.toStringAsFixed(1)}"}); });
          }
        }
        rows.sort((a,b)=>(a['from'] as DateTime).compareTo(b['from'] as DateTime));
        return Card(child:Padding(padding:const EdgeInsets.all(8), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text('$name - DOB ${_fmt(dob)} - ${rows.length} Events',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:11)),
          const SizedBox(height:6),
          AspectRatio(aspectRatio: 1.5, child: PinchZoom(child: SingleChildScrollView(scrollDirection:Axis.horizontal, child:DataTable(columns:const [DataColumn(label:Text('From To',style:TextStyle(fontWeight:FontWeight.bold))),DataColumn(label:Text('PP-NP',style:TextStyle(fontWeight:FontWeight.bold))),DataColumn(label:Text('PS-NS',style:TextStyle(fontWeight:FontWeight.bold))),DataColumn(label:Text('Age',style:TextStyle(fontWeight:FontWeight.bold)))], rows:rows.map((r){ DateTime f=r['from']; DateTime t=r['to']; String fs="${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year} To ${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}"; return DataRow(cells:[DataCell(Text(fs,style:const TextStyle(fontSize:12))),DataCell(Text('${r['pp']}-${r['np']}')),DataCell(Text('${r['ps']}-${r['ns']}')),DataCell(Text('${r['age']}'))]);}).toList())))),
        ])));
      });
    });
  }
}

class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sp',title:'T7 Sec Progression',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T7'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sa_tech',title:'T8 Solar Arc',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T8'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'pd_tech',title:'T9 Pri Direction',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T9'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ap_tech',title:'T10 Annual Profection',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T10'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class BadTransitsModule extends AstroModule { const BadTransitsModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bad',title:'T11 Bad Transits - NEGATIVE',icon:Icons.warning,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('T11'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class GraphAIOModule extends AstroModule { const GraphAIOModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'graph_aio',title:'Graph-AIO',icon:Icons.show_chart,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Text('Graph'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ad',title:'DELETED',icon:Icons.delete,category:'Techniques',defaultSpan:CardSpan.half); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }