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
String _lordOfSign(int sign){ const lm=['','Ma','Ve','Me','Mo','Su','Me','Ve','Ma','Ju','Sa','Sa','Ju']; return lm[sign]; }
int _d9Sign(double lon){
  int rashi = (lon~/30)+1;
  double deg = lon%30;
  int navIndex = (deg*9/30).floor();
  int movable=[1,4,7,10].contains(rashi)?0: [2,5,8,11].contains(rashi)?1:2;
  int start= movable==0? rashi : movable==1? ((rashi+8-1)%12)+1 : ((rashi+4-1)%12)+1;
  int d9 = ((start-1+navIndex)%12)+1;
  return d9;
}
double _d9Lon(double lon){
  int d9sign=_d9Sign(lon);
  double deg=lon%30;
  double navDeg = (deg*9)%30;
  return (d9sign-1)*30+navDeg;
}

class GlobalRange {
  static ValueNotifier<DateTime> from = ValueNotifier(DateTime(DateTime.now().year,DateTime.now().month,1));
  static ValueNotifier<DateTime> to = ValueNotifier(DateTime(DateTime.now().year,DateTime.now().month+1,0));
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
  @override ModuleMeta get meta => const ModuleMeta(id:'md',title:'T1 T-N Aspects',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full);
  @override Widget cardView(BuildContext context,ModuleContext ctx) => _DashaFullCard(ctx:ctx);
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('T1 T-N Aspects')];
}

class _DashaFullCard extends ConsumerStatefulWidget { 
  final ModuleContext ctx; 
  const _DashaFullCard({required this.ctx}); 
  @override ConsumerState<_DashaFullCard> createState()=>_DashaFullCardState(); 
}

class _DashaFullCardState extends ConsumerState<_DashaFullCard> {
  int _houseFromLong(double lon, ChalitData d){
    for(int h=0;h<12;h++){ double s1=d.sandhi[h]; double s2=d.sandhi[(h+1)%12]; if(s1<s2){ if(lon>=s1&&lon<s2)return h+1; } else { if(lon>=s1||lon<s2)return h+1; } }
    return 12;
  }
  bool _isTri(double natalD9, double transitLon){
    double diff=(natalD9-transitLon)%360; if(diff<0)diff+=360; int h=(diff/30).floor(); return h==0||h==4||h==8;
  }

