import 'package:flutter/material.dart';

class ColorUtils {
  // Convert hex color string to Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Convert Color to hex string
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
}
// lib/utils/date_utils.dart
