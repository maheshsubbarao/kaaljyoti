import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

class GlobalRange {
  static ValueNotifier<DateTime> from = ValueNotifier(DateTime(1996, 1, 1));
  static ValueNotifier<DateTime> to = ValueNotifier(DateTime(1999, 12, 31));
}

class GlobalDateRangeWidget extends StatelessWidget {
  const GlobalDateRangeWidget({super.key});
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.from, builder: (context, fromVal, _) {
      return ValueListenableBuilder<DateTime>(valueListenable: GlobalRange.to, builder: (context, toVal, __) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.orange[50], border: Border.all(color: Colors.orange, width: 1.5), borderRadius: BorderRadius.circular(8)),
          child: Wrap(spacing: 12, children: [
            const Text("From:", style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: fromVal, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (p!=null) GlobalRange.from.value = p; }, child: Text(_fmt(fromVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
            const Text("To:", style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: toVal, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (p!=null) GlobalRange.to.value = p; }, child: Text(_fmt(toVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
          ])
        );
      });
    });
  }
}

class ZoomWrapper extends StatelessWidget {
  final Widget child;
  const ZoomWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 1)), child: InteractiveViewer(minScale: 0.3, maxScale: 5.0, child: child));
  }
}

class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'md', title: 'T1 Dasha Technique', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext context, ModuleContext ctx) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [const GlobalDateRangeWidget(), const Text('T1 Dasha Technique - Dynamic')])));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('T1')];
}

class TNMasterModule extends AstroModule {
  const TNMasterModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'tn', title: 'T2 T-N 0 Orb PHLK', icon: Icons.star, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T2')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class D9TechniqueModule extends AstroModule {
  const D9TechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'd9', title: 'T3 D9 TOE', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T3')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class SJMHModule extends AstroModule {
  const SJMHModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'sjmh', title: 'T4 SJMH 9', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T4')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class AIOModule extends AstroModule {
  const AIOModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'aio', title: 'T5 AIO 8', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T5')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class BNNModule extends AstroModule {
  const BNNModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'bnn', title: 'T6 BNN RG Rao', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T6')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('BNN')];
}

class SPModule extends AstroModule {
  const SPModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'sp', title: 'T7 Sec Prog', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T7')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class SATechniqueModule extends AstroModule {
  const SATechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'sa_tech', title: 'T8 Solar Arc', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T8')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class PDTechniqueModule extends AstroModule {
  const PDTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'pd_tech', title: 'T9 Pri Dir', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T9')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class APTechniqueModule extends AstroModule {
  const APTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'ap_tech', title: 'T10 Annual Profection', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T10')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class BadTransitsModule extends AstroModule {
  const BadTransitsModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'bad', title: 'T11 Bad Transits Neg', icon: Icons.warning, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('T11')));
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class ADTechniqueModule extends AstroModule {
  const ADTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'ad', title: 'DELETED', icon: Icons.delete, category: 'Techniques', defaultSpan: CardSpan.half);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => const SizedBox.shrink();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}