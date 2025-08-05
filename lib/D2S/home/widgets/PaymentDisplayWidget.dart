import 'package:flutter/material.dart';

class PaymentDisplayWidget extends StatelessWidget {
  final double total;
  final double receivedAmount;

  const PaymentDisplayWidget({
    super.key,
    required this.total,
    required this.receivedAmount,
  });

  // คำนวณเงินทอน
  double get changeAmount => receivedAmount - total;

  // ตรวจสอบว่าจำนวนเงินที่รับเพียงพอหรือไม่
  bool get isAmountSufficient => receivedAmount >= total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isAmountSufficient
          ? _buildPaymentWithChange()
          : _buildPendingPayment(),
    );
  }

  // ✅ แสดงยอดชำระและเงินทอน (เมื่อเงินเพียงพอ)
  Widget _buildPaymentWithChange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ส่วนยอดรวมและคำอธิบาย
        _buildAmountColumn(
          amount: total,
          label: 'ยอดค้างชำระ',
          fontSize: 32,
          color: Colors.black,
        ),
        
        const SizedBox(width: 24),
        
        // เส้นแบ่งแนวตั้ง
        _buildVerticalDivider(),
        
        const SizedBox(width: 24),
        
        // ส่วนเงินทอนและคำอธิบาย
        _buildAmountColumn(
          amount: changeAmount,
          label: 'เงินทอน',
          fontSize: 32,
          color: Colors.green,
        ),
      ],
    );
  }

  // ✅ แสดงยอดค้างชำระ (เมื่อเงินไม่เพียงพอ)
  Widget _buildPendingPayment() {
    return _buildAmountColumn(
      amount: total,
      label: 'ยอดค้างชำระ',
      fontSize: 36,
      color: Colors.black,
    );
  }

  // ✅ สร้าง Column สำหรับแสดงจำนวนเงินและป้ายกำกับ
  Widget _buildAmountColumn({
    required double amount,
    required String label,
    required double fontSize,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '฿${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: color == Colors.green ? Colors.green : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ✅ สร้างเส้นแบ่งแนวตั้ง
  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey,
    );
  }
}
