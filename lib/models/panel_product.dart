import 'package:json_annotation/json_annotation.dart';

import 'panel.dart';
import 'product.dart';

part 'panel_product.g.dart';

@JsonSerializable()
class PanelProduct {
  int id;
  String? color;
  int? sequence;
  Panel? panel;
  Product? product;

  PanelProduct(this.id, {this.color, this.sequence, this.panel, this.product});

  factory PanelProduct.fromJson(Map<String, dynamic> json) =>
      _$PanelProductFromJson(json);
  Map<String, dynamic> toJson() => _$PanelProductToJson(this);
}
