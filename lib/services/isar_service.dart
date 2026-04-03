import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:posashastd/constants.dart';
import 'package:posashastd/helpers/image_local.dart';
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
      [CategoryLocalSchema, OrderItemLocalSchema, OrderLocalSchema, PanelLocalSchema, PanelProductLocalSchema, ProductLocalSchema, ShiftLocalSchema],
      directory: dir.path,
      inspector: true, // เปิด true เวลา debug ก็ได้
    );
    return _isar!;
  }

  Future<void> loadData() async {
    final data = await getData();

    // ✅ ตรวจสอบว่า data เป็น null หรือไม่
    if (data == null) {
      print('❌ getData() returned null - aborting loadData');
      return;
    }

    // ✅ ตรวจสอบว่าได้ข้อมูลจาก API หรือไม่
    final categoriesFromApi = (data['categories'] as List? ?? const []);
    final productsFromApi = (data['products'] as List? ?? const []);
    final panelsFromApi = (data['panels'] as List? ?? const []);
    final panelProductsFromApi = (data['panelProducts'] as List? ?? const []);

    // ✅ ถ้าข้อมูลว่างเปล่าทั้งหมด = ไม่มีเน็ตหรือ error → ไม่ต้องลบข้อมูลเก่า
    if (categoriesFromApi.isEmpty && productsFromApi.isEmpty && panelsFromApi.isEmpty && panelProductsFromApi.isEmpty) {
      print('⚠️ No data from API - keeping existing data in database');
      throw Exception('ไม่สามารถดึงข้อมูลจากเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต');
    }

    print(
      '✅ Got data from API - categories: ${categoriesFromApi.length}, products: ${productsFromApi.length}, panels: ${panelsFromApi.length}, panelProducts: ${panelProductsFromApi.length}',
    );

    // ---------- 1) Categories ----------
    final categories = <CategoryLocal>[];
    for (final c in (data['categories'] as List? ?? const [])) {
      categories.add(
        CategoryLocal()
          ..id = c['id'] as int
          ..code = (c['code'] ?? '').toString()
          ..name = (c['name'] ?? '').toString()
          ..createdAt = c['createdAt'] != null ? DateTime.parse(c['createdAt']) : null
          ..updatedAt = c['updatedAt'] != null ? DateTime.parse(c['updatedAt']) : null
          ..deletedAt = c['deletedAt'] != null ? DateTime.parse(c['deletedAt']) : null,
      );
    }

    // ---------- 2) Products + Images ----------
    final products = <ProductLocal>[];
    final productCategoryIds = <int?>[]; // เก็บ categoryId ของแต่ละ product ตาม index
    final imageFutures = <Future<String?>>[];

    for (final p in (data['products'] as List? ?? const [])) {
      final product =
          ProductLocal()
            ..id = p['id'] as int
            ..code = (p['code'] ?? '').toString()
            ..name = (p['name'] ?? '').toString()
            ..imageUrl = (p['imageUrl'] as String?)
            ..price = (p['price'] as num?)?.toDouble()
            ..showType = (p['showType'] as String?)
            ..color = (p['color'] as String?)
            ..createdAt = p['createdAt'] != null ? DateTime.parse(p['createdAt']) : null
            ..updatedAt = p['updatedAt'] != null ? DateTime.parse(p['updatedAt']) : null
            ..deletedAt = p['deletedAt'] != null ? DateTime.parse(p['deletedAt']) : null;

      products.add(product);
      productCategoryIds.add((p['category'] as Map?)?['id'] as int?);

      imageFutures.add(cacheImageLocal(p['imageUrl']?.toString()));
    }

    // --- โหลดรูปแบบ chunk (ครั้งละ 10 งาน) ---
    const chunkSize = 10;
    var start = 0;
    while (start < imageFutures.length) {
      final end = (start + chunkSize < imageFutures.length) ? start + chunkSize : imageFutures.length;

      final batch = imageFutures.sublist(start, end);
      final results = await Future.wait(batch);

      for (var i = 0; i < results.length; i++) {
        final r = results[i];
        final idx = start + i;
        products[idx].imageLocal = r;
      }

      start = end;
    }

    // ---------- 3) Panels ----------
    final panelsIncoming = <PanelLocal>[];
    for (final p in (data['panels'] as List? ?? const [])) {
      panelsIncoming.add(
        PanelLocal()
          ..name = (p['name'] ?? '').toString()
          ..createdAt = p['createdAt'] != null ? DateTime.parse(p['createdAt']) : null
          ..updatedAt = p['updatedAt'] != null ? DateTime.parse(p['updatedAt']) : null
          ..deletedAt = p['deletedAt'] != null ? DateTime.parse(p['deletedAt']) : null,
      );
    }

    final panelProductsJson = (data['panelProducts'] as List?) ?? const [];

    // ✅ Log เพื่อตรวจสอบข้อมูล
    print('📊 Panels from API: ${panelsIncoming.length} items');
    print('📊 PanelProducts from API: ${panelProductsJson.length} items');

    // ---------- 4) เข้าธุรกรรมครั้งเดียว ----------
    await _isar!.writeTxn(() async {
      // ✅ 4.0) ลบข้อมูลทั้งหมดก่อน (Clear All Data)
      print('🗑️ Clearing all existing data from database...');
      await _isar!.panelProductLocals.clear();
      await _isar!.panelLocals.clear();
      await _isar!.productLocals.clear();
      await _isar!.categoryLocals.clear();
      print('✅ Cleared all data: Categories, Products, Panels, PanelProducts');

      // 4.1) Insert Categories ใหม่
      print('📥 Inserting ${categories.length} new Categories...');
      await _isar!.categoryLocals.putAll(categories);
      final categoryById = {for (final c in categories) c.id: c};
      print('✅ Inserted ${categories.length} Categories');

      // 4.2) Insert Products ใหม่ + set category link
      print('📥 Inserting ${products.length} new Products...');
      await _isar!.productLocals.putAll(products);
      for (var i = 0; i < products.length; i++) {
        final catId = productCategoryIds[i];
        if (catId != null) {
          final cat = categoryById[catId];
          if (cat != null) {
            products[i].category.value = cat;
          }
        }
      }
      for (final p in products) {
        await p.category.save();
      }
      print('✅ Inserted ${products.length} Products');

      // 4.3) Insert Panels ใหม่

      // Insert Panels ใหม่ทั้งหมด
      print('📥 Inserting ${panelsIncoming.length} new Panels...');
      await _isar!.panelLocals.putAll(panelsIncoming);
      print('✅ Inserted ${panelsIncoming.length} new Panels');

      // โหลดแผนที่ panel ตามชื่อ (สมมติ name เป็น unique)
      final allPanels = await _isar!.panelLocals.where().findAll();
      final panelByName = <String, PanelLocal>{for (final pan in allPanels) (pan.name ?? '').trim(): pan};

      // 4.4) Upsert PanelProducts
      final codes = <String>{};
      for (final pp in panelProductsJson) {
        final prod = pp['product'] as Map<String, dynamic>?;
        final c = (prod?['code'] ?? '').toString().trim();
        if (c.isNotEmpty) codes.add(c);
      }

      // โหลด products ทั้งหมดใน DB แล้วทำ map ตาม code (ถ้าตารางใหญ่ แนะนำทำ query ตามชุด codes)
      final prodsAll = await _isar!.productLocals.where().findAll();
      final productByCode = <String, ProductLocal>{for (final pr in prodsAll) (pr.code ?? '').trim(): pr};

      var savedPanelProductCount = 0;
      for (final pp in panelProductsJson) {
        final prod = pp['product'] as Map<String, dynamic>?;
        if (prod == null) {
          print('⚠️ PanelProduct skipped: product is null');
          continue;
        }
        final code = (prod['code'] ?? '').toString().trim();
        if (code.isEmpty) {
          print('⚠️ PanelProduct skipped: product code is empty');
          continue;
        }

        final product =
            productByCode[code] ?? ProductLocal()
              ..code = code
              ..name = (prod['name'] ?? '').toString()
              ..imageUrl = (prod['imageUrl'] as String?)
              ..price = (prod['price'] as num?)?.toDouble()
              ..showType = (prod['showType'] as String?)
              ..color = (prod['color'] as String?)
              ..createdAt = prod['createdAt'] != null ? DateTime.parse(prod['createdAt']) : null
              ..updatedAt = prod['updatedAt'] != null ? DateTime.parse(prod['updatedAt']) : DateTime.now()
              ..deletedAt = prod['deletedAt'] != null ? DateTime.parse(prod['deletedAt']) : null;

        final productId = await _isar!.productLocals.put(product);
        productByCode[code] = product..id = productId;

        final pan = pp['panel'] as Map<String, dynamic>?;
        if (pan == null) {
          print('⚠️ PanelProduct skipped: panel is null for product code: $code');
          continue;
        }
        final panelName = (pan['name'] ?? '').toString().trim();
        if (panelName.isEmpty) {
          print('⚠️ PanelProduct skipped: panel name is empty for product code: $code');
          continue;
        }

        final panel =
            panelByName[panelName] ??
            (PanelLocal()
              ..name = panelName
              ..createdAt = pan['createdAt'] != null ? DateTime.parse(pan['createdAt']) : DateTime.now()
              ..updatedAt = pan['updatedAt'] != null ? DateTime.parse(pan['updatedAt']) : DateTime.now()
              ..deletedAt = pan['deletedAt'] != null ? DateTime.parse(pan['deletedAt']) : null);

        if (panel.id == 0) {
          final pid = await _isar!.panelLocals.put(panel);
          panel.id = pid;
          panelByName[panelName] = panel;
        }

        final uniqueKey = '${panel.id}:$productId';

        PanelProductLocal? panelProduct = await _isar!.panelProductLocals.filter().uniqueKeyEqualTo(uniqueKey).findFirst();
        panelProduct ??= PanelProductLocal();

        panelProduct
          ..uniqueKey = uniqueKey
          ..color = (pp['color'] as String?)
          ..sequence = (pp['sequence'] as int?) ?? 0
          ..createdAt = pp['createdAt'] != null ? DateTime.parse(pp['createdAt']) : panelProduct.createdAt
          ..updatedAt = pp['updatedAt'] != null ? DateTime.parse(pp['updatedAt']) : DateTime.now()
          ..deletedAt = pp['deletedAt'] != null ? DateTime.parse(pp['deletedAt']) : null;

        panelProduct.panel.value = panel;
        panelProduct.product.value = product;

        await _isar!.panelProductLocals.put(panelProduct);
        await panelProduct.panel.save();
        await panelProduct.product.save();

        // ✅ เพิ่ม panelProduct เข้าไปใน panel.panelProducts (two-way relationship)
        panel.panelProducts.add(panelProduct);
        await panel.panelProducts.save();

        savedPanelProductCount++;
        print('✅ Saved PanelProduct: ${panelProduct.uniqueKey} (Panel: $panelName, Product: $code)');
      }

      print('📊 Total PanelProducts saved: $savedPanelProductCount');
    });
  }

  Future<List<CategoryLocal>> getCategories() async {
    // ✅ Filter เฉพาะ Categories ที่ไม่ถูกลบ (deletedAt = null)
    return await _isar!.categoryLocals.filter().deletedAtIsNull().findAll();
  }

  //get panel
  Future<List<PanelLocal>> getPanels() async {
    // ✅ Filter เฉพาะ Panels ที่ไม่ถูกลบ (deletedAt = null)
    return await _isar!.panelLocals.filter().deletedAtIsNull().findAll();
  }

  Future<List<OrderLocal>> getOrders() async {
    return await _isar!.orderLocals.where().findAll();
  }

  Future clearOrders() async {
    return _isar!.writeTxn(() async {
      await _isar!.shiftLocals.clear();
      await _isar!.orderLocals.clear();
    });
  }

  Future clearOrders2() async {
    return _isar!.writeTxn(() async {
      await _isar!.orderLocals.clear();
    });
  }

  Future<List<ProductLocal>> getProducts({int? categoryId}) async {
    if (categoryId != null && categoryId > 0) {
      // ✅ Filter เฉพาะ Products ที่ไม่ถูกลบ (deletedAt = null) และอยู่ใน category ที่ระบุ
      return await _isar!.productLocals.filter().deletedAtIsNull().and().category((q) => q.idEqualTo(categoryId)).findAll();
    } else {
      // ✅ Filter เฉพาะ Products ที่ไม่ถูกลบ (deletedAt = null)
      return await _isar!.productLocals.filter().deletedAtIsNull().findAll();
    }
  }

  // ใช้สำหรับหน้า POS: ดึงสินค้าตาม Panel เรียง sequence
  Future<List<ProductLocal>> getProductsOfPanel(String panelName) async {
    print('🔍 Getting products for panel: $panelName');
    final panel = await isar!.panelLocals.filter().nameEqualTo(panelName).findFirst();
    if (panel == null) {
      print('⚠️ Panel not found: $panelName');
      return [];
    }

    await panel.panelProducts.load();
    print('📦 Panel "$panelName" has ${panel.panelProducts.length} panelProducts');

    final pps = panel.panelProducts.where((pp) => pp.deletedAt == null).toList()..sort((a, b) => a.sequence.compareTo(b.sequence));
    print('✅ After filtering deletedAt: ${pps.length} panelProducts');

    final result = <ProductLocal>[];
    for (final pp in pps) {
      await pp.product.load();
      final p = pp.product.value;
      if (p != null && p.deletedAt == null) {
        result.add(p);
        print('  ✅ Product: ${p.name} (sequence: ${pp.sequence})');
      }
    }
    print('📊 Total products for panel "$panelName": ${result.length}');
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
              'api-key': 'c7ef38a0594617d91138899ca6f43884724b828047b22a2d16d706d32ed58040',
              'Authorization': 'Bearer ${_authService.currentToken}',
            },
          )
          .timeout(const Duration(seconds: 30), onTimeout: () => throw Exception('การเชื่อมต่อหมดเวลา'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      } else if (response.statusCode == 429) {
        throw Exception('พยายามเข้าสู่ระบบบ่อยเกินไป กรุณาลองใหม่ภายหลัง');
      } else {
        throw Exception('เกิดข้อผิดพลาดในการโหลดข้อมูล: ${response.statusCode}');
      }
    } catch (e) {
      // ✅ ถ้าเกิด error ให้ return ข้อมูลเปล่าแทน null
      return {'categories': [], 'products': [], 'panels': [], 'panelProducts': []};
    }
  }
}
