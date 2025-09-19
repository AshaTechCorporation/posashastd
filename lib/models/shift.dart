import 'package:json_annotation/json_annotation.dart';
import 'package:posashastd/models/store.dart';
import 'package:posashastd/models/user.dart';

part 'shift.g.dart';

@JsonSerializable()
class Shift {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? date;
  String? startShift;
  String? endShift;
  double? change;
  double? cash;
  String? remark;
  String? status;
  Store? store;
  User? user;

  Shift(
    this.id, {
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.date,
    this.startShift,
    this.endShift,
    this.change,
    this.cash,
    this.remark,
    this.status,
    this.store,
    this.user,
  });

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftToJson(this);
}
