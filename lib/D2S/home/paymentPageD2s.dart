import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/helpers/ReceiptWidget.dart';
import 'package:posashastd/helpers/printReceiptFromCartItems.dart';
import 'package:posashastd/services/homeService.dart';
import 'package:posashastd/utils/cart_utils.dart';
import 'package:screenshot/screenshot.dart';

class PaymentPageD2s extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const PaymentPageD2s({super.key, required this.cartItems});

  @override
  State<PaymentPageD2s> createState() => _PaymentPageD2sState();
}

class _PaymentPageD2sState extends State<PaymentPageD2s> {
  double receivedAmount = 0;
  bool isPaid = false;
  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey receiptKey = GlobalKey();

  // ตัวแปรสำหรับจัดการส่วนลด
  double? selectedDiscountAmount;
  double discountAmount = 0;

  // คำนวณยอดรวมหลังหักส่วนลด
  double calculateTotalWithDiscount() {
    final originalTotal = widget.cartItems.fold(0.0, (sum, item) {
      final price = item['price'] ?? 0;
      final qty = item['qty'] ?? 1;
      return sum + (price * qty);
    });

    if (selectedDiscountAmount != null) {
      discountAmount = selectedDiscountAmount!;
      // ตรวจสอบไม่ให้ส่วนลดเกินยอดรวม
      if (discountAmount > originalTotal) {
        discountAmount = originalTotal;
      }
      return originalTotal - discountAmount;
    }

    discountAmount = 0;
    return originalTotal;
  }

  // จัดการการเลือกส่วนลด
  void handleDiscountSelection(double amount) {
    setState(() {
      if (selectedDiscountAmount == amount) {
        // ถ้ากดปุ่มเดิม ให้ยกเลิกส่วนลด
        selectedDiscountAmount = null;
        discountAmount = 0;
      } else {
        // เลือกส่วนลดใหม่
        selectedDiscountAmount = amount;
      }
    });
  }

