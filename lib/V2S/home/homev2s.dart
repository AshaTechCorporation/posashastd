import 'package:flutter/material.dart';
import 'package:posashastd/V2S/home/orderPagev2s.dart';
import 'package:posashastd/V2S/widgets/AppDrawerv2s.dart';

class Homev2s extends StatefulWidget {
  const Homev2s({super.key});

  @override
  State<Homev2s> createState() => _Homev2sState();
}

class _Homev2sState extends State<Homev2s> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerv2s(),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPagev2s()));
          },
          child: const Text('ตัวออเดอร์'),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: const Text('0', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          // ปุ่มชำระเงิน
          Container(
            height: 50,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.green.shade300, borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.center,
            child: const Text('ชำระเงิน\n฿80.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),

          // Dropdown และค้นหา
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('รายการทั้งหมด'),
                const Icon(Icons.arrow_drop_down),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              ],
            ),
          ),

          // GridView แสดงสินค้า
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 🔘 กล่องเทาแทนรูปภาพ
                        Container(decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8))),
                        // 🔘 ข้อความชื่อสินค้า
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black45],
                            ),
                          ),
                          child: Text(
                            'AFMสินค้า $index',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
