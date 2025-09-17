import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:posashastd/dto/order_dto.dart';

/// เปิด Isar instance
Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [OrderDtoSchema, OrderItemDtoSchema],
    directory: dir.path,
    inspector: true, // เปิด true เวลา debug ก็ได้
  );
}

/// แปลง String ISO8601 เป็น DateTime (nullable)
DateTime? _dtOrNull(dynamic v) {
  if (v == null) return null;
  return DateTime.parse(v as String);
}

/// นี่คือ JSON ต้นฉบับของคุณ (วางได้เลย หรือนำเข้าจากไฟล์/HTTP ก็ได้)
const String rawJson = r'''
{YOUR_JSON_HERE}
''';

/// import หลัก: สร้าง/อัปเดต Category, Unit, Product
// // Future<void> importCatalog(Isar isar, Map<String, dynamic> json) async {
// //   final cats = (json['categories'] as List).cast<Map<String, dynamic>>();
// //   final units = (json['units'] as List).cast<Map<String, dynamic>>();
// //   final prods = (json['products'] as List).cast<Map<String, dynamic>>();

// //   // ——— 1) Upsert Category & Unit ———
// //   final categoryModels = <Category>[];
// //   for (final c in cats) {
// //     categoryModels.add(
// //       Category(
// //         id: (c['id'] as num).toInt(),
// //         code: c['code']?.toString() ?? '',
// //         name: c['name']?.toString() ?? '',
// //         createdAt: DateTime.parse(c['createdAt']),
// //         updatedAt: DateTime.parse(c['updatedAt']),
// //         deletedAt: _dtOrNull(c['deletedAt']),
// //       ),
// //     );
// //   }

// //   final unitModels = <Unit>[];
// //   for (final u in units) {
// //     unitModels.add(
// //       Unit(
// //         id: (u['id'] as num).toInt(),
// //         code: u['code']?.toString() ?? '',
// //         name: u['name']?.toString() ?? '',
// //         createdAt: DateTime.parse(u['createdAt']),
// //         updatedAt: DateTime.parse(u['updatedAt']),
// //         deletedAt: _dtOrNull(u['deletedAt']),
// //       ),
// //     );
// //   }

// //   // ——— 2) Upsert Product ———
// //   final productModels = <Product>[];
// //   for (final p in prods) {
// //     final category = p['category'] as Map<String, dynamic>?;
// //     final unit = p['unit'] as Map<String, dynamic>?;

// //     final categoryId = (category?['id'] as num?)?.toInt();
// //     final unitId = (unit?['id'] as num?)?.toInt();

// //     if (categoryId == null || unitId == null) {
// //       // ข้ามถ้าไม่มี category/unit
// //       continue;
// //     }

// //     productModels.add(
// //       Product(
// //         id: (p['id'] as num).toInt(),
// //         code: p['code']?.toString() ?? '',
// //         name: p['name']?.toString() ?? '',
// //         image: p['image']?.toString(),
// //         imageUrl: p['imageUrl']?.toString(),
// //         price: (p['price'] as num).toDouble(),
// //         cost: (p['cost'] as num).toDouble(),
// //         active: p['active'] == true,
// //         barcode: p['barcode']?.toString(),
// //         remark: p['remark']?.toString(),
// //         showType: p['showType']?.toString(),
// //         color: p['color']?.toString(),
// //         categoryId: categoryId,
// //         unitId: unitId,
// //         createdAt: DateTime.parse(p['createdAt']),
// //         updatedAt: DateTime.parse(p['updatedAt']),
// //         deletedAt: _dtOrNull(p['deletedAt']),
// //       ),
// //     );
// //   }

// //   // ——— 3) เขียนลง Isar (transaction เดียว, replace existing by same id) ———
// //   await isar.writeTxn(() async {
// //     await isar.categorys.putAll(categoryModels); // putAll = upsert
// //     await isar.units.putAll(unitModels);
// //     await isar.products.putAll(productModels);
// //   });
// // }

// // /// ตัวอย่างการเรียกใช้งานใน main หรือในจุด seed ข้อมูล
// // Future<void> seedFromEmbeddedJson() async {
// //   final isar = await openIsar();
// //   final Map<String, dynamic> data = jsonDecode(rawJson) as Map<String, dynamic>;
// //   await importCatalog(isar, data);

// //   // ตัวอย่าง query สั้น ๆ: เอาสินค้าที่ active ในหมวด "ลูกชิ้น"
// //   final meatballCat =
// //       await isar.categorys.filter().codeEqualTo('20000', caseSensitive: false).findFirst();

// //   if (meatballCat != null) {
// //     final activeMeatball = await isar.products
// //         .filter()
// //         .categoryIdEqualTo(meatballCat.id)
// //         .and()
// //         .activeEqualTo(true)
// //         .sortByName() // ใช้ได้เพราะมี index ชื่อ
// //         .findAll();

// //     // debug print
// //     for (final p in activeMeatball) {
// //       // ignore: avoid_print
// //       print('>> ${p.code} ${p.name} : ${p.price}');
// //     }
// //   }
// }
