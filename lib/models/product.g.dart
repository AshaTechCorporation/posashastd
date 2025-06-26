// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
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
  code: json['code'] as String?,
  name: json['name'] as String?,
  image: json['image'] as String?,
  price: (json['price'] as num?)?.toInt(),
  cost: (json['cost'] as num?)?.toInt(),
  active: json['active'] as bool?,
  barcode: json['barcode'] as String?,
  remark: json['remark'] as String?,
  showType: json['showType'] as String?,
  color: json['color'] as String?,
  category:
      json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'code': instance.code,
  'name': instance.name,
  'image': instance.image,
  'price': instance.price,
  'cost': instance.cost,
  'active': instance.active,
  'barcode': instance.barcode,
  'remark': instance.remark,
  'showType': instance.showType,
  'color': instance.color,
  'category': instance.category,
  'imageUrl': instance.imageUrl,
};
