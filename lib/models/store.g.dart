// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
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
  address: json['address'] as String?,
  logo: json['logo'] as String?,
  tax: json['tax'] as String?,
);

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'code': instance.code,
  'name': instance.name,
  'address': instance.address,
  'logo': instance.logo,
  'tax': instance.tax,
};
