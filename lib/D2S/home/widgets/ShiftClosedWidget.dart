import 'package:flutter/material.dart';
import 'package:posashastd/constants.dart';

class ShiftClosedWidget extends StatelessWidget {
  final VoidCallback onOpenShift;

  const ShiftClosedWidget({
    super.key,
    required this.onOpenShift,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ ไอคอนนาฬิกา
          const Icon(
            Icons.access_time,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          
          // ✅ ข้อความหลัก
          const Text(
            'กะปิดอยู่ กรุณาเปิดกะ',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // ✅ ปุ่มเปิดกะ
          ElevatedButton.icon(
            onPressed: onOpenShift,
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            label: const Text(
              'เปิดกะ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kTabColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
