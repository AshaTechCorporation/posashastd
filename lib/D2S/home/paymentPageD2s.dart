import 'package:flutter/material.dart';

class PaymentPageD2s extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const PaymentPageD2s({super.key, required this.cartItems});

  @override
  State<PaymentPageD2s> createState() => _PaymentPageD2sState();
}

class _PaymentPageD2sState extends State<PaymentPageD2s> {
  double receivedAmount = 0;

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
        removeTop: true, // ✅ เอาช่องว่างด้านบนออกจริง ๆ
        child: Column(
          children: [
            // ✅ หัวตารางแนบชิดขอบ
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  // 🔵 ฝั่งซ้าย
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
                  // 🔴 ฝั่งขวา
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
                  // 🔵 ซ้าย
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

                  // 🔴 ขวา
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
                                const Text('จำนวนเงินที่ต้องชำระ', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
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
                            onPressed: () {},
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
