import 'package:flutter/material.dart';

import '../models/wifi_code.dart';
import '../utils/color_utils.dart';

class WifiCard extends StatelessWidget {
  final WifiCode code;

  const WifiCard({
    super.key,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = ColorUtils.fromHex(code.fontColor);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code.wifiName,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              code.code,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'For ${code.duration}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}