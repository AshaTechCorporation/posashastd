import 'package:json_annotation/json_annotation.dart';

import 'panel_product.dart';

part 'panel.g.dart';

@JsonSerializable()
class Panel {
  int id;
  String? code;
  String? name;
  List<PanelProduct>? panelProducts;

  Panel(
    this.id, {
    this.code,
    this.name,
    this.panelProducts,
  });

  factory Panel.fromJson(Map<String, dynamic> json) => _$PanelFromJson(json);
  Map<String, dynamic> toJson() => _$PanelToJson(this);
}
