import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wifi_code.dart';

class WifiCodeProvider extends ChangeNotifier {
  List<WifiCode> _codes = [];
  bool _isLoading = false;

  List<WifiCode> get codes => _codes;

  bool get isLoading => _isLoading;

  WifiCodeProvider() {
    _loadCodes();
  }

  Future<void> _loadCodes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final codesJson = prefs.getString('wifiCodes') ?? '[]';
      final List<dynamic> decodedList = json.decode(codesJson);

      _codes = decodedList.map((item) => WifiCode.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading codes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedCodes =
      json.encode(_codes.map((code) => code.toJson()).toList());
      await prefs.setString('wifiCodes', encodedCodes);
    } catch (e) {
      debugPrint('Error saving codes: $e');
    }
  }

  void addCode(WifiCode code) {
    _codes.add(code);
    saveCodes();
    notifyListeners();
  }

  void addMultipleCodes(List<WifiCode> newCodes) {
    _codes.addAll(newCodes);
    saveCodes();
    notifyListeners();
  }

  void updateCode(String id, WifiCode updatedCode) {
    final index = _codes.indexWhere((code) => code.id == id);
    if (index >= 0) {
      _codes[index] = updatedCode;
      saveCodes();
      notifyListeners();
    }
  }

  void deleteCode(String id) {
    _codes.removeWhere((code) => code.id == id);
    saveCodes();
    notifyListeners();
  }

  void deleteAllCodes() {
    _codes.clear();
    saveCodes();
    notifyListeners();
  }

  // Statistics methods
  int get totalCodes => _codes.length;

  Set<String> get uniqueNetworks {
    return _codes.map((code) => code.wifiName).toSet();
  }

  Map<String, int> get durationBreakdown {
    Map<String, int> result = {};
    for (var code in _codes) {
      if (result.containsKey(code.duration)) {
        result[code.duration] = result[code.duration]! + 1;
      } else {
        result[code.duration] = 1;
      }
    }
    return result;
  }

  WifiCode? get mostRecentCode {
    if (_codes.isEmpty) return null;

    return _codes.reduce((a, b) {
      final dateA = DateTime.parse(a.createdAt);
      final dateB = DateTime.parse(b.createdAt);
      return dateA.isAfter(dateB) ? a : b;
    });
  }
}
