import 'package:isar_community/isar.dart';

part 'order_local.g.dart';

@collection
class OrderLocal {
  Id id = Isar.autoIncrement;
  String? localNo;
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

  Map<String, dynamic> toJson() {
    return {
      'localNo': localNo,
      'deviceId': deviceId,
      'shiftId': shiftId,
      'branchId': branchId,
      'total': total,
      'memberId': memberId,
      'date': date?.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'paid': paid,
      'change': change,
      'discount': discount,
      'remark': remark,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

@collection
class OrderItemLocal {
  Id id = Isar.autoIncrement;
  int? productId;
  String? productName;
  double? price;
  int? quantity;
  double? total;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }
}
