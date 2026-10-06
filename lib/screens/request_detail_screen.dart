import 'package:flutter/material.dart';

class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Detail")),
      body: const Center(child: Text("Request Detail - Working")),
    );
  }
  
  // Dummy to fix build
  void showReportChartSheet() {}
}