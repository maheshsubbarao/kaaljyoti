import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/astro/models.dart';
import '../core/astro/ashtakoota_calculator.dart';
import '../data/models.dart' show Kundli;
import '../state/providers.dart';
import '../ui/common.dart';

class AshtakootaScreen extends ConsumerStatefulWidget {
  const AshtakootaScreen({super.key});
  @override
  ConsumerState<AshtakootaScreen> createState() => _AshtakootaScreenState();
}

class _AshtakootaScreenState extends ConsumerState<AshtakootaScreen> {
  String? _brideId; String? _groomId; bool _hideAyush = true;
  @override
  Widget build(BuildContext context) {
    final kundlis = ref.watch(allKundlisForMatchingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AshtaKoota Guna Milan')),
      body: kundlis.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error $e')),
        data: (list) {
          final sorted = [...list]..sort((a,b)=>a.name.toLowerCase().trim().compareTo(b.name.toLowerCase().trim()));
          return ListView(padding: const EdgeInsets.all(12), children: [
            Row(children: [
              Expanded(child: _KundliPicker(label: "Girl", kundlis: sorted, value: _brideId, onChanged: (id){ if(id!=null) ref.invalidate(snapshotProvider(id)); setState(()=>_brideId=id);},),),
              const SizedBox(width: 12),
              Expanded(child: _KundliPicker(label: "Boy", kundlis: sorted, value: _groomId, onChanged: (id){ if(id!=null) ref.invalidate(snapshotProvider(id)); setState(()=>_groomId=id);},),),
            ]),
            const SizedBox(height: 8),
            if (_brideId != null && _groomId != null)
              AshtakootaBody(brideId: _brideId!, groomId: _groomId!, allKundlis: sorted, hideAyush: _hideAyush, onAyushChanged: (v)=>setState(()=>_hideAyush=v),)
            else const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('Select any two charts')),),
          ]);
        },
      ),
    );
  }
}

class _KundliPicker extends StatelessWidget {
  const _KundliPicker({required this.label, required this.kundlis, required this.value, required this.onChanged});
  final String label; final List<Kundli> kundlis; final String? value; final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    KJSectionLabel(label), const SizedBox(height: 6),
    DropdownButton<String?>(isExpanded: true, value: value, hint: const Text('Choose'), items: [for (final k in (List.of(kundlis)..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())))) DropdownMenuItem(value: k.id, child: Text(k.name, overflow: TextOverflow.ellipsis))], onChanged: onChanged,),
  ],);
}