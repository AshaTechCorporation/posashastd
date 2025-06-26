import 'dart:developer';

import 'package:get/get.dart';
import 'package:posashastd/models/product.dart';

import '../../services/database_service.dart';

class HomeController extends GetxController {
  List<Product> products = <Product>[].obs;

  final _databaseService = DatebaseService();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() async {
    log('Fetch Products');
    try {
      final products = await _databaseService.getProducts();
      this.products.assignAll(products);

      final panel = await _databaseService.getPanels();
      inspect(panel);
      log('Panel: ${panel.length}');

    } catch (e) {
      // handle error
    }
  }
}
