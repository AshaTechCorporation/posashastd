import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex'; // เติม alpha = 100% ถ้าไม่มี
  }
  return Color(int.parse(hex, radix: 16));
}
