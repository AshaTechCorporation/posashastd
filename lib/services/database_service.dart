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