  @override Widget build(BuildContext context){
    final snap=widget.ctx.snapshot;
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){
        List<Map<String,dynamic>> rows=[];
        Map<String,double> bestDiffMap={};
        try{
          final chalitData=computeChalit(snap, ChalitSystem.sripati);
          Map<String,int> natalH={}; 
          try{ var m=(snap as dynamic).planetHouses; if(m!=null)natalH=Map<String,int>.from(m); }catch(e){}
          if(natalH.isEmpty)natalH={'Su':12,'Mo':12,'Ma':12,'Me':12,'Ju':3,'Ve':11,'Sa':12,'Ra':3,'Ke':9};
          Map<String,double> natalLon={}; 
          try{ snap.positions.forEach((pl,pos){ String ab=_planetToAbbr(pl); natalLon[ab]=pos.longitude; }); }catch(e){}
          int asc=9; 
          try{ var ls=snap.lagnaSign; asc=ls is int? ls: (ls as dynamic).index+1; }catch(e){}
          final lords=getLordsForAsc(asc); 
          final own=getOwn(lords);
          final karaka={1:'Su',2:'Ju',3:'Ma',4:'Ve',5:'Ju',6:'Ma',7:'Ve',8:'Sa',9:'Ju',10:'Su',11:'Ju',12:'Sa'};
          int moonSign = natalLon.containsKey('Mo') ? ((natalLon['Mo']! ~/30)+1) : 11;
          
          Map<int,double> natalLordD9={};
          for(int req=1;req<=12;req++){
            String lord=lords[req]!;
            double lon=natalLon[lord]??0;
            natalLordD9[req]=_d9Lon(lon);
          }
          
          int daysTotal = toVal.difference(fromVal).inDays+1;
          if(daysTotal>366) daysTotal=366;
          if(daysTotal<1) daysTotal=1;
          
          for(int dayIdx=0; dayIdx<daysTotal; dayIdx++){
            DateTime curDay = DateTime(fromVal.year,fromVal.month,fromVal.day).add(Duration(days:dayIdx));
            DateTime cur = DateTime(curDay.year,curDay.month,curDay.day,8,52);
            try{
              var tPos=transit.currentTransitPositions(ayanamsaId: snap.ayanamsaId, at: cur);
              Map<String,double> tLonMap={};
              Map<String,int> tHouseMap={};
              for(var e in tPos.values){
                String ab=_planetToAbbr(e.planet);
                tLonMap[ab]=e.longitude;
                tHouseMap[ab]=_houseFromLong(e.longitude, chalitData);
              }
              
              for(var tEntry in tPos.values){
                String tpAb=_planetToAbbr(tEntry.planet);
                double tLon=tEntry.longitude; 
                int tHouse=tHouseMap[tpAb]??_houseFromLong(tLon, chalitData);
                for(var nEntry in snap.positions.entries){
                  String npAb=_planetToAbbr(nEntry.key);
                  double nLon=nEntry.value.longitude;
                  int nHouse=natalH[npAb]??_houseFromLong(nLon, chalitData);
                  double tDeg=tLon%30; double nDeg=nLon%30;
                  double diff=(tDeg-nDeg).abs(); if(diff>15)diff=30-diff;
                  if(diff<1.5 && _asp(tHouse,tpAb,nHouse)){
                    String dayKey="${curDay.day}-${curDay.month}-${curDay.year}-${tpAb}-${npAb}";
                    double prevBest = bestDiffMap[dayKey] ?? 999;
                    if(diff < prevBest){
                      bestDiffMap[dayKey]=diff;
                      String dateStr="${curDay.day.toString().padLeft(2,'0')}-${curDay.month.toString().padLeft(2,'0')}-${curDay.year} ${cur.hour.toString().padLeft(2,'0')}:${cur.minute.toString().padLeft(2,'0')}";
                      String tnVal="$tpAb-$npAb";
                      List<String> rashiShort=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];
                      int tSign=(tLon~/30)+1; int nSign=(nLon~/30)+1;
                      String tsnsVal="${rashiShort[tSign]}-${rashiShort[nSign]}";
                      Map<int,List<String>> houseTags={};
                      for(int req=1;req<=12;req++){
                        List<String> tags=[];
                        if((own[tpAb]??[]).contains(req)) tags.add("${tpAb}AD${_hh(req)}");
                        if(tHouse==req) tags.add("${tpAb}-${_hh(req)}H");
                        String rLord=lords[req]!; int rLordH=natalH[rLord]??12;
                        String k=karaka[req]!; int kH=natalH[k]??12;
                        int kSign = natalLon.containsKey(k) ? ((natalLon[k]! ~/30)+1) : 1;
                        int lfkSign = ((kSign-1+req-1)%12)+1;
                        String lfkLord = _lordOfSign(lfkSign);
                        int lfkLordH = natalH[lfkLord]??12;
                        int hfmSign = ((moonSign-1+req-1)%12)+1;
                        int hfmSignHouse = ((hfmSign - asc + 12)%12)+1;
                        String lfmLord = _lordOfSign(hfmSign);
                        int lfmLordH = natalH[lfmLord]??12;
                        int hfkSign = ((kSign-1+req-1)%12)+1;
                        int hfkHouse = ((hfkSign - asc +12)%12)+1;

                        if(_asp(tHouse,tpAb,req))tags.add("${_hh(req)}H");
                        if(_asp(tHouse,tpAb,rLordH))tags.add("${_hh(req)}L");
                        if(_asp(tHouse,tpAb,kH)){ tags.add("${_hh(req)}K"); tags.add("${_hh(req)}JK"); }
                        if(_asp(tHouse,tpAb,lfkLordH))tags.add("${_hh(req)}LFK");
                        if(_asp(tHouse,tpAb,hfkHouse))tags.add("${_hh(req)}HFK");
                        if(_asp(tHouse,tpAb,hfmSignHouse))tags.add("${_hh(req)}HFM");
                        if(_asp(tHouse,tpAb,lfmLordH))tags.add("${_hh(req)}LFM");
                        
                        double d9Deg=natalLordD9[req]??0;
                        double tVe=tLonMap['Ve']??0; double tMa=tLonMap['Ma']??0; double tJu=tLonMap['Ju']??0; double tSa=tLonMap['Sa']??0; double tRa=tLonMap['Ra']??0; double tKe=tLonMap['Ke']??0;
                        if(req==1 && _isTri(d9Deg,tJu)) tags.add("D901");
                        if(req==2 && _isTri(d9Deg,tJu)) tags.add("D902");
                        if(req==3 && _isTri(d9Deg,tJu)) tags.add("D903");
                        if(req==4){
                          if(_isTri(d9Deg,tSa)) tags.add("D904FB");
                          if(_isTri(d9Deg,tVe)||_isTri(d9Deg,tMa)||_isTri(d9Deg,tJu)) tags.add("D904VPM");
                        }
                        if(req==5 && _isTri(d9Deg,tJu)) tags.add("D905");
                        if(req==6){ if(_isTri(d9Deg,tMa)||_isTri(d9Deg,tSa)||_isTri(d9Deg,tRa)||_isTri(d9Deg,tKe)) tags.add("D906"); }
                        if(req==7 && _isTri(d9Deg,tJu)) tags.add("D907");
                        if(req==8 && _isTri(d9Deg,tSa)) tags.add("D908");
                        if(req==9 && _isTri(d9Deg,tJu)) tags.add("D909");
                        if(req==10 && _isTri(d9Deg,tJu)) tags.add("D910");
                        if(req==11){ if(_isTri(d9Deg,tJu)) tags.add("D911"); if(_isTri(d9Deg,tSa)) tags.add("D911MB"); }
                        if(req==12){ if(_isTri(d9Deg,tRa)) tags.add("D912GB"); if(_isTri(d9Deg,tJu)) tags.add("D912FT"); }
                        
                        if(tags.isNotEmpty)houseTags[req]=tags.toSet().take(15).toList();
                      }
                      int existingIdx = rows.indexWhere((r)=> r['key']==dayKey);
                      if(existingIdx>=0){
                        rows[existingIdx]={'key':dayKey,'date':dateStr,'tn':tnVal,'tsns':tsnsVal,'tags':houseTags,'diff':diff};
                      } else {
                        rows.add({'key':dayKey,'date':dateStr,'tn':tnVal,'tsns':tsnsVal,'tags':houseTags,'diff':diff});
                      }
                    }
                  }
                }
              }
              
              for(var tEntry in tPos.values){
                String tpAb=_planetToAbbr(tEntry.planet);
                int tHouse=tHouseMap[tpAb]??1;
                double tLon=tLonMap[tpAb]??0;
                for(int h=1;h<=12;h++){
                  if(_asp(tHouse,tpAb,h)){
                    String dayKey="${curDay.day}-${curDay.month}-${curDay.year}-${tpAb}-${h}H";
                    if(bestDiffMap.containsKey(dayKey)) continue;
                    List<String> rashiShort=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi'];
                    int tSign=(tLon~/30)+1;
                    int houseSign=((asc-1+h-1)%12)+1;
                    String tsnsVal="${rashiShort[tSign]}-${rashiShort[houseSign]}";
                    String dateStr="${curDay.day.toString().padLeft(2,'0')}-${curDay.month.toString().padLeft(2,'0')}-${curDay.year} ${cur.hour.toString().padLeft(2,'0')}:${cur.minute.toString().padLeft(2,'0')}";
                    String tnVal="$tpAb-${_hh(h)}H";
                    Map<int,List<String>> houseTags={};
                    List<String> d9tags=[];
                    double d9Deg=natalLordD9[h]??0;
                    double tVe=tLonMap['Ve']??0; double tMa=tLonMap['Ma']??0; double tJu=tLonMap['Ju']??0; double tSa=tLonMap['Sa']??0; double tRa=tLonMap['Ra']??0; double tKe=tLonMap['Ke']??0;
                    if(h==1 && _isTri(d9Deg,tJu)) d9tags.add("D901");
                    if(h==2 && _isTri(d9Deg,tJu)) d9tags.add("D902");
                    if(h==3 && _isTri(d9Deg,tJu)) d9tags.add("D903");
                    if(h==4){
                      if(_isTri(d9Deg,tSa)) d9tags.add("D904FB");
                      if(_isTri(d9Deg,tVe)||_isTri(d9Deg,tMa)||_isTri(d9Deg,tJu)) d9tags.add("D904VPM");
                    }
                    if(h==5 && _isTri(d9Deg,tJu)) d9tags.add("D905");
                    if(h==6){ if(_isTri(d9Deg,tMa)||_isTri(d9Deg,tSa)||_isTri(d9Deg,tRa)||_isTri(d9Deg,tKe)) d9tags.add("D906"); }
                    if(h==7 && _isTri(d9Deg,tJu)) d9tags.add("D907");
                    if(h==8 && _isTri(d9Deg,tSa)) d9tags.add("D908");
                    if(h==9 && _isTri(d9Deg,tJu)) d9tags.add("D909");
                    if(h==10 && _isTri(d9Deg,tJu)) d9tags.add("D910");
                    if(h==11){ if(_isTri(d9Deg,tJu)) d9tags.add("D911"); if(_isTri(d9Deg,tSa)) d9tags.add("D911MB"); }
                    if(h==12){ if(_isTri(d9Deg,tRa)) d9tags.add("D912GB"); if(_isTri(d9Deg,tJu)) d9tags.add("D912FT"); }
                    houseTags[h]=["${_hh(h)}H", ...d9tags];
                    bestDiffMap[dayKey]=0;
                    rows.add({'key':dayKey,'date':dateStr,'tn':tnVal,'tsns':tsnsVal,'tags':houseTags,'diff':0.0});
                  }
                }
              }
              
            }catch(e){}
          }
        }catch(e){}
        
