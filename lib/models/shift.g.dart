// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shift _$ShiftFromJson(Map<String, dynamic> json) => Shift(
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
  date: json['date'] as String?,
  startShift: json['startShift'] as String?,
  endShift: json['endShift'] as String?,
  change: (json['change'] as num?)?.toInt(),
  cash: (json['cash'] as num?)?.toInt(),
  remark: json['remark'] as String?,
  status: json['status'] as String?,
  store:
      json['store'] == null
          ? null
          : Store.fromJson(json['store'] as Map<String, dynamic>),
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShiftToJson(Shift instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'date': instance.date,
  'startShift': instance.startShift,
  'endShift': instance.endShift,
  'change': instance.change,
  'cash': instance.cash,
  'remark': instance.remark,
  'status': instance.status,
  'store': instance.store,
  'user': instance.user,
};
