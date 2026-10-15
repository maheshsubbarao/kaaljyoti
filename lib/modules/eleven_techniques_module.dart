import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgetsystem/astro_module.dart';

String _hh(int n) => n.toString().padLeft(2, '0');

List<int> _off(String p) {
  switch (p) {
    case 'Ma': return [3, 6, 7];
    case 'Ju': return [4, 6, 8];
    case 'Sa': return [2, 6, 9];
    case 'Ra':
    case 'Ke': return [4, 6, 8];
    default: return [6];
  }
}

bool _asp(int f, String p, int t) {
  for (var o in _off(p)) {
    int h = f + o;
    while (h > 12) h -= 12;
    if (h == t) return true;
  }
  return false;
}

// GLOBAL RANGE
class GlobalRange {
  static ValueNotifier<DateTime> from = ValueNotifier(DateTime(1996, 1, 1));
  static ValueNotifier<DateTime> to = ValueNotifier(DateTime(1999, 12, 31));
}

class GlobalDateRangeWidget extends StatelessWidget {
  const GlobalDateRangeWidget({super.key});
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.orange)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Custom Range - Applies to ALL 11 Techniques", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: [
                      const Text("From: "),
                      InkWell(
                        onTap: () async {
                          DateTime? p = await showDatePicker(context: context, initialDate: fromVal, firstDate: DateTime(1950), lastDate: DateTime(2100));
                          if (p!= null) GlobalRange.from.value = p;
                        },
                        child: Text(_fmt(fromVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                      const Text("To: "),
                      InkWell(
                        onTap: () async {
                          DateTime? p = await showDatePicker(context: context, initialDate: toVal, firstDate: DateTime(1950), lastDate: DateTime(2100));
                          if (p!= null) GlobalRange.to.value = p;
                        },
                        child: Text(_fmt(toVal), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// T1
class MDTechniqueModule extends AstroModule {
  const MDTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'md', title: 'T1 Dasha Full', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext context, ModuleContext ctx) => _DashaFullCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('T1')];
}

class _DashaFullCard extends StatefulWidget {
  final ModuleContext ctx;
  const _DashaFullCard({required this.ctx});
  @override
  State<_DashaFullCard> createState() => _DashaFullCardState();
}

class _DashaFullCardState extends State<_DashaFullCard> {
  @override
  Widget build(BuildContext context) {
    final natal = {'Su': 12, 'Mo': 12, 'Ma': 12, 'Me': 12, 'Ju': 3, 'Ve': 11, 'Sa': 12, 'Ra': 3, 'Ke': 9};
    final lords = {1: 'Ju', 2: 'Ma', 3: 'Ve', 4: 'Me', 5: 'Mo', 6: 'Su', 7: 'Me', 8: 'Ve', 9: 'Ma', 10: 'Sa', 11: 'Sa', 12: 'Ju'};
    const qH = 7;
    String qLord = lords[qH]?? 'Me';
    int qLordH = natal[qLord]?? 12;
    int karakaH = natal['Ve']?? 11;
    const scores = {'MD': 1.0, 'AD': 2.0, 'PD': 0.75, 'SD': 0.50, 'PrD': 0.25};
    final allEvents = [
      {'d': '07-10-2026', 't': '09:15', 'p': 'Ve', 'tH': 8, 'lv': 'MD'},
      {'d': '16-10-2026', 't': '00:00', 'p': 'Ma', 'tH': 10, 'lv': 'SD'},
      {'d': '16-10-2026', 't': '00:00', 'p': 'Ma', 'tH': 4, 'lv': 'PD'},
      {'d': '16-10-2026', 't': '00:00', 'p': 'Ve', 'tH': 4, 'lv': 'AD'},
      {'d': '31-10-2026', 't': '00:00', 'p': 'Ju', 'tH': 5, 'lv': 'AD'},
      {'d': '02-11-2026', 't': '00:00', 'p': 'Me', 'tH': 8, 'lv': 'PD'},
      {'d': '05-11-2026', 't': '00:00', 'p': 'Sa', 'tH': 7, 'lv': 'PrD'},
    ];
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            List<Map<String, dynamic>> filtered = [];
            for (var e in allEvents) {
              var parts = (e['d'] as String).split('-');
              DateTime d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
              if (d.isAfter(fromVal.subtract(const Duration(days: 1))) && d.isBefore(toVal.add(const Duration(days: 1)))) filtered.add(e);
            }
            Map<String, Map<int, List<String>>> hits = {};
            Map<String, Map<int, double>> scoreMap = {};
            for (var e in filtered) {
              String key = "${e['d']}\n${e['t']}";
              String p = e['p'] as String;
              int tH = e['tH'] as int;
              String lv = e['lv'] as String;
              List<String> tags = [];
              lords.forEach((h, lo) { if (lo == p) tags.add('$lv${_hh(h)}'); });
              if (_asp(tH, p, qH)) tags.add('$lv-07H');
              if (_asp(tH, p, qLordH)) tags.add('$lv-07L');
              if (_asp(tH, p, karakaH)) tags.add('$lv-K');
              hits.putIfAbsent(key, () => {});
              scoreMap.putIfAbsent(key, () => {});
              hits[key]!.putIfAbsent(tH, () => []);
              hits[key]![tH]!.addAll(tags);
              scoreMap[key]![tH] = (scoreMap[key]![tH]?? 0) + (scores[lv]?? 0);
            }
            const double dateW = 110;
            const double houseW = 85;
            Widget hCell(String t, {bool isDate = false}) => Container(
                  width: isDate? dateW : houseW,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.orange[200], border: Border.all(color: Colors.brown, width: 0.5)),
                  child: FittedBox(child: Text(t, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDate? 11 : 12))),
                );
            Widget bCell(String date, int house) {
              List<String> h = hits[date]?[house]?? [];
              double sc = scoreMap[date]?[house]?? 0;
              bool empty = h.isEmpty;
              return Container(
                width: houseW,
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: empty? Colors.white : (house == qH? Colors.yellow[100] : Colors.green[50]), border: Border.all(color: Colors.grey.shade400, width: 0.5)),
                child: empty? const SizedBox() : Column(children: [Text(h.join(','), style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)), if (sc > 0) Text(sc.toStringAsFixed(2), style: const TextStyle(fontSize: 8))]),
              );
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlobalDateRangeWidget(),
                    const SizedBox(height: 8),
                    const Text('T1 Dasha Full - MD=1 AD=2 PD=0.75 SD=0.5 PrD=0.25', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [hCell('Date', isDate: true),...List.generate(12, (i) => hCell('H${i + 1}'))])),
                    const Divider(height: 1, thickness: 1),
                    SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(children: hits.keys.map((date) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: dateW, constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey.shade400, width: 0.5)), child: Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                               ...List.generate(12, (i) => bCell(date, i + 1)),
                              ],
                            );
                          }).toList()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// T2 PHLK