  // เช็คเครื่องปริ้นและปริ้นใบเสร็จ
  Future<void> checkPrinterAndPrint() async {
    try {
      // ลองปริ้นและเช็คว่าสำเร็จหรือไม่
      await printReceiptFromCartItems(widget.cartItems);

      // ถ้าปริ้นสำเร็จ แสดงข้อความสำเร็จ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ปริ้นใบเสร็จสำเร็จ'), backgroundColor: Colors.green));
      }
    } catch (e) {
      // ถ้าปริ้นไม่สำเร็จ (ไม่เจอเครื่องปริ้นหรือเกิดข้อผิดพลาด)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถปริ้นใบเสร็จได้: ไม่พบเครื่องปริ๊น หรือไม่ได้เชื่อต่อเครื่องปริ๊น'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  // ✅ แสดง Dialog ยืนยันการชำระเงิน
  void _showPaymentConfirmDialog(BuildContext context, String paymentMethod, IconData icon, int paymentMethodId, bool autoSetAmount) {
    final total = calculateTotalWithDiscount();

    Get.dialog(
      AlertDialog(
        title: Row(children: [Icon(icon, color: Colors.green), const SizedBox(width: 8), Text('ยืนยันการชำระเงิน')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ต้องการชำระเงินด้วย$paymentMethod หรือไม่?', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ยอดรวม:', style: TextStyle(fontSize: 16)),
                      Text('฿${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (!autoSetAmount) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('จำนวนรับ:', style: TextStyle(fontSize: 16)),
                        Text('฿${receivedAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('เงินทอน:', style: TextStyle(fontSize: 16)),
                        Text(
                          '฿${(receivedAmount >= total ? receivedAmount - total : 0).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: receivedAmount >= total ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก', style: TextStyle(fontSize: 18))),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // ปิด dialog

              // ✅ ตั้งค่า receivedAmount สำหรับโอนและเครดิต
              if (autoSetAmount) {
                setState(() {
                  receivedAmount = total;
                });
              }

              // ✅ ตรวจสอบจำนวนเงินสำหรับเงินสด
              if (!autoSetAmount && receivedAmount < total) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('จำนวนที่รับชำระไม่เพียงพอ'), backgroundColor: Colors.red));
                return;
              }

              // ✅ ดำเนินการชำระเงิน
              setState(() {
                isPaid = true;
              });

              await createOrders(paymentMethodId: paymentMethodId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> createOrders({required int paymentMethodId}) async {
    try {
      final total = calculateTotalWithDiscount();
      final formattedOrder = {
        "deviceId": 1,
        "shiftId": 1,
        "branchId": 1,
        "total": total,
        "memberId": null,
        "date": DateTime.now().toIso8601String(),
        "orderItems":
            widget.cartItems.map((item) {
              return {"productId": item["id"] ?? 0, "price": item["price"] ?? 0, "quantity": item["qty"] ?? 0, "total": item["total"] ?? 0};
            }).toList(),
        "paymentMethodId": paymentMethodId,
        "paid": receivedAmount,
        "change": receivedAmount >= total ? receivedAmount - total : 0,
        "discount": discountAmount,
        "remark": selectedDiscountAmount != null ? "ส่วนลด ฿${selectedDiscountAmount!.toStringAsFixed(0)}" : "string",
      };

      print("📦 JSON ที่จะส่ง: $formattedOrder");
      final order = await Homeservice.createOrders(formattedOrder: formattedOrder);
      if (!mounted) return;

      setState(() {});
    } catch (e) {
      // handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final double originalTotal = widget.cartItems.fold(0, (sum, item) {
      final price = item['price'] ?? 0;
      final qty = item['qty'] ?? 1;
      return sum + (price * qty);
    });

    final double total = calculateTotalWithDiscount();

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
                          Text('รายการสินค้า', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
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
                            child: Text('USER', style: TextStyle(color: Colors.white, fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                                      Text('$name x $qty', style: const TextStyle(fontSize: 18)),
                                      Text('฿${totalItem.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(height: 1),

                          // แสดงยอดรวมก่อนส่วนลด
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('ยอดรวม', style: TextStyle(fontSize: 18)),
                                Text('฿${originalTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),

                          // แสดงส่วนลด (ถ้ามี)
                          if (selectedDiscountAmount != null) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('ส่วนลด', style: TextStyle(fontSize: 18, color: Colors.red)),
                                  Text('-฿${discountAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.red)),
                                ],
                              ),
                            ),
                          ],

                          // แสดงยอดรวมหลังหักส่วนลด
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('รวมทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                Text('฿${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child:
                                receivedAmount >= total
                                    ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ส่วนยอดรวมและคำอธิบาย
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '฿${total.toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            const Text('ยอดค้างชำระ', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                                          ],
                                        ),
                                        const SizedBox(width: 24),
                                        // เส้นแบ่งแนวตั้ง
                                        Container(width: 1, height: 50, color: Colors.grey),
                                        const SizedBox(width: 24),
                                        // ส่วนเงินทอนและคำอธิบาย
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '฿${(receivedAmount - total).toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            const Text('เงินทอน', style: TextStyle(fontSize: 18, color: Colors.green), textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ],
                                    )
                                    : Column(
                                      children: [
                                        Text(
                                          '฿${total.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        const Text('ยอดค้างชำระ', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                                      ],
                                    ),
                          ),

                          const SizedBox(height: 24),

                          if (!isPaid) ...[
                            const Text('จำนวนรับ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('฿${receivedAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                OutlinedButton(
                                  onPressed: () async {
                                    final amount = await showDialog<double>(
                                      context: context,
                                      builder: (context) {
                                        double tempAmount = 0;
                                        return AlertDialog(
                                          title: const Text("ใส่จำนวนเงิน"),
                                          content: TextField(
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(hintText: 'เช่น 500'),
                                            onChanged: (value) {
                                              tempAmount = double.tryParse(value) ?? 0;
                                            },
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("ตกลง"),
                                              onPressed: () {
                                                Navigator.of(context).pop(tempAmount);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (amount != null && amount > 0) {
                                      setState(() {
                                        receivedAmount = amount;
                                      });
                                    }
                                  },
                                  child: const Text("จำนวนเงิน", style: TextStyle(color: Colors.black)),
                                ),
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
                                          side: BorderSide(color: Colors.grey),
                                          backgroundColor: Colors.white,
                                          fixedSize: Size(130, 48), // ✅ เพิ่มความกว้างตรงนี้
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
                            Row(
                              children: [
                                // 🔹 เงินสด
                                Expanded(
                                  child: Card(
                                    elevation: 4, // เพิ่มเงา
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () {
                                        // ✅ แสดง dialog ยืนยันการชำระด้วยเงินสด
                                        if (receivedAmount >= total) {
                                          _showPaymentConfirmDialog(
                                            context,
                                            'เงินสด',
                                            Icons.payments,
                                            1, // paymentMethodId สำหรับเงินสด
                                            false, // ไม่ auto set receivedAmount
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(const SnackBar(content: Text('จำนวนที่ชำระไม่พอ'), backgroundColor: Colors.red));
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // ✅ สูงขึ้น
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.payments, color: Colors.black, size: 32), // ✅ ใหญ่ขึ้น
                                            SizedBox(height: 8),
                                            Text("เงินสด", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 🔹 โอน
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () {
                                        // ✅ แสดง dialog ยืนยันการชำระด้วยโอน
                                        _showPaymentConfirmDialog(
                                          context,
                                          'โอน',
                                          Icons.account_balance,
                                          2, // paymentMethodId สำหรับโอน
                                          true, // auto set receivedAmount = total
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.account_balance, color: Colors.black, size: 32),
                                            SizedBox(height: 8),
                                            Text("โอน", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 🔹 เครดิต
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () {
                                        // ✅ แสดง dialog ยืนยันการชำระด้วยเครดิต
                                        _showPaymentConfirmDialog(
                                          context,
                                          'เครดิต',
                                          Icons.add_card,
                                          3, // paymentMethodId สำหรับเครดิต
                                          true, // auto set receivedAmount = total
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.add_card, color: Colors.black, size: 32),
                                            SizedBox(height: 8),
                                            Text("เครดิต", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ปุ่มส่วนลด
                            const SizedBox(height: 16),
                            const Text('ส่วนลด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (final amount in [1.0, 2.0, 5.0, 10.0])
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: OutlinedButton(
                                        onPressed: () => handleDiscountSelection(amount),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: selectedDiscountAmount == amount ? Colors.green : Colors.grey,
                                            width: selectedDiscountAmount == amount ? 2 : 1,
                                          ),
                                          backgroundColor: selectedDiscountAmount == amount ? Colors.green.shade50 : Colors.white,
                                          fixedSize: const Size.fromHeight(48),
                                        ),
                                        child: Text(
                                          '฿${amount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: selectedDiscountAmount == amount ? Colors.green : Colors.black,
                                            fontWeight: selectedDiscountAmount == amount ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
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
                            GestureDetector(
                              onTap: () async {
                                await checkPrinterAndPrint();
                              },
                              child: Container(
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

  Widget buildHiddenReceiptWidget() {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: RepaintBoundary(
          key: receiptKey,
          child: Container(
            color: Colors.white,
            width: 384, // 80mm ขนาดพอดีของ Sunmi
            padding: const EdgeInsets.all(16),
            child: ReceiptWidget(cartItems: widget.cartItems, total: calculateCartTotal(widget.cartItems)),
          ),
        ),
      ),
    );
  }
}
