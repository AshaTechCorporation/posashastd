import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<String?> cacheImageLocally(String? imageUrl, String filename) async {
  if (imageUrl == null) return null;
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/images/$filename');
  if (await file.exists()) return file.path;
  await file.parent.create(recursive: true);

  final resp = await http.get(Uri.parse(imageUrl));
  if (resp.statusCode == 200) {
    await file.writeAsBytes(resp.bodyBytes);
    return file.path;
  }
  return null;
}
