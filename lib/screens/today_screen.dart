class TransitPositionsTable extends StatelessWidget {
  final Map<Planet, dynamic> positions;
  final double ascendant;
  const TransitPositionsTable({super.key, required this.positions, required this.ascendant});
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        for (final pos in positions.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text((pos as dynamic).planet.label(l10n), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${(pos as dynamic).sign.label(l10n)} ${(pos as dynamic).degreesInSign.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }
}