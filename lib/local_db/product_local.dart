import 'package:isar_community/isar.dart';
import 'package:posashastd/local_db/category_local.dart';

part 'product_local.g.dart';

@collection
class ProductLocal {
  Id id = Isar.autoIncrement;
  String? code;
  String? name;
  String? imageUrl;
  double? price;
  String? showType;
  String? color;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  final category = IsarLink<CategoryLocal>();
}
