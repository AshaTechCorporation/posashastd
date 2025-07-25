import 'package:json_annotation/json_annotation.dart';

part 'summary.g.dart';

@JsonSerializable()
class Summary {
  String? payment_name;
  String? total_transactions;
  String? total_amount;

  Summary(this.payment_name, this.total_transactions, this.total_amount);

  factory Summary.fromJson(Map<String, dynamic> json) => _$SummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SummaryToJson(this);
}
