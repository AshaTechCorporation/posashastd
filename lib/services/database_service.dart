import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posashastd/models/product.dart';
import 'package:sqflite/sqflite.dart';

import '../constants.dart';
import '../models/category.dart';
import 'auth_service.dart';

class DatebaseService {
  // Singleton pattern
  static final DatebaseService _instance = DatebaseService._internal();
  factory DatebaseService() => _instance;
  DatebaseService._internal();

  final _authService = AuthService();

  Database? _database;

  // ดำเนินการ Sync
  Future<void> loadDataSync() async {
    try {
      await getDatabase();

      final data = await getData();

      await Future.wait([insertProducts(data), insertCategories(data)]);

      log('Load Data Sync Done.');
    } catch (e) {
      throw Exception('Failed to load data from API: $e');
    }
  }

  // ฟังก์ชันเปิดหรือสร้างฐานข้อมูล
  Future<void> getDatabase() async {
    // final databasesPath = await getDatabasesPath();
    final exterlnal = await getExternalStorageDirectory();

    final String dbPath = join(exterlnal!.path, 'pos.db');

    bool dbExists = await File(dbPath).exists();

    if (dbExists) {
      await deleteDatabase(dbPath);

      // _database = await openDatabase(dbPath);
      // return;
    }

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(createProductTable);
        await db.execute(createCategoryTable);
      },
    );
  }

  // Future<void> fetchDataFromAPI() async {
  //   // final response = await http.get(Uri.parse(publicUrl, '/api/sync'));
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   final url = Uri.https(publicUrl, '/kkt-api/public/api/sync-data');
  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };
  //   final response = await http.post(
  //     headers: headers,
  //     url,
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     // Call function to update database
  //     await syncTable(data);
  //     // await updateLocalDatabase(data);
  //   } else {
  //     throw Exception('Failed to load data from API');
  //   }
  // }

  // Future<String> imageToBase64(String imageUrl) async {
  //   try {
  //     final response = await http.get(Uri.parse(imageUrl));
  //     if (response.statusCode == 200) {
  //       return base64Encode(response.bodyBytes);
  //     }
  //   } catch (e) {
  //     print("Error converting image: $e");
  //   }
  //   return ''; // คืนค่าว่างหากไม่สามารถแปลงรูปได้
  // }

  // // sync ข้อมูลทั้งหมดครั้งแรก
  // Future fetchDataFromAPI({List<Orderslists>? data, String? last_sync}) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final url = Uri.https(publicUrl, '/kkt-api/public/api/sync-data-first');
  //   final token = prefs.getString('token');
  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };

  //   final response = await http.post(
  //     url,
  //     headers: headers,
  //     body: convert.jsonEncode({"last_sync": last_sync, "orders": data}),
  //   );

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final data = jsonDecode(response.body);
  //     return await syncTable(data);
  //   } else {
  //     final data = convert.jsonDecode(response.body);
  //     throw ApiException(data['message']);
  //   }
  // }

  // Future fetchUpdateFromAPI({
  //   List<Orderslists>? data,
  //   String? last_sync,
  // }) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final url = Uri.https(publicUrl, '/kkt-api/public/api/sync-data');
  //   final token = prefs.getString('token');
  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };

  //   final response = await http.post(
  //     url,
  //     headers: headers,
  //     body: convert.jsonEncode({"last_sync": last_sync, "orders": data}),
  //   );

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final data = jsonDecode(response.body);
  //     return await syncTable(data);
  //   } else {
  //     final data = convert.jsonDecode(response.body);
  //     throw ApiException(data['message']);
  //   }
  // }

  // // Updateorder
  // Future fetchUpdateOrder({List<Orderslists>? data, String? last_sync}) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final url = Uri.https(publicUrl, '/kkt-api/public/api/sync-data');
  //   final token = prefs.getString('token');
  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };

  //   final response = await http.post(
  //     url,
  //     headers: headers,
  //     body: convert.jsonEncode({"last_sync": last_sync, "orders": data}),
  //   );

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final data = jsonDecode(response.body);
  //     return await syncorder(data);
  //   } else {
  //     final data = convert.jsonDecode(response.body);
  //     throw ApiException(data['message']);
  //   }
  // }

  // // UpdateClients
  // Future fetchUpdateClients({
  //   List<Orderslists>? data,
  //   String? last_sync,
  // }) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final url = Uri.https(publicUrl, '/kkt-api/public/api/sync-data');
  //   final token = prefs.getString('token');
  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };

  //   final response = await http.post(
  //     url,
  //     headers: headers,
  //     body: convert.jsonEncode({"last_sync": last_sync, "orders": data}),
  //   );

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final data = jsonDecode(response.body);
  //     return await syncClients(data);
  //   } else {
  //     final data = convert.jsonDecode(response.body);
  //     throw ApiException(data['message']);
  //   }
  // }

  // //UpdateProduct
  // Future fetchUpdateProduct({
  //   List<Orderslists>? data,
  //   String? last_sync,
  // }) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final url = Uri.https(publicUrl, '/kkt-api/public/api/sync-data');
  //   final token = prefs.getString('token');
  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };

  //   final response = await http.post(
  //     url,
  //     headers: headers,
  //     body: convert.jsonEncode({"last_sync": last_sync, "orders": data}),
  //   );

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final data = jsonDecode(response.body);
  //     return await syncProduct(data);
  //   } else {
  //     final data = convert.jsonDecode(response.body);
  //     throw ApiException(data['message']);
  //   }
  // }

  // // ฟังชั่นสินค้า
  // Future<void> insetupdateproduct(Batch batch, dynamic dataFromApi) async {
  //   for (var productFromApi in dataFromApi['products']) {
  //     // แทรกข้อมูลในตาราง product
  //     batch.execute(
  //       '''
  //       INSERT OR REPLACE INTO product
  //       ("id", "code", "category_product_id", "sub_category_product_id", "supplier_id", "area_id", "shelve_id", "floor_id", "channel_id", "name", "detail", "qty", "sale_price", "cost", "min", "max")
  //        VALUES
  //       (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //      ''',
  //       [
  //         productFromApi['id'],
  //         productFromApi['code'],
  //         productFromApi['category_product_id'],
  //         productFromApi['sub_category_product_id'],
  //         productFromApi['supplier_id'],
  //         productFromApi['area_id'],
  //         productFromApi['shelve_id'],
  //         productFromApi['floor_id'],
  //         productFromApi['channel_id'],
  //         productFromApi['name'],
  //         productFromApi['detail'],
  //         productFromApi['qty'],
  //         productFromApi['sale_price'],
  //         productFromApi['cost'],
  //         productFromApi['min'],
  //         productFromApi['max'],
  //       ],
  //     );

  //     // ตรวจสอบว่ามี units หรือไม่
  //     if (productFromApi['units'] != null) {
  //       for (var units in productFromApi['units']) {
  //         // inspect(productFromApi['units']);
  //         batch.execute(
  //           '''
  //           INSERT OR REPLACE INTO units
  //           ("id", "product_id", "unit_id", "qty", "lot", "type", "area_id", "shelve_id", "floor_id", "channel_id", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //           VALUES
  //           (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //           ''',
  //           [
  //             units['id'],
  //             units['product_id'],
  //             units['unit_id'],
  //             units['qty'],
  //             units['lot'],
  //             units['type'],
  //             units['area_id'],
  //             units['shelve_id'],
  //             units['floor_id'],
  //             units['channel_id'],
  //             units['create_by'],
  //             units['update_by'],
  //             units['created_at'],
  //             units['updated_at'],
  //             units['deleted_at'],
  //           ],
  //         );
  //         // ตรวจสอบว่ามี unit หรือไม่
  //         if (units['unit'] != null) {
  //           var unit = units['unit'];
  //           // inspect(units['unit']);product_fee
  //           batch.execute(
  //             '''
  //            INSERT OR IGNORE INTO unit
  //            ("id", "name", "code", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  //            ''',
  //             [
  //               unit['id'],
  //               unit['name'],
  //               unit['code'],
  //               unit['create_by'] ?? null,
  //               unit['update_by'] ?? null,
  //               unit['created_at'] ?? null,
  //               unit['updated_at'] ?? null,
  //               unit['deleted_at'] ?? null,
  //             ],
  //           );
  //         }
  //       }
  //     }
  //     if (productFromApi['promotions'] != null) {
  //       for (var promotion in productFromApi['promotions']) {
  //         // inspect(productFromApi['promotions']);
  //         batch.execute(
  //           '''
  //            INSERT OR REPLACE INTO promotions
  //           ("id","code","product_id", "product_free_id", "min_qty_buy", "free_or_discount_amount", "start_date", "end_date", "type", "status", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //             VALUES
  //            (?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //            ''',
  //           [
  //             promotion['id'],
  //             promotion['code'],
  //             promotion['product_id'],
  //             promotion['product_free_id'],
  //             promotion['min_qty_buy'],
  //             promotion['free_or_discount_amount'],
  //             promotion['start_date'],
  //             promotion['end_date'],
  //             promotion['type'],
  //             promotion['status'],
  //             promotion['create_by'],
  //             promotion['update_by'],
  //             promotion['created_at'],
  //             promotion['updated_at'],
  //             promotion['deleted_at'],
  //           ],
  //         );
  //         if (promotion['product_fee'] != null) {
  //           var product_free = promotion['product_fee'];
  //           batch.execute(
  //             '''
  //              INSERT OR IGNORE INTO product_free
  //             ("id", "code", "category_product_id", "sub_category_product_id", "supplier_id", "area_id",
  //              "shelve_id", "floor_id", "channel_id", "name", "detail", "qty", "sale_price", "cost", "min", "max",
  //              "type", "stock_status", "more_address", "create_by", "update_by", "created_at", "updated_at")
  //              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //              ''',
  //             [
  //               product_free['id'],
  //               product_free['code'],
  //               product_free['category_product_id'] ?? null,
  //               product_free['sub_category_product_id'] ?? null,
  //               product_free['supplier_id'] ?? null,
  //               product_free['area_id'] ?? null,
  //               product_free['shelve_id'] ?? null,
  //               product_free['floor_id'] ?? null,
  //               product_free['channel_id'] ?? null,
  //               product_free['name'],
  //               product_free['detail'] ?? null,
  //               product_free['qty'] ?? null,
  //               product_free['sale_price'] ?? null,
  //               product_free['cost'] ?? null,
  //               product_free['min'] ?? null,
  //               product_free['max'] ?? null,
  //               product_free['type'] ?? null,
  //               product_free['stock_status'] ?? null,
  //               product_free['more_address'] ?? null,
  //               product_free['create_by'] ?? null,
  //               product_free['update_by'] ?? null,
  //               product_free['created_at'] ?? null,
  //               product_free['updated_at'] ?? null,
  //             ],
  //           );
  //         }
  //       }
  //       if (productFromApi['images'] != null) {
  //         Set<int> insertedIds = {};
  //         for (var image in productFromApi['images']) {
  //           // แปลงรูปเป็น Base64
  //           String base64Image = await imageToBase64(image['image']);

  //           // เพิ่ม id ที่แทรกแล้วลงใน Set
  //           insertedIds.add(image['id']);

  //           // ทำการแทรกข้อมูลใหม่ลงในฐานข้อมูล
  //           batch.execute(
  //             '''
  //             INSERT INTO images
  //             ("product_id", "image", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //             VALUES (?, ?, ?, ?, ?, ?, ?)
  //             ''',
  //             [
  //               image['product_id'],
  //               base64Image, // ใช้รูปที่แปลงเป็น Base64 แล้ว
  //               image['create_by'],
  //               image['update_by'],
  //               image['created_at'],
  //               image['updated_at'],
  //               image['deleted_at'],
  //             ],
  //           );
  //         }
  //       }
  //       // if (productFromApi['panorama_images'] != null) {
  //       //   Set<int> insertedIds = {};
  //       //   for (var panorama in productFromApi['panorama_images']) {
  //       //     // inspect(panorama);
  //       //     // แปลงรูปเป็น Base64
  //       //     String base64Image = await imageToBase64(panorama['image']);

  //       //     insertedIds.add(panorama['id']);

  //       //     batch.execute(
  //       //       '''
  //       //       INSERT INTO panorama_images
  //       //       ("product_id", "image", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //       //       VALUES (?, ?, ?, ?, ?, ?, ?)
  //       //        ''',
  //       //       [
  //       //         panorama['product_id'],
  //       //         base64Image, // ใช้รูปที่แปลงเป็น Base64 แล้ว
  //       //         panorama['create_by'],
  //       //         panorama['update_by'],
  //       //         panorama['created_at'],
  //       //         panorama['updated_at'],
  //       //         panorama['deleted_at'],
  //       //       ],
  //       //     );
  //       //   }
  //       // }
  //     }
  //   }
  // }

  // // ฟังชั่นลูกค้า
  // Future<void> insetupdateclients(Batch batch, dynamic dataFromApi) async {
  //   for (var clientsFromApi in dataFromApi['clients']) {
  //     batch.execute(
  //       '''
  //        INSERT OR REPLACE INTO client
  //        (id, code, name, phone, email, address, line_id, facebook, transport, sale_owner_id, create_by, update_by, created_at, updated_at, deleted_at)
  //        VALUES
  //        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //        ''',
  //       [
  //         clientsFromApi['id'],
  //         clientsFromApi['code'],
  //         clientsFromApi['name'],
  //         clientsFromApi['phone'],
  //         clientsFromApi['email'],
  //         clientsFromApi['address'],
  //         clientsFromApi['sale_owner_id'],
  //         clientsFromApi['line_id'],
  //         clientsFromApi['facebook'],
  //         clientsFromApi['transport'],
  //         clientsFromApi['create_by'],
  //         clientsFromApi['update_by'],
  //         clientsFromApi['created_at'],
  //         clientsFromApi['updated_at'],
  //         clientsFromApi['deleted_at'],
  //       ],
  //     );
  //   }
  // }

  // // ฝังชั่น order
  // Future<void> insetupdateorder(Batch batch, dynamic dataFromApi) async {
  //   for (var orderFromApi in dataFromApi['orders']) {
  //     batch.execute(
  //       '''
  //       INSERT OR REPLACE INTO orders
  //       ("id","code", "date", "client_id", "client_name", "client_phone","client_address", "client_email",
  //       "total_price", "discount", "adjust_discount", "vat", "percent_vat", "price_vat", "status",
  //       "create_by", "update_by", "created_at", "updated_at","deleted_at", "No")
  //       VALUES
  //       (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)
  //        ''',
  //       [
  //         orderFromApi['id'],
  //         orderFromApi['code'],
  //         orderFromApi['date'],
  //         orderFromApi['client_id'],
  //         orderFromApi['client_name'],
  //         orderFromApi['client_phone'],
  //         orderFromApi['client_address'],
  //         orderFromApi['client_email'],
  //         orderFromApi['total_price'],
  //         orderFromApi['discount'],
  //         orderFromApi['adjust_discount'],
  //         orderFromApi['vat'],
  //         orderFromApi['percent_vat'],
  //         orderFromApi['price_vat'],
  //         orderFromApi['status'],
  //         orderFromApi['create_by'],
  //         orderFromApi['update_by'],
  //         orderFromApi['created_at'],
  //         orderFromApi['updated_at'],
  //         orderFromApi['deleted_at'],
  //         orderFromApi['No'],
  //       ],
  //     );
  //     if (orderFromApi['order_lists'] != null) {
  //       for (var orderList in orderFromApi['order_lists']) {
  //         batch.execute(
  //           '''
  //        INSERT OR IGNORE INTO order_lists
  //        ("id", "order_id", "product_id", "cost", "price","qty", "promotion_id","discount", "unit_id",
  //       "create_by","update_by", "created_at", "updated_at", "deleted_at")
  //       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //        ''',
  //           [
  //             orderList['id'],
  //             orderList['order_id'],
  //             orderList['product_id'],
  //             orderList['cost'],
  //             orderList['price'],
  //             orderList['qty'],
  //             orderList['promotion_id'],
  //             orderList['discount'],
  //             orderList['unit_id'],
  //             orderList['create_by'] ?? null,
  //             orderList['update_by'] ?? null,
  //             orderList['created_at'] ?? null,
  //             orderList['updated_at'] ?? null,
  //             orderList['deleted_at'] ?? null,
  //           ],
  //         );
  //       }
  //     }
  //   }
  // }

  // // Sync ทุก table
  // Future<void> syncTable(Map<String, dynamic> apiData) async {
  //   final db = await getDatabase();
  //   final dataFromApi = apiData['data'];
  //   print('📂 DATABASE PATH = ${db.path}');
  //   await db.transaction((txn) async {
  //     var batch = txn.batch(); // ใช้ batch เพื่อลดการเปิด transaction หลายรอบ
  //     // sync Order
  //     insetupdateorder(batch, dataFromApi);

  //     for (var categoryFromApi in dataFromApi['categories']) {
  //       batch.execute(
  //         '''
  //       INSERT OR REPLACE INTO category
  //       ("id", "prefix", "name", "create_by", "update_by", "created_at", "updated_at", "deleted_at", "No")
  //       VALUES
  //       (?, ?, ?, ?, ?, ?, ?, ?, ?)
  //      ''',
  //         [
  //           categoryFromApi['id'],
  //           categoryFromApi['prefix'],
  //           categoryFromApi['name'],
  //           categoryFromApi['create_by'],
  //           categoryFromApi['update_by'],
  //           categoryFromApi['created_at'],
  //           categoryFromApi['updated_at'],
  //           categoryFromApi['deleted_at'],
  //           categoryFromApi['No'],
  //         ],
  //       );
  //     }
  //     for (var subCategoryFromApi in dataFromApi['sub_categories']) {
  //       batch.execute(
  //         '''
  //      INSERT OR REPLACE INTO sub_category
  //      ("id", "prefix", "category_product_id", "name", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //      VALUES
  //      (?, ?, ?, ?, ?, ?, ?, ?, ?)
  //      ''',
  //         [
  //           subCategoryFromApi['id'],
  //           subCategoryFromApi['prefix'],
  //           subCategoryFromApi['category_product_id'],
  //           subCategoryFromApi['name'],
  //           subCategoryFromApi['create_by'],
  //           subCategoryFromApi['update_by'],
  //           subCategoryFromApi['created_at'],
  //           subCategoryFromApi['updated_at'],
  //           subCategoryFromApi['deleted_at'],
  //         ],
  //       );
  //     }

  //     await insetupdateproduct(batch, dataFromApi);

  //     for (var productFromApi in dataFromApi['products']) {
  //       // แทรกข้อมูลในตาราง product
  //       batch.execute(
  //         '''
  //       INSERT OR REPLACE INTO product
  //       ("id", "code", "category_product_id", "sub_category_product_id", "supplier_id", "area_id", "shelve_id", "floor_id", "channel_id", "name", "detail", "qty", "sale_price", "cost", "min", "max")
  //        VALUES
  //       (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //      ''',
  //         [
  //           productFromApi['id'],
  //           productFromApi['code'],
  //           productFromApi['category_product_id'],
  //           productFromApi['sub_category_product_id'],
  //           productFromApi['supplier_id'],
  //           productFromApi['area_id'],
  //           productFromApi['shelve_id'],
  //           productFromApi['floor_id'],
  //           productFromApi['channel_id'],
  //           productFromApi['name'],
  //           productFromApi['detail'],
  //           productFromApi['qty'],
  //           productFromApi['sale_price'],
  //           productFromApi['cost'],
  //           productFromApi['min'],
  //           productFromApi['max'],
  //         ],
  //       );

  //       // ตรวจสอบว่ามี units หรือไม่
  //       if (productFromApi['units'] != null) {
  //         for (var units in productFromApi['units']) {
  //           // inspect(productFromApi['units']);
  //           batch.execute(
  //             '''
  //           INSERT OR REPLACE INTO units
  //           ("id", "product_id", "unit_id", "qty", "lot", "type", "area_id", "shelve_id", "floor_id", "channel_id", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //           VALUES
  //           (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //           ''',
  //             [
  //               units['id'],
  //               units['product_id'],
  //               units['unit_id'],
  //               units['qty'],
  //               units['lot'],
  //               units['type'],
  //               units['area_id'],
  //               units['shelve_id'],
  //               units['floor_id'],
  //               units['channel_id'],
  //               units['create_by'],
  //               units['update_by'],
  //               units['created_at'],
  //               units['updated_at'],
  //               units['deleted_at'],
  //             ],
  //           );
  //           // ตรวจสอบว่ามี unit หรือไม่
  //           if (units['unit'] != null) {
  //             var unit = units['unit'];
  //             // inspect(units['unit']);product_fee
  //             batch.execute(
  //               '''
  //            INSERT OR IGNORE INTO unit
  //            ("id", "name", "code", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  //            ''',
  //               [
  //                 unit['id'],
  //                 unit['name'],
  //                 unit['code'],
  //                 unit['create_by'] ?? null,
  //                 unit['update_by'] ?? null,
  //                 unit['created_at'] ?? null,
  //                 unit['updated_at'] ?? null,
  //                 unit['deleted_at'] ?? null,
  //               ],
  //             );
  //           }
  //         }
  //       }
  //       if (productFromApi['promotions'] != null) {
  //         for (var promotion in productFromApi['promotions']) {
  //           // inspect(productFromApi['promotions']);
  //           batch.execute(
  //             '''
  //            INSERT OR REPLACE INTO promotions
  //           ("id","code","product_id", "product_free_id", "min_qty_buy", "free_or_discount_amount", "start_date", "end_date", "type", "status", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //             VALUES
  //            (?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //            ''',
  //             [
  //               promotion['id'],
  //               promotion['code'],
  //               promotion['product_id'],
  //               promotion['product_free_id'],
  //               promotion['min_qty_buy'],
  //               promotion['free_or_discount_amount'],
  //               promotion['start_date'],
  //               promotion['end_date'],
  //               promotion['type'],
  //               promotion['status'],
  //               promotion['create_by'],
  //               promotion['update_by'],
  //               promotion['created_at'],
  //               promotion['updated_at'],
  //               promotion['deleted_at'],
  //             ],
  //           );
  //           if (promotion['product_fee'] != null) {
  //             var product_free = promotion['product_fee'];
  //             batch.execute(
  //               '''
  //              INSERT OR IGNORE INTO product_free
  //             ("id", "code", "category_product_id", "sub_category_product_id", "supplier_id", "area_id",
  //              "shelve_id", "floor_id", "channel_id", "name", "detail", "qty", "sale_price", "cost", "min", "max",
  //              "type", "stock_status", "more_address", "create_by", "update_by", "created_at", "updated_at")
  //              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //              ''',
  //               [
  //                 product_free['id'],
  //                 product_free['code'],
  //                 product_free['category_product_id'] ?? null,
  //                 product_free['sub_category_product_id'] ?? null,
  //                 product_free['supplier_id'] ?? null,
  //                 product_free['area_id'] ?? null,
  //                 product_free['shelve_id'] ?? null,
  //                 product_free['floor_id'] ?? null,
  //                 product_free['channel_id'] ?? null,
  //                 product_free['name'],
  //                 product_free['detail'] ?? null,
  //                 product_free['qty'] ?? null,
  //                 product_free['sale_price'] ?? null,
  //                 product_free['cost'] ?? null,
  //                 product_free['min'] ?? null,
  //                 product_free['max'] ?? null,
  //                 product_free['type'] ?? null,
  //                 product_free['stock_status'] ?? null,
  //                 product_free['more_address'] ?? null,
  //                 product_free['create_by'] ?? null,
  //                 product_free['update_by'] ?? null,
  //                 product_free['created_at'] ?? null,
  //                 product_free['updated_at'] ?? null,
  //               ],
  //             );
  //           }
  //         }
  //         // if (productFromApi['images'] != null) {
  //         //   Set<int> insertedIds = {};
  //         //   for (var image in productFromApi['images']) {
  //         //     insertedIds.add(image['id']);
  //         //     final productId = image['product_id'];
  //         //     final checkProduct = await txn.rawQuery(
  //         //       'SELECT id FROM product WHERE id = ?',
  //         //       [productId],
  //         //     );

  //         //     if (checkProduct.isNotEmpty) {
  //         //       print('✅ พบ product_id = $productId → เตรียมแทรกรูป');
  //         //       String base64Image = await imageToBase64(image['image']);
  //         //       print('🟢 แทรกรูป images ID: ${image['id']} → Base64 length: ${base64Image.length}');

  //         //       // ✅ ใช้ txn.insert แทน db.insert
  //         //       await txn.insert('images', {
  //         //         'product_id': productId,
  //         //         'image': base64Image,
  //         //         'create_by': image['create_by'],
  //         //         'update_by': image['update_by'],
  //         //         'created_at': image['created_at'],
  //         //         'updated_at': image['updated_at'],
  //         //         'deleted_at': image['deleted_at'],
  //         //       });
  //         //     } else {
  //         //       print('❌ ไม่พบ product_id = $productId → ข้ามการแทรก image ID: ${image['id']}');
  //         //     }
  //         //   }
  //         // }

  //         if (productFromApi['product_add_ons'] != null) {
  //           Set<int> insertedAddOnIds = {};
  //           for (var addon in productFromApi['product_add_ons']) {
  //             insertedAddOnIds.add(addon['id']);

  //             batch.execute(
  //               '''
  //               INSERT OR REPLACE INTO product_add_ons
  //               ("id", "product_main_id", "product_add_on_id", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //               VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  //               ''',
  //               [
  //                 addon['id'],
  //                 addon['product_main_id'],
  //                 addon['product_add_on_id'],
  //                 addon['create_by'],
  //                 addon['update_by'],
  //                 addon['created_at'],
  //                 addon['updated_at'],
  //                 addon['deleted_at'],
  //               ],
  //             );

  //             final addOnProduct = addon['product'];
  //             if (addOnProduct != null &&
  //                 addOnProduct['product_images'] != null) {
  //               for (var image in addOnProduct['product_images']) {
  //                 print('🟢 แทรกรูป product_images ID: ${image['id']}');

  //                 String base64Image = await imageToBase64(image['image']);

  //                 batch.execute(
  //                   '''
  //                   INSERT OR REPLACE INTO product_images
  //                   ("id", "product_id", "image", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //                   VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  //                   ''',
  //                   [
  //                     int.tryParse(image['id'].toString()),
  //                     image['product_id']?.toString(),
  //                     base64Image,
  //                     image['create_by'],
  //                     image['update_by'],
  //                     image['created_at'],
  //                     image['updated_at'],
  //                     image['deleted_at'],
  //                   ],
  //                 );
  //               }
  //             }
  //           }
  //         }

  //         // if (productFromApi['panorama_images'] != null) {
  //         //   Set<int> insertedIds = {};
  //         //   for (var panorama in productFromApi['panorama_images']) {
  //         //     // inspect(panorama);
  //         //     // แปลงรูปเป็น Base64
  //         //     String base64Image = await imageToBase64(panorama['image']);

  //         //     insertedIds.add(panorama['id']);

  //         //     batch.execute(
  //         //       '''
  //         //     INSERT INTO panorama_images
  //         //     ("product_id", "image", "create_by", "update_by", "created_at", "updated_at", "deleted_at")
  //         //     VALUES (?, ?, ?, ?, ?, ?, ?)
  //         //      ''',
  //         //       [
  //         //         panorama['product_id'],
  //         //         base64Image, // ใช้รูปที่แปลงเป็น Base64 แล้ว
  //         //         panorama['create_by'],
  //         //         panorama['update_by'],
  //         //         panorama['created_at'],
  //         //         panorama['updated_at'],
  //         //         panorama['deleted_at'],
  //         //       ],
  //         //     );
  //         //   }
  //         // }
  //       }
  //     }
  //     insetupdateclients(batch, dataFromApi);

  //     // await batch.commit(noResult: true); // สั่ง execute batch พร้อมกัน
  //     try {
  //       await batch.commit(noResult: true);
  //       print('✅ Batch commit สำเร็จ');
  //     } catch (e, stack) {
  //       print('❌ Batch commit ล้มเหลว: $e');
  //       print(stack);
  //     }
  //   });

  //   // ✅ รอ DB พร้อมแน่นอนก่อนแทรก images
  //   await Future.delayed(Duration(milliseconds: 200));

  //   // ✅ ไม่ต้องใช้ transaction ซ้ำ → แทรกแต่ละรูปด้วย db โดยตรง
  //   print('📌 เริ่มวนลูป products สำหรับ images');

  //   if (dataFromApi['products'] != null) {
  //     for (var productFromApi in dataFromApi['products']) {
  //       if (productFromApi['images'] != null) {
  //         for (var image in productFromApi['images']) {
  //           final productId = int.tryParse(image['product_id'].toString());

  //           final checkProduct = await db.rawQuery(
  //             'SELECT id FROM product WHERE id = ?',
  //             [productId],
  //           );

  //           if (checkProduct.isNotEmpty) {
  //             print('✅ พบ product_id = $productId → เตรียมแทรกรูป');
  //             String base64Image = await imageToBase64(image['image']);

  //             await db.insert('images', {
  //               'product_id': productId,
  //               'image': base64Image,
  //               'create_by': image['create_by'],
  //               'update_by': image['update_by'],
  //               'created_at': image['created_at'],
  //               'updated_at': image['updated_at'],
  //               'deleted_at': image['deleted_at'],
  //             });
  //           } else {
  //             print(
  //               '❌ ไม่พบ product_id = $productId → ข้าม image ID: ${image['id']}',
  //             );
  //           }
  //         }
  //       }
  //     }
  //   }
  // }

  // //syncข้อมูล นพกำพ
  // Future<void> syncorder(Map<String, dynamic> apiData) async {
  //   final db = await getDatabase();
  //   final dataFromApi = apiData['data'];
  //   await db.transaction((txn) async {
  //     var batch = txn.batch(); // ใช้ batch เพื่อลดการเปิด transaction หลายรอบ
  //     // sync Order
  //     insetupdateorder(batch, dataFromApi);

  //     await batch.commit(noResult: true); // สั่ง execute batch พร้อมกัน
  //   });
  // }

  // // sync ข้อมูลลูกค้า
  // Future<void> syncClients(Map<String, dynamic> apiData) async {
  //   final db = await getDatabase();
  //   final dataFromApi = apiData['data'];
  //   await db.transaction((txn) async {
  //     var batch = txn.batch(); // ใช้ batch เพื่อลดการเปิด transaction หลายรอบ
  //     // sync Order
  //     insetupdateclients(batch, dataFromApi);

  //     await batch.commit(noResult: true); // สั่ง execute batch พร้อมกัน
  //   });
  // }

  // // sync ข้อมูลสินค้า
  // Future<void> syncProduct(Map<String, dynamic> apiData) async {
  //   final db = await getDatabase();
  //   final dataFromApi = apiData['data'];
  //   await db.transaction((txn) async {
  //     var batch = txn.batch(); // ใช้ batch เพื่อลดการเปิด transaction หลายรอบ
  //     // sync Order
  //     insetupdateproduct(batch, dataFromApi);

  //     await batch.commit(noResult: true); // สั่ง execute batch พร้อมกัน
  //   });
  // }

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

  String createProductTable = '''
    CREATE TABLE product (
      id INTEGER PRIMARY KEY,
      created_at TEXT,
      updated_at TEXT,
      deleted_at TEXT,
      code TEXT,
      name TEXT,
      image TEXT,
      price REAL,
      cost REAL,
      active INTEGER,
      barcode TEXT,
      remark TEXT,
      category_id INTEGER,
      unit_id INTEGER,
      show_type TEXT,
      color TEXT
    );
  ''';

  Future<void> insertProducts(data) async {
    final products =
        (data['products'] as List).map((e) => Product.fromJson(e)).toList();

    for (var product in products) {
      await _database!.rawInsert(
        '''INSERT INTO product(
            id,
            created_at,
            updated_at,
            deleted_at,
            code,
            name,
            image,
            price,
            cost,
            active,
            barcode,
            remark,
            show_type,
            category_id,
            color) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,? ,?)''',
        [
          product.id,
          product.createdAt?.toIso8601String(),
          product.updatedAt?.toIso8601String(),
          product.deletedAt?.toIso8601String(),
          product.code,
          product.name,
          product.image,
          product.price,
          product.cost,
          null,
          product.barcode,
          product.remark,
          product.showType,
          product.category?.id,
          product.color,
        ],
      );
      // await _database!.insert(
      //   'product',
      //   product.toMap(),
      //   conflictAlgorithm: ConflictAlgorithm.replace,
      // );
    }

    log('Insert Product Done.');
  }

  Future<List<Product>> getProducts() async {
    final List<Map<String, dynamic>> maps = await _database!.query('product');

    return maps.map((e) {
      return Product.fromJson(e);
    }).toList();
  }

  String createCategoryTable = '''
    CREATE TABLE category (
      id INTEGER PRIMARY KEY,
      created_at TEXT,
      updated_at TEXT,
      deleted_at TEXT,
      code TEXT,
      name TEXT
    );
  ''';

  Future<void> insertCategories(data) async {
    final categories =
        (data['categories'] as List).map((e) => Category.fromJson(e)).toList();

    for (var category in categories) {
      await _database!.rawInsert(
        '''INSERT INTO category(
            id,
            created_at,
            updated_at,
            deleted_at,
            code,
            name) VALUES(?, ?, ?, ?, ?, ?)''',
        [
          category.id,
          category.createdAt?.toIso8601String(),
          category.updatedAt?.toIso8601String(),
          category.deletedAt?.toIso8601String(),
          category.code,
          category.name,
        ],
      );
    }

    log('Insert Category Done.');
  }

  Future<List<Category>> getCategories() async {
    final List<Map<String, dynamic>> maps = await _database!.query('category');

    return maps.map((e) {
      return Category.fromJson(e);
    }).toList();
  }
}
