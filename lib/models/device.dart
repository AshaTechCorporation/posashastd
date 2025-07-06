import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? code;
  String? name;
  String? description;
  bool? active;

  Device(this.id, {this.createdAt, this.updatedAt, this.deletedAt, this.code, this.name, this.description, this.active});

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