        rows.sort((a,b){
          try{
            List<String> pa=(a['date'] as String).split(' ')[0].split('-');
            List<String> pb=(b['date'] as String).split(' ')[0].split('-');
            DateTime da=DateTime(int.parse(pa[2]),int.parse(pa[1]),int.parse(pa[0]));
            DateTime dbb=DateTime(int.parse(pb[2]),int.parse(pb[1]),int.parse(pb[0]));
            return da.compareTo(dbb);
          }catch(_){return 0;}
        });

        return Card(child:Padding(padding:const EdgeInsets.all(6), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          const GlobalDateRangeWidgetT1(),
          const SizedBox(height:6),
          Text('${rows.length} Events',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:11,color:Colors.deepOrange)),
          const SizedBox(height:6),
          SizedBox(height:600, child: PinchZoom(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(scrollDirection: Axis.vertical, child: DataTable(
            columnSpacing:12,
            headingRowColor: MaterialStateProperty.all(Colors.orange[100]),
            columns: const [
              DataColumn(label: Text('Date',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('T-N',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('TS-NS',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H1',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H2',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H3',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H4',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H5',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H6',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H7',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H8',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H9',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H10',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H11',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
              DataColumn(label: Text('H12',style: TextStyle(fontWeight: FontWeight.bold,fontSize:11))),
            ],
            rows: rows.map((r){
              Map<int,List<String>> tags=r['tags'] as Map<int,List<String>>;
              List<DataCell> cells=[];
              cells.add(DataCell(Text(r['date'],style:const TextStyle(fontSize:10,fontWeight:FontWeight.bold))));
              cells.add(DataCell(Text(r['tn'],style:const TextStyle(fontSize:10,fontWeight:FontWeight.bold))));
              cells.add(DataCell(Text(r['tsns'],style:const TextStyle(fontSize:10))));
              for(int h=1;h<=12;h++){
                List<String> list=tags[h]??[];
                cells.add(DataCell(Container(
                  constraints: const BoxConstraints(minWidth:65),
                  padding: const EdgeInsets.all(2),
                  child: Text(list.join('\n'),style: TextStyle(fontSize:9,fontWeight:FontWeight.bold,color: list.isEmpty?Colors.grey:Colors.black)),
                )));
              }
              return DataRow(cells:cells);
            }).toList(),
          ))))),
        ])));
      });
    });
  }
}

