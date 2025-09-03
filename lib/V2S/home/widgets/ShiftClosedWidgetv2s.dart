import 'package:flutter/material.dart';
import 'package:posashastd/constants.dart';

class ShiftClosedWidgetv2s extends StatelessWidget {
  final VoidCallback onOpenShift;

  const ShiftClosedWidgetv2s({
    super.key,
    required this.onOpenShift,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ไอคอนนาฬิกา
          const Icon(
            Icons.access_time,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          
          // ข้อความหลัก
          const Text(
            'กะปิดอยู่ กรุณาเปิดกะ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // ปุ่มเปิดกะ
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
                fontSize: 18,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kTabColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
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
