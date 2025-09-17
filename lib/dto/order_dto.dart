import 'package:isar_community/isar.dart';

part 'order_dto.g.dart';

@collection
class OrderDto {
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
  
  final orderItems = IsarLinks<OrderItemDto>();
}

@collection
class OrderItemDto {
  Id id = Isar.autoIncrement;
  int? productId;
  double? price;
  int? quantity;
  double? total;
}
