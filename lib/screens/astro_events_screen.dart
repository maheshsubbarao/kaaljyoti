import 'package:flutter/material.dart';

class AstroEventsScreen extends StatefulWidget {
  const AstroEventsScreen({super.key});
  @override
  State<AstroEventsScreen> createState() => _AstroEventsScreenState();
}

class _AstroEventsScreenState extends State<AstroEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Calendar Months: 01-Oct-2026 to 31-Dec-2026
  DateTime fromDate = DateTime(2026, 10, 1);
  DateTime toDate = DateTime(2026, 12, 31);
  
  int selectedHouse = 7; // Default 7
  String selectedTech = 'ALL';
  
  // Dummy events for now - will connect to Excel later
  List<Map<String, String>> events = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 13, vsync: this, initialIndex: 7);
    _generateEvents();
  }

  void _generateEvents() {
    // Generate sample Astro Events: DD-MM-YYYY  MD-07H format
    List<Map<String, String>> temp = [];
    DateTime cur = fromDate;
    while (cur.isBefore(toDate)) {
      if (cur.day % 5 == 0) { // Sample
        temp.add({
          'date': "${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}",
          'code': "MD-${selectedHouse.toString().padLeft(2,'0')}H",
          'tech': "MD",
        });
      }
      if (cur.day % 7 == 0) {
        temp.add({
          'date': "${cur.day.toString().padLeft(2,'0')}-${cur.month.toString().padLeft(2,'0')}-${cur.year}",
          'code': "AD-${selectedHouse.toString().padLeft(2,'0')}L",
          'tech': "AD",
        });
      }
      cur = cur.add(Duration(days: 1));
    }
    setState(() => events = temp);
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
    );
    if (picked != null) {
      setState(() {
        fromDate = DateTime(picked.start.year, picked.start.month, 1);
        toDate = DateTime(picked.end.year, picked.end.month + 1, 0);
      });
      _generateEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedTech == 'ALL' ? events : events.where((e) => e['tech'] == selectedTech).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Astro Events - Build #19'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (idx) {
            setState(() => selectedHouse = idx == 0 ? 0 : idx);
            _generateEvents();
          },
          tabs: [
            Tab(text: 'ALL'),
            ...List.generate(12, (i) => Tab(text: '${i+1}')),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: OutlinedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text("${fromDate.day.toString().padLeft(2,'0')}-${fromDate.month.toString().padLeft(2,'0')}-${fromDate.year} to ${toDate.day.toString().padLeft(2,'0')}-${toDate.month.toString().padLeft(2,'0')}-${toDate.year}", style: TextStyle(fontFamily: 'monospace')),
              onPressed: _pickRange,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['ALL','MD','AD','BNN','D9 TOE','SJMH 9','AIO 8','Transit'].map((t) {
                return Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(t, style: TextStyle(fontSize: 11)),
                    selected: selectedTech == t,
                    onSelected: (v) => setState(() => selectedTech = t),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, idx) {
                final ev = filtered[idx];
                return ListTile(
                  leading: Icon(Icons.event, color: ev['tech'] == 'MD' ? Colors.orange : Colors.blue),
                  title: Text("${ev['date']}  ${ev['code']}", style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  subtitle: Text("${ev['tech']} • House $selectedHouse"),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.dashboard),
                label: Text('View 12 Houses Dashboard'),
                onPressed: () {
                  // TODO: 12 houses dashboard
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
