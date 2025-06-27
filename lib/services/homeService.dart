import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:posashastd/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homeservice {
  const Homeservice();

  //เรียกดูข้อมูล Category
  static Future getCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // final domain = prefs.getString('domain');
    // final token =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInVzZXJuYW1lIjoic2hvcCIsImlhdCI6MTc1MDc2ODAyMSwiZXhwIjoxNzgyMzI1NjIxfQ.czBDdUQeQgvB8YWrCSARElvRK-xxn5sbHHiQmTi65u4';
    final url = Uri.https(publicUrl, '/api/category');
    var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //final domain = prefs.getString('domain');
    // final token =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInVzZXJuYW1lIjoic2hvcCIsImlhdCI6MTc1MDc2ODAyMSwiZXhwIjoxNzgyMzI1NjIxfQ.czBDdUQeQgvB8YWrCSARElvRK-xxn5sbHHiQmTi65u4';
    Uri url;
    if (branchId != 0) {
      url = Uri.https(publicUrl, '/api/product', {"branchId": "$branchId", "categoryId": '$categoryId', "sortBy": 'createdAt:DESC'});
    } else {
      url = Uri.https(publicUrl, '/api/product', {"branchId": "null", "categoryId": '$categoryId', "sortBy": 'createdAt:DESC'});
    }
    var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
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
  static Future createOrders({required Map<String, dynamic> formattedOrder}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //final domain = prefs.getString('domain');
    // final token =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInVzZXJuYW1lIjoic2hvcCIsImlhdCI6MTc1MDc2ODAyMSwiZXhwIjoxNzgyMzI1NjIxfQ.czBDdUQeQgvB8YWrCSARElvRK-xxn5sbHHiQmTi65u4';
    final url = Uri.https(publicUrl, '/api/order/order-with-payment');
    var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final response = await http.post(url, headers: headers, body: convert.jsonEncode(formattedOrder));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = convert.jsonDecode(response.body);
      //return Shift.fromJson(data);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }
}
