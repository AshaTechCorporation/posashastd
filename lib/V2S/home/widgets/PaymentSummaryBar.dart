import 'package:flutter/material.dart';

class PaymentSummaryBar extends StatelessWidget {
  final double totalAmount;

  const PaymentSummaryBar({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade400,
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
    );
  }
}
