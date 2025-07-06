import 'package:json_annotation/json_annotation.dart';
import 'package:posashastd/models/product.dart';

part 'orderItems.g.dart';

@JsonSerializable()
class OrderItems {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  int? quantity;
  int? price;
  double? total;
  Product? product;

  OrderItems(this.id, {this.createdAt, this.updatedAt, this.deletedAt, this.quantity, this.price, this.total, this.product});

  factory OrderItems.fromJson(Map<String, dynamic> json) => _$OrderItemsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemsToJson(this);
}
