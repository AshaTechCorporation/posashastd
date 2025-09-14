import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/V2S/home/paymentPagev2s.dart';
import 'package:posashastd/constants.dart';

class OrderPagev2s extends StatefulWidget {
  OrderPagev2s({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  @override
  State<OrderPagev2s> createState() => _OrderPagev2sState();
}

class _OrderPagev2sState extends State<OrderPagev2s> {
  // ฟังก์ชันลบรายการ
  void _removeItem(int index) {
    setState(() {
      widget.items.removeAt(index);
    });
    Get.back(); // ปิด dialog ยืนยันการลบ
    Get.back(); // ปิด dialog หลัก
    Get.snackbar('ลบสำเร็จ', 'ลบรายการออกจากตะกร้าแล้ว', backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 2));
  }

  // Dialog ยืนยันการลบ
  void _showDeleteConfirmDialog(int index) {
    final item = widget.items[index];
    Get.dialog(
      AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${item['name']}" ออกจากตะกร้าหรือไม่?'),
        actions: [
          TextButton(
            onPressed:
                () =>
                    Navigator.of(context)
                      ..pop()
                      ..pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => _removeItem(index),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialog จัดการรายการ
  void _showItemManageDialog(int index) {
    final item = widget.items[index];

    Get.dialog(
      AlertDialog(
        title: Text('${item['name']}'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final currentQty = item['qty'] ?? 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ราคา: ฿${item['price'].toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ปุ่มลด
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (currentQty > 1) {
                            setState(() {
                              widget.items[index]['qty'] = currentQty - 1;
                            });
                            setDialogState(() {}); // อัปเดท dialog
                          } else {
                            // ถ้าจำนวนเหลือ 1 ให้ปิด dialog และแสดง dialog ยืนยันการลบ
                            Get.back();
                            _showDeleteConfirmDialog(index);
                          }
                        },
                        icon: Icon(currentQty > 1 ? Icons.remove : Icons.delete, color: Colors.red, size: 20),
                      ),
                    ),

                    // แสดงจำนวน
                    Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$currentQty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),

                    // ปุ่มเพิ่ม
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            widget.items[index]['qty'] = currentQty + 1;
                          });
                          setDialogState(() {}); // อัปเดท dialog
                        },
                        icon: const Icon(Icons.add, color: Colors.green, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ปิด')),
          ElevatedButton(
            onPressed: () => _showDeleteConfirmDialog(index),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบรายการ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.items.fold(0, (sum, item) => sum + (item['price'] * (item['qty'] ?? 1)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kTabColor,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            const Text('ตัวออเดอร์', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Text(widget.items.length.toString(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        // actions: const [
        //   Icon(Icons.person_add_alt_1, color: Colors.white),
        //   SizedBox(width: 12),
        //   Icon(Icons.more_vert, color: Colors.white),
        //   SizedBox(width: 8),
        // ],
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          ...widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return GestureDetector(
              onTap: () => _showItemManageDialog(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item['name']} x ${item['qty'] ?? 1} (฿${item['price'].toStringAsFixed(2)})',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      '฿${(item['price'] * (item['qty'] ?? 1)).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('รวมทั้งหมด', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('฿${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),

      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPagev2s(items: widget.items, totalAmount: total)));
        },
        child: Container(
          height: 60,
          color: kTabColor,
          alignment: Alignment.center,
          child: Text(
            'ชำระเงิน\n฿${total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
