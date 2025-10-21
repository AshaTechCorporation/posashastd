import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String?> cacheImageLocal(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) {
    return null;
  }
  
  final dir = await getApplicationDocumentsDirectory();

  final filename = imageUrl.split('/').last;

  final imageFile = File('${dir.path}/images/$filename');

  // ถ้ามีไฟล์อยู่แล้ว ข้ามดาวน์โหลด
  if (!await imageFile.exists()) {
    await imageFile.parent.create(recursive: true);

    final resp = await http.get(Uri.parse(imageUrl));
    if (resp.statusCode == 200) {
      await imageFile.writeAsBytes(resp.bodyBytes);
    } else {
      return null;
    }
  }

  return imageFile.path;
}
