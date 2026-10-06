class TransitPositionsTable extends StatelessWidget {
  final Map<Planet, dynamic> positions;
  final double ascendant;
  const TransitPositionsTable({super.key, required this.positions, required this.ascendant});
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = positions.values.toList();
    return Column(
      children: [
        for (final dynamic pos in list)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pos.planet.label(l10n), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text("${pos.sign.label(l10n)} ${pos.degreesInSign.toStringAsFixed(1)}°${pos.isRetrograde? ' R' : ''}", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.labelLagna, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text("${(ascendant/30).floor()}", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}