class TNMasterModule extends AstroModule { const TNMasterModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'tn',title:'T2 Merged',icon:Icons.star,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T2 Merged into T1'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'d9',title:'T3 D9 TOE',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T3'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sjmh',title:'T4 SJMH 9',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T4'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'aio',title:'T5 AIO 8',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T5'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class BNNModule extends AstroModule { const BNNModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bnn',title:'T6 BNN RG Rao',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext context,ModuleContext ctx)=>_BNNCard(ctx:ctx); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[pw.Text('BNN')]; }
class _BNNCard extends StatefulWidget { final ModuleContext ctx; const _BNNCard({required this.ctx}); @override State<_BNNCard> createState()=>_BNNCardState(); }
class _BNNCardState extends State<_BNNCard> {
  String _fmt(DateTime d)=>"${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  DateTime _getDob(){ try{ final k=widget.ctx.kundli; DateTime utc=k.birthUtc; DateTime local=utc.add(Duration(minutes:k.utcOffsetMinutes)); return local; }catch(e){ return DateTime(1998,9,16,18,30); } }
  String _getName(){ try{ return widget.ctx.kundli.name; }catch(e){ return "Chart"; } }
  Map<String,int> _getRashi(){ try{ var snap=widget.ctx.snapshot; Map<String,int> m={}; snap.positions.forEach((planet,pos){ String ab=_planetToAbbr(planet); int sign=(pos.longitude~/30)+1; m[ab]=sign; }); if(m.isNotEmpty&&m.length>=5)return m; }catch(e){} return {'Su':11,'Mo':11,'Ma':11,'Me':11,'Ju':2,'Ve':10,'Sa':11,'Ra':2,'Ke':8}; }
  @override Widget build(BuildContext context){
    Map<String,int> natal=_getRashi(); DateTime dob=_getDob(); String name=_getName();
    List<String> rashiName=['','Ar','Ta','Ge','Cn','Le','Vi','Li','Sc','Sg','Cp','Aq','Pi']; const asp=[0,4,6,8];
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){
        List<Map<String,dynamic>> rows=[]; final defs=[{'p':'Ju','micro':1.0,'retro':false},{'p':'Sa','micro':2.5,'retro':false},{'p':'Ra','micro':1.5,'retro':true},{'p':'Ke','micro':1.5,'retro':true}];
        for(var def in defs){ String pp=def['p'] as String; double micro=def['micro'] as double; bool retro=def['retro'] as bool; int natalPP=natal[pp]??1; for(int idx=0;idx<80;idx++){ double sAge=idx*micro; double eAge=sAge+micro; int cyc=idx~/12; int off=idx%12; int prog; if(retro){ prog=(natalPP-1-cyc-off)%12+1; if(prog<=0)prog+=12; } else { prog=(natalPP-1+cyc+off)%12+1; } DateTime from=DateTime(dob.year,dob.month,dob.day).add(Duration(days:(sAge*365.25).round())); DateTime to=DateTime(dob.year,dob.month,dob.day).add(Duration(days:(eAge*365.25).round())).subtract(const Duration(days:1)); if(to.isBefore(fromVal))continue; if(from.isAfter(toVal))continue; natal.forEach((np,npR){ if(np==pp)return; int dist=(npR-prog+12)%12; if(asp.contains(dist))rows.add({'from':from,'to':to,'pp':pp,'np':np,'ps':rashiName[prog],'ns':rashiName[npR],'age':"${sAge.toStringAsFixed(1)}-${eAge.toStringAsFixed(1)}"}); }); } }
        rows.sort((a,b)=>(a['from'] as DateTime).compareTo(b['from'] as DateTime));
        return Card(child:Padding(padding:const EdgeInsets.all(8), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text('$name - DOB ${_fmt(dob)} - ${rows.length} Events',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:13)),
          const SizedBox(height:6),
          SingleChildScrollView(scrollDirection:Axis.horizontal, child:DataTable(columns:const [DataColumn(label:Text('From To',style:TextStyle(fontSize:12))),DataColumn(label:Text('To',style:TextStyle(fontSize:12))),DataColumn(label:Text('PP-NP')),DataColumn(label:Text('PS-NS')),DataColumn(label:Text('Age'))], rows:rows.map((r){ DateTime f=r['from']; DateTime t=r['to']; String fs="${f.day.toString().padLeft(2,'0')}-${f.month.toString().padLeft(2,'0')}-${f.year} To ${t.day.toString().padLeft(2,'0')}-${t.month.toString().padLeft(2,'0')}-${t.year}"; return DataRow(cells:[DataCell(Text(fs,style:const TextStyle(fontSize:12))),DataCell(Text(_fmt(t),style:const TextStyle(fontSize:12))),DataCell(Text('${r['pp']}-${r['np']}')),DataCell(Text('${r['ps']}-${r['ns']}')),DataCell(Text('${r['age']}'))]);}).toList())),
        ])));
      });
    });
  }
}
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sp',title:'T7 Sec Progression',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T7'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'sa_tech',title:'T8 Solar Arc',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T8'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'pd_tech',title:'T9 Pri Direction',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T9'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ap_tech',title:'T10 Annual Profection',icon:Icons.auto_awesome,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T10'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class BadTransitsModule extends AstroModule { const BadTransitsModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'bad',title:'T11 Bad Transits - NEGATIVE',icon:Icons.warning,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('T11'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class GraphAIOModule extends AstroModule { const GraphAIOModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'graph_aio',title:'Graph-AIO',icon:Icons.show_chart,category:'Techniques',defaultSpan:CardSpan.full); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Graph'))); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }
class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta=>const ModuleMeta(id:'ad',title:'DELETED',icon:Icons.delete,category:'Techniques',defaultSpan:CardSpan.half); @override Widget cardView(BuildContext c,ModuleContext ctx)=>const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx)=>[]; }