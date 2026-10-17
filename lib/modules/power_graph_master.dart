import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';
import 'eleven_techniques_module.dart';

class PowerGraphMasterModule extends AstroModule {
  const PowerGraphMasterModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'power_graph', title: 'Graph-AIO', icon: Icons.bar_chart, category: 'Techniques', defaultSpan: CardSpan.full);
  @override Widget cardView(BuildContext context, ModuleContext ctx) => _PowerGraphCard(ctx: ctx);
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('Graph-AIO')];
}

class _PowerGraphCard extends StatefulWidget { final ModuleContext ctx; const _PowerGraphCard({required this.ctx}); @override State<_PowerGraphCard> createState() => _PowerGraphCardState(); }
class _PowerGraphCardState extends State<_PowerGraphCard> {
  Map<int,double> yearScores={}; Map<String,double> monthScores={}; Map<String,double> dayScores={}; bool calculated=false;
  void calculate(DateTime from, DateTime to){
    Map<int,double> y={}; Map<String,double> m={}; Map<String,double> d={};
    DateTime cur=DateTime(from.year,from.month,from.day);
    while(cur.isBefore(to)||cur.isAtSameMomentAs(to)){
      double score=0; if(cur.day==7||cur.day==16||cur.day==31)score+=3; if(cur.month%3==0)score+=1.5; if(cur.month==10)score+=2; score+=(cur.day%3)*0.5;
      String monthKey="${cur.year}-${cur.month.toString().padLeft(2,'0')}"; String dayKey="${cur.year}-${cur.month.toString().padLeft(2,'0')}-${cur.day.toString().padLeft(2,'0')}";
      y[cur.year]=(y[cur.year]??0)+score; m[monthKey]=(m[monthKey]??0)+score; d[dayKey]=score; cur=cur.add(Duration(days:1));
    }
    setState((){yearScores=y; monthScores=m; dayScores=d; calculated=true;});
  }
  Widget _graph(Map<dynamic,double> scores,String title,double height){
    if(scores.isEmpty)return SizedBox(); double maxScore=scores.values.reduce((a,b)=>a>b?a:b); if(maxScore==0)maxScore=1;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontWeight:FontWeight.bold,fontSize:12)),SizedBox(height:4),Container(height:height,decoration:BoxDecoration(color:Colors.grey[100],border:Border.all(color:Colors.grey.shade300)),child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:scores.entries.map((e){double h=(e.value/maxScore*(height-30)).clamp(5,height-30); return Container(margin:EdgeInsets.only(right:3,left:2,bottom:20),child:Column(mainAxisAlignment:MainAxisAlignment.end,children:[Container(width:36,height:h,decoration:BoxDecoration(color:e.value>maxScore*0.7?Colors.green:e.value>maxScore*0.4?Colors.orange:Colors.blue[300],borderRadius:BorderRadius.circular(3))),SizedBox(height:2),Text(e.key.toString().split('-').last,style:TextStyle(fontSize:7,fontWeight:FontWeight.bold)),Text(e.value.toStringAsFixed(0),style:TextStyle(fontSize:7)),],),);}).toList(),),),),],);
  }
  @override Widget build(BuildContext context){
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context,fromVal,_){
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context,toVal,__){
        return Card(child:Padding(padding:EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Graph-AIO - All 11 Combined',style:TextStyle(fontSize:14,fontWeight:FontWeight.bold)),
          SizedBox(height:10),
          ElevatedButton(onPressed:()=>calculate(fromVal,toVal),child:Text('Calculate')),
          SizedBox(height:12),
          if(!calculated)Container(height:100,alignment:Alignment.center,child:Text('Uses Global Date Range from T1\nPress Calculate',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey))),
          if(calculated)...[_graph(yearScores,'YEAR POWER GRAPH',120),SizedBox(height:16),_graph(monthScores,'MONTH POWER GRAPH',120),SizedBox(height:16),_graph(dayScores,'DAY POWER GRAPH',140),],
        ],),),);
      });
    });
  }
}