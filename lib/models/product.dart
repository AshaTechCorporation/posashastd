import 'package:json_annotation/json_annotation.dart';

import 'category.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? code;
  String? name;
  String? image;
  int? price;
  int? cost;
  bool? active;
  String? barcode;
  String? remark;
  String? showType;
  String? color;
  Category? category;
  String? imageUrl;

  Product(
    this.id, {
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.code,
    this.name,
    this.image,
    this.price,
    this.cost,
    this.active,
    this.barcode,
    this.remark,
    this.showType,
    this.color,
    this.category,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Map<String, Object?> toMap() {
  //   return {
  //     'id': id,
  //     'created_at': createdAt?.toIso8601String(),
  //     'updated_at': updatedAt?.toIso8601String(),
  //     'deleted_at': deletedAt?.toIso8601String(),
  //     'code': code,
  //     'name': name,
  //     'image': image,
  //     'price': price,
  //     'cost': cost,
  //     'active': active! ? 1 : 0 ,
  //     'barcode': barcode,
  //     'remark': remark,
  //     'category_id': null,
  //     'unit_id': null,
  //     'show_type': showType,
  //     'color': color,
  //   };
  // }

  // factory Product.fromMap(Map<String, Object?> map) {
  //   return Product(
  //     id: map['id'] as int,
  //     createdAt:
  //         map['created_at'] != null
  //             ? DateTime.parse(map['created_at'] as String)
  //             : null,
  //     updatedAt:
  //         map['updated_at'] != null
  //             ? DateTime.parse(map['updated_at'] as String)
  //             : null,
  //     deletedAt:
  //         map['deleted_at'] != null
  //             ? DateTime.parse(map['deleted_at'] as String)
  //             : null,
  //     code: map['code'] as String?,
  //     name: map['name'] as String?,
  //     image: map['image'] as String?,
  //     price: map['price'] as int?,
  //     cost: map['cost'] as int?,
  //     active: map['active'] as bool?,
  //     barcode: map['barcode'] as String?,
  //     remark: map['remark'] as String?,
  //     showType: map['show_type'] as String?,
  //     color: map['color'] as String?,
  //   );
  // }
}
