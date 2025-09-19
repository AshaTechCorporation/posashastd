import 'package:isar_community/isar.dart';

part 'order_item_local.g.dart';

@collection
class OrderItemLocal {
  Id id = Isar.autoIncrement;
  int? productId;
  double? price;
  int? quantity;
  double? total;
}
