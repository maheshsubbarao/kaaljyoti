import 'package:flutter/material.dart';

class ResearchLabModule {
  static const String id = 'research_lab';
  static const String name = 'Research Lab';
  static const IconData icon = Icons.science_outlined;
}

class ResearchLabScreen extends StatelessWidget {
  const ResearchLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Lab'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: 'Jyotish Research',
            subtitle: 'Analyze planetary combinations & yogas',
            icon: Icons.auto_graph,
            color: Colors.orange,
          ),
          _buildCard(
            title: 'Muhurta Lab',
            subtitle: 'Test auspicious timings',
            icon: Icons.access_time_filled,
            color: Colors.blue,
          ),
          _buildCard(
            title: 'Chart Comparison',
            subtitle: 'Compare multiple charts',
            icon: Icons.compare,
            color: Colors.purple,
          ),
          _buildCard(
            title: 'Research Notes',
            subtitle: 'Your private research journal',
            icon: Icons.note_alt,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required IconData icon, required Color color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}