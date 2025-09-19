import 'package:flutter/material.dart';
import 'package:posashastd/local_db/product_local.dart';
import 'package:posashastd/utils/color_utils.dart';

import '../../../local_db/panel_product_local.dart';

class ProductGrid extends StatelessWidget {
  final int itemCount;
  final bool isMainTab;
  final void Function(int index, ProductLocal? product)? onTap;
  final void Function(int index)? onLongPress;
  final double width;
  final double height;
  final List<PanelProductLocal> panelProduct;

  const ProductGrid({
    super.key,
    required this.itemCount,
    required this.isMainTab,
    required this.width,
    required this.height,
    required this.panelProduct,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final gridHeight = height - 50 - 48 - 34;

    return GridView.builder(
      key: ValueKey("grid_${isMainTab ? 'main' : 'extra'}"),
      padding: const EdgeInsets.all(8),
      physics: isMainTab ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: (width * 0.7) / 5,
        mainAxisExtent: gridHeight / 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final product = panelProduct[index].product;
        final String name = product.value?.name ?? 'ไม่ระบุชื่อ';
        final String? showType = product.value?.showType;
        final String? colorHex = product.value?.color;
        final String? imageUrl = product.value?.imageUrl;

        // สร้างส่วนแสดงผลสินค้าตาม showType (เหมือนกับแท็บสินค้าทั้งหมด)
        final Widget productVisual =
            showType == 'color' && colorHex != null
                ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: hexToColor(colorHex), borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                )
                : (showType == 'image' && imageUrl != null
                    ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey)),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey)),
                            ),
                      ),
                    )
                    : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                      child: const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                    ));

        final content =
            product != null
                ? Column(
                  children: [
                    Expanded(child: productVisual),
                    Container(
                      decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.vertical(bottom: Radius.circular(6))),
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '฿${product.value?.price ?? 0}',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : Container(
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)),
                  child: const Center(child: Icon(Icons.add, color: Colors.white, size: 40)),
                );

        return GestureDetector(
          onTap: () {
            onTap?.call(index, product.value);
          },
          onLongPress: () {
            if (!isMainTab) onLongPress?.call(index);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(6), child: content),
          ),
        );
      },
    );
  }
}
