// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

Future<void> exportCsv(String csvContent, String fileName) async {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}