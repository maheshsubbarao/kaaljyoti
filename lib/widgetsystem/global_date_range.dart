import 'package:flutter/material.dart';

class GlobalDateRangeWidget extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final Function(DateTime) onFromChanged;
  final Function(DateTime) onToChanged;

  const GlobalDateRangeWidget({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onFromChanged,
    required this.onToChanged,
  });

  String _format(DateTime d) => "${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Custom Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              Text("From: "),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: fromDate, firstDate: DateTime(1900), lastDate: DateTime(2100));
                  if(picked!=null) onFromChanged(picked);
                },
                child: Text(_format(fromDate), style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 16),
              Text("To: "),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: toDate, firstDate: DateTime(1900), lastDate: DateTime(2100));
                  if(picked!=null) onToChanged(picked);
                },
                child: Text(_format(toDate), style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}