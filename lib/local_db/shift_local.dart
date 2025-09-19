import 'package:isar_community/isar.dart';

part 'shift_local.g.dart';

@collection
class ShiftLocal {
  Id id = Isar.autoIncrement;
  String? uuid;
  double? change;
  double? cash;
  String? remark;
  String? status;
}
