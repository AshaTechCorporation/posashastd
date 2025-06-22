import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  final int itemCount;
  final bool isMainTab;
  final void Function(int index)? onTap;
  final void Function(int index)? onLongPress;
  final double width;
  final double height;

  const ProductGrid({
    super.key,
    required this.itemCount,
    required this.isMainTab,
    required this.width,
    required this.height,
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
        final content =
            isMainTab
                ? Column(
                  children: [
                    Expanded(child: Container(width: double.infinity, color: Colors.grey[300])),
                    Container(
                      color: Colors.black54,
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'สินค้า ${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                : Container(color: Colors.grey[300]);

        return GestureDetector(
          onTap: () => onTap?.call(index),
          onLongPress: () {
            if (!isMainTab) {
              onLongPress?.call(index);
            }
          },
          child: content,
        );
      },
    );
  }
}
