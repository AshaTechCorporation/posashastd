import 'package:flutter/material.dart';

class ProductVerticalListV2s extends StatelessWidget {
  const ProductVerticalListV2s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Row(children: const [Text('รายการทั้งหมด', style: TextStyle(color: Colors.white)), Icon(Icons.arrow_drop_down, color: Colors.white)]),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white))],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.green, onPressed: () {}, child: const Icon(Icons.add, color: Colors.white)),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green, // ใช้สีแทนรูปจริง
              ),
              alignment: Alignment.center,
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
            ),
            title: Text('AFMสินค้า $index'),
            subtitle: const Text('-'),
            trailing: Text('฿${(30 + index * 5)}.00'),
          );
        },
      ),
    );
  }
}
