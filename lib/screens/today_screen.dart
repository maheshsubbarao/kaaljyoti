import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today")),
      body: const Center(
        child: Text("Today Screen - Working"),
      ),
    );
  }
}

class TransitPositionsTable extends StatelessWidget {
  final Map<dynamic, dynamic> positions;
  final double ascendant;
  const TransitPositionsTable({super.key, required this.positions, required this.ascendant});
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}