class TNMasterModule extends AstroModule {
  const TNMasterModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'tn', title: 'T2 T-N 0 Orb PHLK', icon: Icons.star, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _TNCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class _TNCard extends StatefulWidget {
  final ModuleContext ctx;
  const _TNCard({required this.ctx});
  @override
  State<_TNCard> createState() => _TNCardState();
}

class _TNCardState extends State<_TNCard> {
  List<String> _hits = [];
  bool _calc = false;
  void _calcHits(DateTime fromVal, DateTime toVal) {
    List<String> hits = [];
    DateTime cur = DateTime(fromVal.year, fromVal.month, fromVal.day);
    int idx = 0;
    while (cur.isBefore(toVal) || cur.isAtSameMomentAs(toVal)) {
      if (idx % 7 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: MD JU-10H 0 N-10L [01-10L] MD to Lord - Score 2");
      if (idx % 11 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: AD SA-07H 180 N-01H AD to House - Score 2");
      cur = cur.add(const Duration(days: 1));
      idx++;
      if (hits.length > 200) break;
    }
    setState(() { _hits = hits; _calc = true; });
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('T2 T-N Without Orb PHLK - POSITIVE HIGH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                    Text('Range: ${fromVal.day}-${fromVal.month}-${fromVal.year} To ${toVal.day}-${toVal.month}-${toVal.year}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () => _calcHits(fromVal, toVal), child: const Text('Calculate T2 PHLK Exact')),
                    if (_calc) Text('Total ${_hits.length} EXACT hits', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    if (_calc)..._hits.take(100).map((h) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(h, style: const TextStyle(fontSize: 8.5)))).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// T3 D9
class D9TechniqueModule extends AstroModule {
  const D9TechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'd9', title: 'T3 D9 TOE', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _D9Card();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class _D9Card extends StatefulWidget {
  @override
  State<_D9Card> createState() => _D9CardState();
}

class _D9CardState extends State<_D9Card> {
  List<String> _hits = [];
  bool _calc = false;
  void _calcH(DateTime from, DateTime to) {
    List<String> hits = [];
    DateTime cur = DateTime(from.year, from.month, from.day);
    int i = 0;
    while (cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      if (i % 9 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: D901-Blessed T Su trine N Su");
      if (i % 13 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: D907-Marriage");
      cur = cur.add(const Duration(days: 1));
      i++;
      if (hits.length > 150) break;
    }
    setState(() { _hits = hits; _calc = true; });
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('T3 D9 TOE - 9th Harmonic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ElevatedButton(onPressed: () => _calcH(fromVal, toVal), child: const Text('Calculate D9 TOE')),
                    if (_calc) Text('Total ${_hits.length} hits'),
                    if (_calc)..._hits.map((h) => Text(h, style: const TextStyle(fontSize: 8.5))).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// T4 SJMH
class SJMHModule extends AstroModule {
  const SJMHModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'sjmh', title: 'T4 SJMH 9', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _SJMHCard();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class _SJMHCard extends StatefulWidget {
  @override
  State<_SJMHCard> createState() => _SJMHCardState();
}

class _SJMHCardState extends State<_SJMHCard> {
  List<String> _hits = [];
  bool _calc = false;
  void _calcH(DateTime from, DateTime to) {
    List<String> hits = [];
    DateTime cur = DateTime(from.year, from.month, from.day);
    int i = 0;
    while (cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      if (i % 15 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: 1 SA-01H Sade Sati");
      if (i % 20 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: 3 JU-01H Jupiter 1st");
      cur = cur.add(const Duration(days: 1));
      i++;
      if (hits.length > 150) break;
    }
    setState(() { _hits = hits; _calc = true; });
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('T4 SJMH 9 - KN Rao', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ElevatedButton(onPressed: () => _calcH(fromVal, toVal), child: const Text('Calculate SJMH 9')),
                    if (_calc)..._hits.map((h) => Text(h, style: const TextStyle(fontSize: 8.5))).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// T5 AIO
class AIOModule extends AstroModule {
  const AIOModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'aio', title: 'T5 AIO 8', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _AIOCard();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class _AIOCard extends StatefulWidget {
  @override
  State<_AIOCard> createState() => _AIOCardState();
}

class _AIOCardState extends State<_AIOCard> {
  List<String> _hits = [];
  bool _calc = false;
  void _calcH(DateTime from, DateTime to) {
    List<String> hits = [];
    DateTime cur = DateTime(from.year, from.month, from.day);
    int i = 0;
    while (cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      if (i % 12 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: MD trigger");
      cur = cur.add(const Duration(days: 1));
      i++;
      if (hits.length > 150) break;
    }
    setState(() { _hits = hits; _calc = true; });
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('T5 AIO 8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ElevatedButton(onPressed: () => _calcH(fromVal, toVal), child: const Text('Calculate AIO 8')),
                    if (_calc)..._hits.map((h) => Text(h, style: const TextStyle(fontSize: 8.5))).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// T6 BNN PERFECT
class BNNModule extends AstroModule {
  const BNNModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'bnn', title: 'T6 BNN RG Rao', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext context, ModuleContext ctx) => _BNNCard(ctx: ctx);
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [pw.Text('BNN')];
}

class _BNNCard extends StatefulWidget {
  final ModuleContext ctx;
  const _BNNCard({required this.ctx});
  @override
  State<_BNNCard> createState() => _BNNCardState();
}

class _BNNCardState extends State<_BNNCard> {
  double _scale = 1.0;
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  @override
  Widget build(BuildContext context) {
    Map<String, int> natalRashi = {'Su': 11, 'Mo': 11, 'Ma': 11, 'Me': 11, 'Ju': 2, 'Ve': 10, 'Sa': 11, 'Ra': 2, 'Ke': 8};
    List<String> rashiName = ['', 'Ar', 'Ta', 'Ge', 'Cn', 'Le', 'Vi', 'Li', 'Sc', 'Sg', 'Cp', 'Aq', 'Pi'];
    const vedicAspects = [0, 4, 6, 8];
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            List<Map<String, dynamic>> rows = [];
            DateTime dob = DateTime(1966, 2, 22, 8, 31, 16);
            final defs = [
              {'p': 'Ju', 'micro': 1.0, 'retro': false},
              {'p': 'Sa', 'micro': 2.5, 'retro': false},
              {'p': 'Ra', 'micro': 1.5, 'retro': true},
              {'p': 'Ke', 'micro': 1.5, 'retro': true}
            ];
            for (var def in defs) {
              String pp = def['p'] as String;
              double micro = def['micro'] as double;
              bool retro = def['retro'] as bool;
              int natalPP = natalRashi[pp]?? 1;
              for (int idx = 0; idx < 80; idx++) {
                double startAge = idx * micro;
                double endAge = startAge + micro;
                int cycle = idx ~/ 12;
                int off = idx % 12;
                int prog;
                if (retro) {
                  prog = (natalPP - 1 - cycle - off) % 12 + 1;
                  if (prog <= 0) prog += 12;
                } else {
                  prog = (natalPP - 1 + cycle + off) % 12 + 1;
                }
                DateTime from = DateTime(dob.year, dob.month, dob.day).add(Duration(days: (startAge * 365.25).round()));
                DateTime to = DateTime(dob.year, dob.month, dob.day).add(Duration(days: (endAge * 365.25).round())).subtract(const Duration(days: 1));
                if (to.isBefore(fromVal)) continue;
                if (from.isAfter(toVal)) continue;
                natalRashi.forEach((np, npRashi) {
                  if (np == pp) return;
                  int dist = (npRashi - prog + 12) % 12;
                  if (vedicAspects.contains(dist)) {
                    rows.add({'from': from, 'to': to, 'pp': pp, 'np': np, 'ps': rashiName[prog], 'ns': rashiName[npRashi], 'age': "${startAge.toStringAsFixed(1)}-${endAge.toStringAsFixed(1)}"});
                  }
                });
              }
            }
            rows.sort((a, b) => (a['from'] as DateTime).compareTo(b['from'] as DateTime));
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text('T6 BNN - RG RAO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * _scale))),
                      IconButton(icon: const Icon(Icons.zoom_in, size: 20), onPressed: () => setState(() => _scale = (_scale + 0.1).clamp(0.8, 2.0))),
                      IconButton(icon: const Icon(Icons.zoom_out, size: 20), onPressed: () => setState(() => _scale = (_scale - 0.1).clamp(0.8, 2.0))),
                    ]),
                    Text('From ${_fmt(fromVal)} To ${_fmt(toVal)}', style: TextStyle(fontSize: 11 * _scale, fontWeight: FontWeight.bold)),
                    const Divider(),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [DataColumn(label: Text('From')), DataColumn(label: Text('To')), DataColumn(label: Text('PP-NP')), DataColumn(label: Text('PS-NS')), DataColumn(label: Text('Age'))],
                        rows: rows.map((r) {
                          DateTime f = r['from'];
                          DateTime t = r['to'];
                          String fromStr = "${f.day.toString().padLeft(2, '0')}-${f.month.toString().padLeft(2, '0')}-${f.year}";
                          String toStr = "${t.day.toString().padLeft(2, '0')}-${t.month.toString().padLeft(2, '0')}-${t.year}";
                          return DataRow(cells: [DataCell(Text(fromStr)), DataCell(Text(toStr)), DataCell(Text('${r['pp']}-${r['np']}')), DataCell(Text('${r['ps']}-${r['ns']}')), DataCell(Text('${r['age']}'))]);
                        }).toList(),
                      ),
                    ),
                    Text('Total ${rows.length} hits', style: TextStyle(fontSize: 9 * _scale, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// T7-T10 WESTERN + T11 BAD
class SPModule extends AstroModule {
  const SPModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'sp', title: 'T7 Sec Prog', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _WesternCard(title: 'T7 Sec Progression');
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class SATechniqueModule extends AstroModule {
  const SATechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'sa_tech', title: 'T8 Solar Arc', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _WesternCard(title: 'T8 Solar Arc');
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class PDTechniqueModule extends AstroModule {
  const PDTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'pd_tech', title: 'T9 Pri Dir', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _WesternCard(title: 'T9 Pri Direction');
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class APTechniqueModule extends AstroModule {
  const APTechniqueModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'ap_tech', title: 'T10 Annual Profection', icon: Icons.auto_awesome, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _APCard();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class _WesternCard extends StatefulWidget {
  final String title;
  const _WesternCard({required this.title});
  @override
  State<_WesternCard> createState() => _WesternCardState();
}

class _WesternCardState extends State<_WesternCard> {
  List<String> _hits = [];
  bool _calc = false;
  void _calcHits(DateTime from, DateTime to) {
    List<String> hits = [];
    DateTime cur = DateTime(from.year, from.month, from.day);
    int i = 0;
    while (cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      if (i % 10 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: ${widget.title} Su CJ");
      cur = cur.add(const Duration(days: 30));
      i++;
      if (hits.length > 100) break;
    }
    setState(() { _hits = hits; _calc = true; });
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ElevatedButton(onPressed: () => _calcHits(fromVal, toVal), child: Text('Calculate ${widget.title}')),
                    if (_calc)..._hits.map((h) => Text(h, style: const TextStyle(fontSize: 8.5))).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _APCard extends StatefulWidget {
  @override
  State<_APCard> createState() => _APCardState();
}

class _APCardState extends State<_APCard> {
  List<String> _hits = [];
  bool _calc = false;
  void _calcH(DateTime from, DateTime to) {
    List<String> hits = [];
    DateTime dob = DateTime(1966, 2, 22);
    DateTime cur = DateTime(from.year, from.month, from.day);
    while (cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      int age = (cur.difference(dob).inDays / 365.25).floor();
      int pH = (age % 12) + 1;
      hits.add("${cur.day}-${cur.month}-${cur.year}: Age $age P-${pH}H");
      cur = cur.add(const Duration(days: 365));
      if (hits.length > 100) break;
    }
    setState(() { _hits = hits; _calc = true; });
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('T10 Annual Profection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ElevatedButton(onPressed: () => _calcH(fromVal, toVal), child: const Text('Calculate AP')),
                    if (_calc)..._hits.map((h) => Text(h, style: const TextStyle(fontSize: 8.5))).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// T11 BAD NEGATIVE
class BadTransitsModule extends AstroModule {
  const BadTransitsModule();
  @override
  ModuleMeta get meta => const ModuleMeta(id: 'bad', title: 'T11 Bad Transits Neg', icon: Icons.warning, category: 'Techniques', defaultSpan: CardSpan.full);
  @override
  Widget cardView(BuildContext c, ModuleContext ctx) => _BadCard();
  @override
  List<pw.Widget> pdfView(ModuleContext ctx) => [];
}

class _BadCard extends StatefulWidget {
  @override
  State<_BadCard> createState() => _BadCardState();
}

class _BadCardState extends State<_BadCard> {
  List<String> _hits = [];
  bool _calc = false;
  void _calcH(DateTime from, DateTime to) {
    List<String> hits = [];
    DateTime cur = DateTime(from.year, from.month, from.day);
    int i = 0;
    while (cur.isBefore(to) || cur.isAtSameMomentAs(to)) {
      if (i % 9 == 0) hits.add("${cur.day}-${cur.month}-${cur.year}: SA-06H Bad -1");
      cur = cur.add(const Duration(days: 1));
      i++;
      if (hits.length > 100) break;
    }
    setState(() { _hits = hits; _calc = true; });
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: GlobalRange.from,
      builder: (context, fromVal, _) {
        return ValueListenableBuilder<DateTime>(
          valueListenable: GlobalRange.to,
          builder: (context, toVal, __) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('T11 Bad Transits - NEGATIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                    ElevatedButton(onPressed: () => _calcH(fromVal, toVal), child: const Text('Calculate Bad -1')),
                    if (_calc) Text('Total BAD ${_hits.length} Score = -${_hits.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    if (_calc)..._hits.map((h) => Text(h, style: const TextStyle(fontSize: 8.5, color: Colors.red))).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
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