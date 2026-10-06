import 'package:flutter/services.dart';

class JyotishChart {
  final String name; final int day, month, year, hour, minute, second;
  final int tzHour, tzMin; final String place; final double lon, lat;
  JyotishChart({required this.name, required this.day, required this.month, required this.year, required this.hour, required this.minute, required this.second, required this.tzHour, required this.tzMin, required this.place, required this.lon, required this.lat});
  Map<String, dynamic> toKundliJson()=>{'name':name,'day':day,'month':month,'year':year,'hour':hour,'minute':minute,'second':second,'tzHour':tzHour,'tzMin':tzMin,'place':place,'longitude':lon,'latitude':lat};
}

class JyotishTxtImporter {
  static JyotishChart? parseLine(String line){
    try{
      if(!line.contains(":::")) return null;
      final parts=line.split(":::");
      final name=parts[0].trim();
      final d=parts[1].split("#");
      if(d.length<16) return null;
      int day=int.parse(d[0]); int month0=int.parse(d[1]); int month=month0+1; int year=int.parse(d[2]);
      int hour=int.parse(d[3]); int minute=int.parse(d[4]); int second=int.parse(d[5]);
      int tzH=int.parse(d[6]); int tzM=int.parse(d[7]); String place=d[9];
      int lonDeg=int.parse(d[10]); int lonMin=int.parse(d[11]); int lonSec=int.parse(d[12]);
      double lon=lonDeg+lonMin/60.0+lonSec/3600.0;
      int latDeg=int.parse(d[13]); int latMin=int.parse(d[14]); int latSec=int.parse(d[15]);
      double lat=latDeg+latMin/60.0+latSec/3600.0;
      return JyotishChart(name:name,day:day,month:month,year:year,hour:hour,minute:minute,second:second,tzHour:tzH,tzMin:tzM,place:place,lon:lon,lat:lat);
    }catch(e){return null;}
  }
  static Future<List<JyotishChart>> loadAllFromAssets() async {
    final content=await rootBundle.loadString('assets/JyotishAppCharts.txt');
    List<JyotishChart> charts=[];
    for(var line in content.split('\n')){final c=parseLine(line); if(c!=null) charts.add(c);}
    return charts;
  }
}
