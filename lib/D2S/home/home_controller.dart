import 'dart:developer';

import 'package:get/get.dart';
import 'package:posashastd/models/product.dart';

import '../../models/panel.dart';
import '../../models/panel_product.dart';
import '../../services/database_service.dart';

class HomeController extends GetxController {
  List<Product> products = <Product>[].obs;
  List<Panel> panels = <Panel>[].obs;

  final _databaseService = DatebaseService();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() async {
    log('Fetch Products');
    try {
      // final products = await _databaseService.getProducts();
      // this.products.assignAll(products);

      final panel = await _databaseService.getPanels();
      panels.assignAll(panel);
    } catch (e) {
      log('Fetch Products Error: $e');
      // handle error
    }
  }

  void addPanel() {
    panels.add(
      Panel(
        0,
        panelProducts: List.generate(
          20,
          (i) => PanelProduct(0),
        ),
      ),
    );
    update();
  }
}
