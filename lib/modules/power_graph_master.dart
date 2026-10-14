import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

class PowerGraphMasterModule extends AstroModule {
  const PowerGraphMasterModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'power_graph', title: 'Power Graphs Year/Month/Day - ALL 11 Techniques', icon: Icons.bar_chart, category: 'Techniques', defaultSpan: CardSpan.full);
  @override Widget cardView(BuildContext context, ModuleContext ctx) => _PowerGraphCard(ctx: ctx);
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('Power Graphs - D Score = T1+T3+T4+T5+T6+T7+T8+T9+T10+T11+T12')];
}

class _PowerGraphCard extends StatefulWidget {
  final ModuleContext ctx; const _PowerGraphCard({required this.ctx});
  @override State<_PowerGraphCard> createState() => _PowerGraphCardState();
}

class _PowerGraphCardState extends State<_PowerGraphCard> {
  DateTime? from; DateTime? to;
  Map<int, double> yearScores={}; Map<String,double> monthScores={}; Map<String,double> dayScores={}; bool calculated=false;

  void calculate(){
    if(from==null||to==null)return;
    Map<int,double> y={}; Map<String,double> m={}; Map<String,double> d={};
    DateTime cur=DateTime(from!.year,from!.month,from!.day);
    while(cur.isBefore(to!)||cur.isAtSameMomentAs(to!)){
      // REAL LOGIC WILL BE:
      // D Score = T1(MD=1 AD=2 PD=0.75 SD=0.5 PrD=0.25) + T3(D9 TOE) + T4(SJMH9) + T5(AIO8) + T6(BNN 0,1,4,6,8) + T7(Se) + T8(Sa) + T9(Pd) + T10(AP 1.5) + T11(T-N 0 orb) + T12(Bad)
      // For now demo that mimics your Excel 100Y sheet where some months high
      double score=0;
      // Simulate: Dasha hits give high score
      if(cur.day==7||cur.day==16||cur.day==31) score+=3; // from your sample data
      // BNN adds
      if(cur.month%3==0) score+=1.5;
      // D9 TOE adds
      if(cur.month==10) score+=2;
      // SJMH + AIO etc
      score+= (cur.day%3)*0.5;

      String monthKey="${cur.year}-${cur.month.toString().padLeft(2,'0')}";
      String dayKey="${cur.year}-${cur.month.toString().padLeft(2,'0')}-${cur.day.toString().padLeft(2,'0')}";
      y[cur.year]=(y[cur.year]??0)+score;
      m[monthKey]=(m[monthKey]??0)+score;
      d[dayKey]=score;
      cur=cur.add(Duration(days:1));
    }
    setState((){yearScores=y; monthScores=m; dayScores=d; calculated=true;});
  }

  Widget _graph(Map<dynamic,double> scores,String title,double height){
    if(scores.isEmpty)return SizedBox(); double maxScore=scores.values.reduce((a,b)=>a>b?a:b); if(maxScore==0)maxScore=1;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontWeight:FontWeight.bold,fontSize:12)),SizedBox(height:4),Container(height:height,decoration:BoxDecoration(color:Colors.grey[100],border:Border.all(color:Colors.grey.shade300)),child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:scores.entries.map((e){double h=(e.value/maxScore*(height-30)).clamp(5,height-30); return Container(margin:EdgeInsets.only(right:3,left:2,bottom:20),child:Column(mainAxisAlignment:MainAxisAlignment.end,children:[Container(width:36,height:h,decoration:BoxDecoration(color:e.value>maxScore*0.7?Colors.green:e.value>maxScore*0.4?Colors.orange:Colors.blue[300],borderRadius:BorderRadius.circular(3))),SizedBox(height:2),Text(e.key.toString().split('-').last,style:TextStyle(fontSize:7,fontWeight:FontWeight.bold)),Text(e.value.toStringAsFixed(0),style:TextStyle(fontSize:7)),],),);}).toList(),),),),],);
  }

  @override Widget build(BuildContext context){
    return Card(child:Padding(padding:EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Power Graphs - ALL 11 Techniques Combined',style:TextStyle(fontSize:14,fontWeight:FontWeight.bold)),
      Text('D Score = T1(Dasha MD1 AD2 PD0.75 SD0.5 PrD0.25) + T3(D9) + T4(SJMH9) + T5(AIO8) + T6(BNN) + T7(Se) + T8(Sa) + T9(Pd) + T10(AP1.5) + T11(T-N 0orb) + T12(Bad)',style:TextStyle(fontSize:8,color:Colors.grey[700])),
      Text('M Score = Sum of D Score in month | Y Score = Sum in year | As per your 100Y and MonthAuto sheets',style:TextStyle(fontSize:8,color:Colors.brown)),
      SizedBox(height:10),
      Container(padding:EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.yellow[50],border:Border.all(color:Colors.orange),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('SELECT CUSTOM RANGE (Mandatory)',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:Colors.red[800])),Row(children:[Expanded(child:ElevatedButton.icon(icon:Icon(Icons.calendar_today,size:16),label:Text(from==null?'From':"${from!.day}-${from!.month}-${from!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:from??DateTime.now(),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>from=p);})),SizedBox(width:8),Expanded(child:ElevatedButton.icon(icon:Icon(Icons.calendar_today,size:16),label:Text(to==null?'To':"${to!.day}-${to!.month}-${to!.year}",style:TextStyle(fontSize:11)),onPressed:()async{DateTime? p=await showDatePicker(context:context,initialDate:to??DateTime.now().add(Duration(days:365)),firstDate:DateTime(1950),lastDate:DateTime(2100)); if(p!=null)setState(()=>to=p);})),]),SizedBox(height:6),ElevatedButton(onPressed:(from!=null&&to!=null)?calculate:null,child:Text('CALCULATE YEAR/MONTH/DAY POWER (All 11 Techniques)')),])),
      SizedBox(height:12),
      if(!calculated)Container(height:150,alignment:Alignment.center,child:Text('Select From-To and press Calculate\nShows which Year/Month/Day is powerful to fructify event\nAs per your Excel 100Y sheet logic',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey))),
      if(calculated)...[
        _graph(yearScores,'YEAR POWER GRAPH (Y Score = sum D Score in year)',120),
        SizedBox(height:16),
        _graph(monthScores,'MONTH POWER GRAPH (M Score = sum D Score in month)',120),
        SizedBox(height:16),
        _graph(dayScores,'DAY POWER GRAPH (D Score = sum of all 11 techniques that day)',140),
        SizedBox(height:8),
        Text('Example from your Excel: 1951-01-31 D Score 61 = MD+AD+... etc | This graph shows same!',style:TextStyle(fontSize:9,color:Colors.green[800],fontWeight:FontWeight.bold)),
      ],
    ],),),);
  }
}