import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _h(int n) => 'H$n';
String _hh(int n) => n.toString().padLeft(2,'0');
List<int> _off(String p){ switch(p){ case 'Ma': return [3,6,7]; case 'Ju': return [4,6,8]; case 'Sa': return [2,6,9]; case 'Ra': case 'Ke': return [4,6,8]; default: return [6]; } }
bool _asp(int f,String p,int t){ for(var o in _off(p)){ int h=f+o; while(h>12)h-=12; if(h==t) return true; } return false; }
Widget _card(String t, List<Widget> r) => Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize:12)), const Divider(), ...r])));
Widget _l(String s) => Padding(padding: const EdgeInsets.symmetric(vertical:2), child: Text(s, style: const TextStyle(fontFamily:'monospace', fontSize:10.5)));

class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override ModuleMeta get meta => const ModuleMeta(id: 'md', title: 'MD TAGS', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override Widget cardView(BuildContext context, ModuleContext ctx) {
    final natal={'Su':12,'Mo':12,'Ma':12,'Me':12,'Ju':3,'Ve':11,'Sa':12,'Ra':3,'Ke':9};
    final lords={1:'Ju',2:'Ma',3:'Ve',4:'Me',5:'Mo',6:'Su',7:'Me',8:'Ve',9:'Ma',10:'Sa',11:'Sa',12:'Ju'};
    const moonH=12; const qH=7; // H7 Marriage

    // Base for all tags - short
    String qLord=lords[qH]??'Me'; int qLordH=natal[qLord]??12; int karakaH=natal['Ve']??11;
    int seventhFromMoon=moonH+6; if(seventhFromMoon>12)seventhFromMoon-=12;
    const d9F=8; const d9S=2; // Li H8 = 1st D9, Ar H2 = 7th D9

    List<Widget> rows=[];
    rows.add(_l('H07: H7=Vi L=$qLord·H$qLordH K=Ve·H$karakaH D9:1st=Li·H$d9F 7th=Ar·H$d9S Mo·H$moonH 7thFM=Le·H$seventhFromMoon'));
    rows.add(_l('--------------------------------'));

    final evs=[
      {'d':'07-10-2026 09:15','p':'Ve','tH':8,'sg':'Li','lv':'MD','from':'','to':'Ve'},
      {'d':'16-10-2026 12:23','p':'Ma','tH':10,'sg':'Cp','lv':'SD','from':'Mo','to':'Ma'},
      {'d':'28-10-2026','p':'Ma','tH':1,'sg':'Ar','lv':'TR','note':'8th on Me'},
      {'d':'31-10-2026','p':'Ju','tH':5,'sg':'Cn','lv':'AD','from':'','to':'Ju'},
      {'d':'02-11-2026','p':'Me','tH':8,'sg':'Li','lv':'PD','from':'','to':'Me'},
      {'d':'07-11-2026','p':'Mo','tH':12,'sg':'Aq','lv':'PrD','from':'Ve','to':'Mo'},
    ];

    for(var e in evs){
      String d=e['d'] as String; String p=e['p'] as String; int tH=e['tH'] as int; String sg=e['sg'] as String; String lv=e['lv'] as String;
      if(lv=='TR'){ rows.add(_l('$d $p $sg·${_h(tH)} ${e['note']}')); continue; }
      List<String> tags=[];
      lords.forEach((h,lo){ if(lo==p) tags.add('$lv${_hh(h)}'); });
      if(_asp(tH,p,qH)) tags.add('$lv-07H');
      if(_asp(tH,p,qLordH)) tags.add('$lv-07L');
      if(_asp(tH,p,karakaH)) tags.add('$lv-K');
      if(_asp(tH,p,karakaH)) tags.add('$lv-JK');
      if(_asp(tH,p,d9F)) tags.add('$lv-01HD9');
      if(_asp(tH,p,d9S)) tags.add('$lv-07HD9');
      if(natal['Ve']!=null && _asp(tH,p,natal['Ve']!)) tags.add('$lv-01LD9');
      if(natal['Ma']!=null && _asp(tH,p,natal['Ma']!)) tags.add('$lv-07LD9');
      if(_asp(tH,p,seventhFromMoon)) tags.add('$lv-07HFM');
      if(_asp(tH,p,natal['Su']??12)) tags.add('$lv-07LFM');
      if(_asp(tH,p,qLordH)) tags.add('$lv-AP');

      String from=e['from'] as String; String to=e['to'] as String;
      if(lv=='MD') rows.add(_l('$d $p $sg·${_h(tH)} ${tags.join(',')}'));
      else rows.add(_l('$d $from→$to $p $sg·${_h(tH)} ${tags.join(',')}'));
    }
    return _card('MD/AD/PD/SD/PrD - H07 Short Tags', rows);
  }
  @override List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('TAGS')];
}
class ADTechniqueModule extends AstroModule { const ADTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ad', title: 'AD', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class D9TechniqueModule extends AstroModule { const D9TechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'd9', title: 'D9', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SJMHModule extends AstroModule { const SJMHModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sjmh', title: 'SJMH', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class AIOModule extends AstroModule { const AIOModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'aio', title: 'AIO', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class BNNModule extends AstroModule { const BNNModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'bnn', title: 'BNN', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SPModule extends AstroModule { const SPModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sp', title: 'SP', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class SATechniqueModule extends AstroModule { const SATechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'sa_tech', title: 'SA', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class PDTechniqueModule extends AstroModule { const PDTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'pd_tech', title: 'PD', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class APTechniqueModule extends AstroModule { const APTechniqueModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'ap_tech', title: 'AP', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.half); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
class TNMasterModule extends AstroModule { const TNMasterModule(); @override ModuleMeta get meta => const ModuleMeta(id: 'tn', title: 'TN', icon: Icons.star, category: 'Techniques', defaultSpan: CardSpan.full); @override Widget cardView(BuildContext context, ModuleContext ctx) => const SizedBox.shrink(); @override List<pw.Widget> pdfView(ModuleContext ctx) => []; }
