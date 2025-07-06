// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orderItems.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItems _$OrderItemsFromJson(Map<String, dynamic> json) => OrderItems(
  (json['id'] as num).toInt(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  quantity: (json['quantity'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toDouble(),
  product:
      json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderItemsToJson(OrderItems instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'quantity': instance.quantity,
      'price': instance.price,
      'total': instance.total,
      'product': instance.product,
    };
