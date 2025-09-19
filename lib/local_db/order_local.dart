import 'package:isar_community/isar.dart';

part 'order_local.g.dart';

@collection
class OrderLocal {
  Id id = Isar.autoIncrement;
  int? deviceId;
  int? shiftId;
  int? branchId;
  double? total;
  int? memberId;
  DateTime? date;
  int? paymentMethodId;
  double? paid;
  double? change;
  double? discount;
  String? remark;
  
  final orderItems = IsarLinks<OrderItemLocal>();
}

@collection
class OrderItemLocal {
  Id id = Isar.autoIncrement;
  int? productId;
  double? price;
  int? quantity;
  double? total;
}
