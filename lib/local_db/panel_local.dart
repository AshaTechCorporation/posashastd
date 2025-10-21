import 'package:isar_community/isar.dart';
import 'package:posashastd/local_db/panel_product_local.dart';
import 'package:posashastd/local_db/product_local.dart';

part 'panel_local.g.dart';

@collection
class PanelLocal {
  Id id = Isar.autoIncrement;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  final panelProducts = IsarLinks<PanelProductLocal>();
}
