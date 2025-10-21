import 'package:isar_community/isar.dart';
import 'package:posashastd/local_db/panel_local.dart';
import 'package:posashastd/local_db/product_local.dart';

part 'panel_product_local.g.dart';

@collection
class PanelProductLocal {
  Id id = Isar.autoIncrement;

  // สีปุ่ม + ลำดับบนหน้าปัด
  String? color; // ตัวอย่าง "#dedede"
  @Index()
  int sequence = 0;

  // timestamps
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  // ความสัมพันธ์
  final panel = IsarLink<PanelLocal>();
  final product = IsarLink<ProductLocal>();

  // ป้องกันซ้ำ (หนึ่ง panel ต่อหนึ่ง product หนึ่งครั้ง)
  // Isar ยังไม่มี composite unique => ใช้คีย์สังเคราะห์
  @Index(unique: true, caseSensitive: false)
  late String uniqueKey; // "${panelId}:${productId}"
}
