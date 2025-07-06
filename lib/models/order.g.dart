// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
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
  orderNo: json['orderNo'] as String?,
  orderDate:
      json['orderDate'] == null
          ? null
          : DateTime.parse(json['orderDate'] as String),
  orderStatus: json['orderStatus'] as String?,
  paid: (json['paid'] as num?)?.toInt(),
  change: (json['change'] as num?)?.toInt(),
  serviceCharge: (json['serviceCharge'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toInt(),
  vat: (json['vat'] as num?)?.toInt(),
  discount: (json['discount'] as num?)?.toInt(),
  grandTotal: (json['grandTotal'] as num?)?.toInt(),
  remark: json['remark'] as String?,
  shift:
      json['shift'] == null
          ? null
          : Shift.fromJson(json['shift'] as Map<String, dynamic>),
  orderItems:
      (json['orderItems'] as List<dynamic>?)
          ?.map((e) => OrderItems.fromJson(e as Map<String, dynamic>))
          .toList(),
  device:
      json['device'] == null
          ? null
          : Device.fromJson(json['device'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'orderNo': instance.orderNo,
  'orderDate': instance.orderDate?.toIso8601String(),
  'orderStatus': instance.orderStatus,
  'paid': instance.paid,
  'change': instance.change,
  'serviceCharge': instance.serviceCharge,
  'total': instance.total,
  'vat': instance.vat,
  'discount': instance.discount,
  'grandTotal': instance.grandTotal,
  'remark': instance.remark,
  'shift': instance.shift,
  'orderItems': instance.orderItems,
  'device': instance.device,
};
