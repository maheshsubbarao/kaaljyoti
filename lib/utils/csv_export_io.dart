import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportCsv(String csvContent, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(csvContent);
  await Share.shareXFiles([XFile(file.path)], text: 'T1 Export');
}