import 'dart:convert' as convert;
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/dto/order_dto.dart';
import 'package:posashastd/main.dart';
import 'package:posashastd/models/order.dart';
import 'package:posashastd/models/shift.dart';
import 'package:posashastd/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Homeservice {
  Homeservice();
  //เรียกดูข้อมูล Category
  static Future getCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final _authService = AuthService();
    // final domain = prefs.getString('domain');
    final url = Uri.https(publicUrl, '/api/category');
    var headers = {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
    // var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      //final list = data as List;
      return data;
      // return list.map((e) => Category.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  static Future getProduct({int? categoryId, required int branchId}) async {
    final _authService = AuthService();
    Uri url;
    if (branchId != 0) {
      url = Uri.https(publicUrl, '/api/product', {
        "branchId": "$branchId",
        "categoryId": '$categoryId',
        "sortBy": 'createdAt:DESC',
      });
    } else {
      url = Uri.https(publicUrl, '/api/product', {
        "branchId": "null",
        "categoryId": '$categoryId',
        "sortBy": 'createdAt:DESC',
      });
    }
    var headers = {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      //final list = data as List;
      //return list.map((e) => Product.fromJson(e)).toList();
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  //สร้างออเดอร์
  static Future createOrders({
    required Map<String, dynamic> formattedOrder,
  }) async {
    final _authService = AuthService();
    final url = Uri.https(publicUrl, '/api/order/order-with-payment');
    var headers = {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode(formattedOrder),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = convert.jsonDecode(response.body);
      //return Shift.fromJson(data);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  //สร้างออเดอร์ Offline
  static Future createOrderOffline({
    required Map<String, dynamic> formattedOrder,
  }) async {
    await isar.writeTxn(() async {
      final order = OrderDto()
        ..branchId = formattedOrder['branchId']
        ..deviceId = formattedOrder['deviceId']
        ..shiftId = int.parse(formattedOrder['shiftId'])
        ..total = formattedOrder['total']
        ..memberId = formattedOrder['memberId']
        ..date = DateTime.parse(formattedOrder['date'])
        ..paymentMethodId = formattedOrder['paymentMethodId'];
      print('📦 Saving order to Isar');
      final orderId = await isar.orderDtos.put(order);

      final rawItems =
          (formattedOrder['orderItems'] as List<dynamic>).cast<Map<String, dynamic>>();
      final orderItems = rawItems
          .map(
            (item) => OrderItemDto()
              ..productId = item['productId']
              ..price = double.parse(item['price'].toString())
              ..quantity = item['quantity']
              ..total = double.parse(item['total'].toString()),
          )
          .toList();

      await isar.orderItemDtos.putAll(orderItems);
      order.orderItems.addAll(orderItems);
      await order.orderItems.save();

      inspect({'orderId': orderId, 'items': orderItems.length});
    });
  }

  //แก้ไขออเดอร์ วอย ออเดอร์
  static Future voidOrder({required int orderId}) async {
    final _authService = AuthService();
    final url = Uri.https(publicUrl, '/api/order/$orderId/void');
    var headers = {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
    final response = await http.post(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  //เปิดกะงาน
  static Future openShift({
    required Map<String, dynamic> formattedShift,
  }) async {
    final _authService = AuthService();
    final url = Uri.https(publicUrl, '/api/shift');
    var headers = {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode(formattedShift),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  //เปิดกะงาน
  static Future<int?> openShiftOffline({
    required Map<String, dynamic> formattedShift,
  }) async {
    await isar.writeTxn(() async {
      final shift = Shift(1)
        ..uuid = Uuid().v7()
        ..change = double.parse(formattedShift['change'].toString())
        ..cash = double.parse(formattedShift['cash'].toString())
        ..remark = formattedShift['remark']
        ..status = 'open';

      final shiftId = await isar.shifts.put(shift);

      return shiftId;
    });
  }

  //ปิดกะงาน
  static Future closedShift({required int shiftId}) async {
    try {
      final _authService = AuthService();
      final url = Uri.https(publicUrl, '/api/shift/$shiftId/off');
      var headers = {
        'Authorization': 'Bearer ${_authService.currentToken}',
        'Content-Type': 'application/json',
      };

      print('🔍 Debug - Close Shift API Call:');
      print('   URL: $url');
      print('   ShiftId: $shiftId');
      print('   Token: ${_authService.currentToken?.substring(0, 20)}...');

      final response = await http.post(url, headers: headers);

      print('🔍 Debug - API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = convert.jsonDecode(response.body);
        return data;
      } else {
        final data = convert.jsonDecode(response.body);
        print('❌ API Error: ${data['message']}');
        throw Exception(data['message']);
      }
    } catch (e) {
      print('❌ Exception in closedShift: $e');
      rethrow;
    }
  }

  //เช็คยูสเซอร์ที่ล็อกอินอยู่
  static Future checkLogin() async {
    final _authService = AuthService();
    final url = Uri.https(publicUrl, '/api/auth/me');
    var headers = {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  //เช็ค device id เครื่องที่ลงทะเบียน
  static Future checkDevice({required String deviceId}) async {
    final _authService = AuthService();
    final url = Uri.https(publicUrl, '/api/device/check-device', {
      "deviceId": deviceId,
    });
    var headers = {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  //เพิ่ม device id
  static Future registerDevice({
    required String deviceId,
    required String name,
    required String description,
  }) async {
    final _authService = AuthService();
    final url = Uri.https(publicUrl, '/api/device');
    var headers = {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "deviceId": deviceId,
        "name": name,
        "description": description,
        "active": true,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }
}
