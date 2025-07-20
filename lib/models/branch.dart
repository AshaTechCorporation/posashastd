import 'package:json_annotation/json_annotation.dart';

part 'branch.g.dart';

@JsonSerializable()
class Branch {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? code;
  String? name;
  String? address;
  String? description;
  bool? active;

  Branch(this.id, {this.createdAt, this.updatedAt, this.deletedAt, this.code, this.name, this.address, this.description, this.active});

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);

  Map<String, dynamic> toJson() => _$BranchToJson(this);
}
