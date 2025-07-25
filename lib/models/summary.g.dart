// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Summary _$SummaryFromJson(Map<String, dynamic> json) => Summary(
  json['payment_name'] as String?,
  json['total_transactions'] as String?,
  json['total_amount'] as String?,
);

Map<String, dynamic> _$SummaryToJson(Summary instance) => <String, dynamic>{
  'payment_name': instance.payment_name,
  'total_transactions': instance.total_transactions,
  'total_amount': instance.total_amount,
};
