import 'package:flutter/material.dart';

class ResearchLabModule extends StatelessWidget {
  const ResearchLabModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Lab Module'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLabCard(
            icon: Icons.biotech,
            title: 'Blood Test Analysis',
            desc: 'Advanced research on blood samples',
            color: Colors.redAccent,
          ),
          _buildLabCard(
            icon: Icons.science,
            title: 'Microbiology Lab',
            desc: 'Bacteria and virus research',
            color: Colors.blueAccent,
          ),
          _buildLabCard(
            icon: Icons.medication,
            title: 'Drug Research',
            desc: 'New medicine testing',
            color: Colors.green,
          ),
          _buildLabCard(
            icon: Icons.analytics,
            title: 'Data Research',
            desc: 'Lab reports and analytics',
            color: Colors.orange,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Research Lab Module Connected Successfully!')),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Activate Lab Module'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCard({required IconData icon, required String title, required String desc, required Color color}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}