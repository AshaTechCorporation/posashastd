import 'package:json_annotation/json_annotation.dart';
import 'package:posashastd/models/device.dart';
import 'package:posashastd/models/orderItems.dart';
import 'package:posashastd/models/shift.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? orderNo;
  DateTime? orderDate;
  String? orderStatus;
  int? paid;
  int? change;
  int? serviceCharge;
  int? total;
  int? vat;
  int? discount;
  int? grandTotal;
  String? remark;
  Shift? shift;
  List<OrderItems>? orderItems;
  Device? device;

  Order(
    this.id, {
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.orderNo,
    this.orderDate,
    this.orderStatus,
    this.paid,
    this.change,
    this.serviceCharge,
    this.total,
    this.vat,
    this.discount,
    this.grandTotal,
    this.remark,
    this.shift,
    this.orderItems,
    this.device,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
