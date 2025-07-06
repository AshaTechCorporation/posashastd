import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? username;
  String? email;
  String? code;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  bool? isActive;
  bool? confirmed;
  String? refreshToken;

  User(
    this.id, {
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.username,
    this.email,
    this.code,
    this.confirmed,
    this.firstName,
    this.isActive,
    this.lastName,
    this.phoneNumber,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
