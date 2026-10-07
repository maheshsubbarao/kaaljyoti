import 'package:flutter/material.dart';
import '../pdf/pw.dart' as pw;
import '../l10n/astro_l10n.dart';
import '../widgetsystem/astro_module.dart';
import 'common.dart';

String _title(AppLocalizations l10n) => 'Astro Events';

class AstroEventsModule extends AstroModule {
  const AstroEventsModule();

  @override
  ModuleMeta get meta => const ModuleMeta(
        id: 'astro_events',
        title: 'Astro Events',
        localizedTitle: _title,
        icon: Icons.auto_awesome,
        category: 'Predictive',
      );

  @override
  List<ModuleConfigChoice> configChoices(AppLocalizations l10n) => [];

  @override
  Widget cardView(BuildContext context, ModuleContext ctx) {
    return _Body(ctx: ctx, detail: false);
  }

  @override
  Widget detailView(BuildContext context, ModuleContext ctx) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _Body(ctx: ctx, detail: true),
    );
  }

  @override
  List<pw.Widget> pdfView(ModuleContext ctx) {
    return pdfSection(
      header: pdfSectionHeader('Astro Events - 11 Techniques'),
      lead: null,
      rest: [
        pw.Text(
          'Dasha Change, Transit, Solar Arc, Sade Sati, Ashtakavarga, Yoga Activation, Varshphal, Eclipse, Nakshatra Transit, Dasha-Antara Switch, Lunar Events',
          style: pdfBody(),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final ModuleContext ctx;
  final bool detail;
  const _Body({required this.ctx, required this.detail});

  @override
  Widget build(BuildContext context) {
    final list = [
      '🔥 1. Dasha Sandhi - MD/AD Change',
      '🪐 2. Gochar Transit',
      '☀️ 3. Solar Arc',
      '🌙 4. Sade Sati',
      '⭐ 5. Ashtakavarga',
      '💫 6. Yoga Activation',
      '📅 7. Varshphal Entry',
      '⚡ 8. Eclipse Impact',
      '🌟 9. Nakshatra Transit',
      '🔮 10. Dasha-Antar Switch',
      '🌗 11. Lunar Events',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('11 Predictive Techniques', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        for (int i = 0; i < (detail? list.length : 3); i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(list[i]),
          ),
        if (!detail) const Text('+8 more in detail ->', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
