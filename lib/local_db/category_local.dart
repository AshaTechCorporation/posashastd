import 'package:isar_community/isar.dart';

part 'category_local.g.dart';

@collection
class CategoryLocal {
  Id id = Isar.autoIncrement;
  String? code;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
}
