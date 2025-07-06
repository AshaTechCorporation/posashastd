// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
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
  username: json['username'] as String?,
  email: json['email'] as String?,
  code: json['code'] as String?,
  confirmed: json['confirmed'] as bool?,
  firstName: json['firstName'] as String?,
  isActive: json['isActive'] as bool?,
  lastName: json['lastName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  refreshToken: json['refreshToken'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'username': instance.username,
  'email': instance.email,
  'code': instance.code,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'isActive': instance.isActive,
  'confirmed': instance.confirmed,
  'refreshToken': instance.refreshToken,
};
