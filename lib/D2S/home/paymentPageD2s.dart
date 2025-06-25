import 'package:flutter/material.dart';

class PaymentPageD2s extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const PaymentPageD2s({super.key, required this.cartItems});

  @override
  State<PaymentPageD2s> createState() => _PaymentPageD2sState();
}

class _PaymentPageD2sState extends State<PaymentPageD2s> {
  double receivedAmount = 0;
  bool isPaid = false; // ✅ เพิ่ม state สำหรับการชำระเงิน

  @override
  Widget build(BuildContext context) {
    final double total = widget.cartItems.fold(0, (sum, item) {
      final price = item['price'] ?? 0;
      final qty = item['qty'] ?? 1;
      return sum + (price * qty);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('ตัวออเดอร์', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Icon(Icons.person, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.green,
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                          const Spacer(),
                          const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Text('USER', style: TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ เนื้อหา
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.grey))),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: widget.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = widget.cartItems[index];
                                final name = item['name'] ?? '';
                                final qty = item['qty'] ?? 1;
                                final price = item['price'] ?? 0;
                                final totalItem = qty * price;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$name x $qty', style: const TextStyle(fontSize: 14)),
                                      Text('฿${totalItem.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('รวมทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('฿${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔴 ฝั่งขวา
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Text('฿${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text('ยอดค้างชำระ', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (!isPaid) ...[
                            const Text('จำนวนรับ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('฿${receivedAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                OutlinedButton(onPressed: () {}, child: const Text("จำนวนเงิน", style: TextStyle(color: Colors.black))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    for (final amount in [100, 200, 500, 1000])
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            receivedAmount = amount.toDouble();
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.grey),
                                          backgroundColor: Colors.white,
                                          fixedSize: const Size(120, 48),
                                        ),
                                        child: Text('฿${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.payments, color: Colors.black),
                              label: const Text("ชำระด้วยเงินสด", style: TextStyle(color: Colors.black)),
                              onPressed: () {
                                setState(() {
                                  isPaid = true;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                backgroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.account_balance, color: Colors.black),
                              label: const Text("โอนชำระ", style: TextStyle(color: Colors.black)),
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                backgroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),

                            // ✅ ช่องกรอกอีเมล — ไม่มีเส้นขอบ และจัดให้ดูสะอาด
                            Container(
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'กรอกอีเมล์',
                                  prefixIcon: Icon(Icons.email),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // ✅ ปุ่มพิมพ์ใบเสร็จ — จัดกลาง, ไม่มีเส้นรอบขอบ
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.print, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text('พิมพ์ใบเสร็จ', style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  // TODO: เริ่มรายการใหม่
                                  Navigator.pop(context, true);
                                },
                                icon: const Icon(Icons.check, color: Colors.white),
                                label: const Text('เริ่มรายการใหม่', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
