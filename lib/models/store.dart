import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@JsonSerializable()
class Store {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? code;
  String? name;
  String? address;
  String? logo;
  String? tax;

  Store(this.id, {this.createdAt, this.updatedAt, this.deletedAt, this.code, this.name, this.address, this.logo, this.tax});

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  Map<String, dynamic> toJson() => _$StoreToJson(this);
}
