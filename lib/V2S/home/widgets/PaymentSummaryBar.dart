import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posashastd/constants.dart';
import 'package:posashastd/V2S/home/orderPagev2s.dart';
import 'package:posashastd/D2S/controllers/home_controller.dart';

class PaymentSummaryBar extends StatelessWidget {
  final double totalAmount;

  const PaymentSummaryBar({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final homeController = Get.find<HomeController>();
        if (homeController.cartItems.isNotEmpty) {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPagev2s(items: homeController.cartItems)));

          // ถ้าได้ค่า true กลับมา ให้เคลียร์ออเดอร์ทั้งหมด
          if (result == true) {
            homeController.clearCart();
          }
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: kTabColor,
          borderRadius: BorderRadius.circular(4),
          border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ชำระเงิน', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('฿${totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
