import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/constants.dart';

class PaymentConfirmDialog extends StatelessWidget {
  final String paymentMethod;
  final IconData icon;
  final int paymentMethodId;
  final bool autoSetAmount;
  final double total;
  final double receivedAmount;
  final VoidCallback onCancel;
  final Function(int paymentMethodId, bool autoSetAmount) onConfirm;

  const PaymentConfirmDialog({
    super.key,
    required this.paymentMethod,
    required this.icon,
    required this.paymentMethodId,
    required this.autoSetAmount,
    required this.total,
    required this.receivedAmount,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(children: [Icon(icon, color: Colors.green), const SizedBox(width: 8), const Text('ยืนยันการชำระเงิน')]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ต้องการชำระเงินด้วย$paymentMethod หรือไม่?', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
            child: Column(
              children: [
                // ยอดรวม
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ยอดรวม:', style: TextStyle(fontSize: 16)),
                    Text('฿${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),

                // แสดงจำนวนรับและเงินทอนเฉพาะเงินสด
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
        TextButton(onPressed: onCancel, child: const Text('ยกเลิก', style: TextStyle(fontSize: 18))),
        ElevatedButton(
          onPressed: () {
            Get.back(); // ปิด dialog
            onConfirm(paymentMethodId, autoSetAmount);
          },
          style: ElevatedButton.styleFrom(backgroundColor: kTabColor),
          child: const Text('ยืนยัน', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ],
    );
  }

  /// ✅ Static method สำหรับแสดง dialog
  static void show({
    required BuildContext context,
    required String paymentMethod,
    required IconData icon,
    required int paymentMethodId,
    required bool autoSetAmount,
    required double total,
    required double receivedAmount,
    required VoidCallback onCancel,
    required Function(int paymentMethodId, bool autoSetAmount) onConfirm,
  }) {
    Get.dialog(
      PaymentConfirmDialog(
        paymentMethod: paymentMethod,
        icon: icon,
        paymentMethodId: paymentMethodId,
        autoSetAmount: autoSetAmount,
        total: total,
        receivedAmount: receivedAmount,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
      barrierDismissible: false,
    );
  }
}
