import 'package:flutter/material.dart';
class RespondScreen extends StatelessWidget {
  final String requestId;
  const RespondScreen({super.key, required this.requestId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Respond")),
      body: const Center(child: Text("Respond - Working")),
    );
  }
}