// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PanelProduct _$PanelProductFromJson(Map<String, dynamic> json) => PanelProduct(
  (json['id'] as num).toInt(),
  color: json['color'] as String?,
  sequence: (json['sequence'] as num?)?.toInt(),
  panel:
      json['panel'] == null
          ? null
          : Panel.fromJson(json['panel'] as Map<String, dynamic>),
  product:
      json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PanelProductToJson(PanelProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'color': instance.color,
      'sequence': instance.sequence,
      'panel': instance.panel,
      'product': instance.product,
    };
