import 'package:flutter/material.dart';

class ResearchBoardScreen extends StatelessWidget {
  const ResearchBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Research Board")),
      body: const Center(child: Text("Research Board - Working")),
    );
  }
}