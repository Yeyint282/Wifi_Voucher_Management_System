import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wifi_code.dart';

class StorageUtils {
  static const String wifiCodesKey = 'wifiCodes';

  static Future<List<WifiCode>> loadWifiCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? codesJson = prefs.getString(wifiCodesKey);

      if (codesJson == null) {
        return [];
      }

      final List<dynamic> decodedList = json.decode(codesJson);
      return decodedList.map((item) => WifiCode.fromJson(item)).toList();
    } catch (e) {
      print('Error loading codes: $e');
      return [];
    }
  }

  static Future<bool> saveWifiCodes(List<WifiCode> codes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedCodes =
      json.encode(codes.map((code) => code.toJson()).toList());
      return await prefs.setString(wifiCodesKey, encodedCodes);
    } catch (e) {
      debugPrint(('Error saving codes: $e'));
      return false;
    }
  }

  static Future<bool> clearWifiCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(wifiCodesKey);
    } catch (e) {
     debugPrint( ('Error clearing codes: $e'));
      return false;
    }
  }
}
