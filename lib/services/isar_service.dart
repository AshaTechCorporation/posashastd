import 'dart:convert';
import 'dart:developer';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:posashastd/constants.dart';
import 'package:posashastd/local_db/category_local.dart';
import 'package:posashastd/local_db/order_local.dart';
import 'package:posashastd/local_db/panel_local.dart';
import 'package:posashastd/local_db/panel_product_local.dart';
import 'package:posashastd/local_db/product_local.dart';
import 'package:posashastd/local_db/shift_local.dart';
import 'package:posashastd/services/auth_service.dart';
import 'package:http/http.dart' as http;

class IsarService {
  // Singleton pattern
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isar;

  // Getter
  Isar? get isar => _isar;

  final _authService = AuthService();

  // เปิด Isar instance
  Future<Isar> openIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        CategoryLocalSchema,
        OrderItemLocalSchema,
        OrderLocalSchema,
        PanelLocalSchema,
        PanelProductLocalSchema,
        ProductLocalSchema,
        ShiftLocalSchema,
      ],
      directory: dir.path,
      inspector: true, // เปิด true เวลา debug ก็ได้
    );
    return _isar!;
  }

  loadData() async {
    final data = await getData();

    await _isar!.writeTxn(() async {
      final List<CategoryLocal> categories = [];
      for (var c in data['categories']) {
        categories.add(
          CategoryLocal()
            ..id = c['id']
            ..code = c['code']
            ..name = c['name']
            ..createdAt = DateTime.parse(c['createdAt'])
            ..updatedAt = DateTime.parse(c['updatedAt'])
            ..deletedAt =
                c['deletedAt'] != null ? DateTime.parse(c['deletedAt']) : null,
        );
      }

      await _isar!.categoryLocals.putAll(categories);

      for (var p in data['products']) {
        final category = categories.firstWhere(
          (c) => c.id == p['category']['id'],
        );

        final product =
            ProductLocal()
              ..id = p['id']
              ..code = p['code']
              ..name = p['name']
              ..imageUrl = p['imageUrl']
              ..price = (p['price'] as num).toDouble()
              ..showType = p['showType']
              ..color = p['color']
              ..category.value = category
              ..createdAt = DateTime.parse(p['createdAt'])
              ..updatedAt = DateTime.parse(p['updatedAt'])
              ..deletedAt =
                  p['deletedAt'] != null
                      ? DateTime.parse(p['deletedAt'])
                      : null;

        await _isar!.productLocals.put(product);
        await product.category.save();
      }

      final panelsJson = (data['panels'] as List?) ?? const [];
      final panelProductsJson = (data['panelProducts'] as List?) ?? const [];
      //save panels
      // 1) Upsert Panels
      for (final p in panelsJson) {
        final panel =
            PanelLocal()
              ..name = p['name']
              ..updatedAt = DateTime.parse(p['updatedAt'])
              ..deletedAt =
                  p['deletedAt'] != null
                      ? DateTime.parse(p['deletedAt'])
                      : null;

        await _isar!.panelLocals.put(panel);
      }

      // 2) Upsert Products + PanelProducts
      for (final pp in panelProductsJson) {
        // ---- Product ----
        final prod = pp['product'] as Map<String, dynamic>?;
        if (prod == null) continue;

        final code = (prod['code'] ?? '').toString().trim();
        if (code.isEmpty) continue;

        ProductLocal? product =
            await isar!.productLocals.filter().codeEqualTo(code).findFirst();
        product ??= ProductLocal();

        product
          ..code = code
          ..name = (prod['name'] ?? '').toString()
          ..imageUrl = (prod['imageUrl'] as String?)
          ..price = (prod['price'] as num).toDouble()
          ..showType = (prod['showType'] as String?)
          ..color = (prod['color'] as String?)
          ..createdAt =
              DateTime.tryParse(prod['createdAt'] ?? '') ?? product.createdAt
          ..updatedAt =
              DateTime.tryParse(prod['updatedAt'] ?? '') ?? DateTime.now()
          ..deletedAt =
              prod['deletedAt'] == null
                  ? null
                  : DateTime.tryParse(prod['deletedAt']);

        final productId = await isar!.productLocals.put(product);

        // ---- Panel (by name) ----
        final pan = pp['panel'] as Map<String, dynamic>?;
        if (pan == null) continue;
        final panelName = (pan['name'] ?? '').toString().trim();
        if (panelName.isEmpty) continue;

        PanelLocal? panel =
            await isar!.panelLocals.filter().nameEqualTo(panelName).findFirst();
        panel ??=
            PanelLocal()
              ..name = panelName
              ..createdAt =
                  DateTime.tryParse(pan['createdAt'] ?? '') ?? DateTime.now()
              ..updatedAt =
                  DateTime.tryParse(pan['updatedAt'] ?? '') ?? DateTime.now()
              ..deletedAt =
                  pan['deletedAt'] == null
                      ? null
                      : DateTime.tryParse(pan['deletedAt']);
        final panelId = await isar!.panelLocals.put(panel);

        // ---- PanelProduct ----
        // คีย์สังเคราะห์กันซ้ำ: "{panelId}:{productId}"
        final uniqueKey = '$panelId:$productId';

        PanelProductLocal? panelProduct =
            await isar!.panelProductLocals
                .filter()
                .uniqueKeyEqualTo(uniqueKey)
                .findFirst();
        panelProduct ??= PanelProductLocal();

        panelProduct
          ..uniqueKey = uniqueKey
          ..color = (pp['color'] as String?)
          ..sequence = (pp['sequence'] ?? 0) as int
          ..createdAt =
              DateTime.tryParse(pp['createdAt'] ?? '') ?? panelProduct.createdAt
          ..updatedAt =
              DateTime.tryParse(pp['updatedAt'] ?? '') ?? DateTime.now()
          ..deletedAt =
              pp['deletedAt'] == null
                  ? null
                  : DateTime.tryParse(pp['deletedAt']);

        // set links
        panelProduct.panel.value = panel;
        panelProduct.product.value = product;

        await isar!.panelProductLocals.put(panelProduct);
        await panelProduct.panel.save();
        await panelProduct.product.save();
      }
    });
  }

  Future<List<CategoryLocal>> getCategories() async {
    return await _isar!.categoryLocals.where().findAll();
  }

  //get panel
  Future<List<PanelLocal>> getPanels() async {
    return await _isar!.panelLocals.where().findAll();
  }

  Future<List<ProductLocal>> getProducts({int? categoryId}) async {
    if (categoryId != null && categoryId > 0) {
      return await _isar!.productLocals
          .filter()
          .category((q) => q.idEqualTo(categoryId))
          .findAll();
    } else {
      return await _isar!.productLocals.where().findAll();
    }
  }

  // ใช้สำหรับหน้า POS: ดึงสินค้าตาม Panel เรียง sequence
  Future<List<ProductLocal>> getProductsOfPanel(String panelName) async {
    final panel = await isar!.panelLocals.filter().nameEqualTo(panelName).findFirst();
    if (panel == null) return [];
    await panel.panelProducts.load();

    final pps =
        panel.panelProducts.where((pp) => pp.deletedAt == null).toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));

    final result = <ProductLocal>[];
    for (final pp in pps) {
      await pp.product.load();
      final p = pp.product.value;
      if (p != null && p.deletedAt == null) result.add(p);
    }
    return result;
  }

  /// ดึงข้อมูลจาก API สำหรับ Sync
  Future getData() async {
    try {
      final url = Uri.https(publicUrl, '/api/load-data');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'api-key':
                  'c7ef38a0594617d91138899ca6f43884724b828047b22a2d16d706d32ed58040',
              'Authorization': 'Bearer ${_authService.currentToken}',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('การเชื่อมต่อหมดเวลา'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // return LoginResponse(
        //   success: false,
        //   message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
        // );
      } else if (response.statusCode == 429) {
        // return LoginResponse(
        //   success: false,
        //   message: 'พยายามเข้าสู่ระบบบ่อยเกินไป กรุณาลองใหม่ภายหลัง',
        // );
      } else {
        // return LoginResponse(
        //   success: false,
        //   message: loginResponse.message ?? 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ',
        // );
      }
    } catch (e) {
      // return LoginResponse(success: false, message: _handleError(e));
    }
  }
}

/// แปลง String ISO8601 เป็น DateTime (nullable)
// DateTime? _dtOrNull(dynamic v) {
//   if (v == null) return null;
//   return DateTime.parse(v as String);
// }

/// นี่คือ JSON ต้นฉบับของคุณ (วางได้เลย หรือนำเข้าจากไฟล์/HTTP ก็ได้)
// const String rawJson = r'''
// {YOUR_JSON_HERE}
// ''';

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
