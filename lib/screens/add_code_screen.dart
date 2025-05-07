import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../models/wifi_code.dart';
import '../provides/wifi_code_provider.dart';
import '../utils/color_utils.dart';

class AddCodeScreen extends StatefulWidget {
  const AddCodeScreen({super.key});

  @override
  State<AddCodeScreen> createState() => _AddCodeScreenState();
}

class _AddCodeScreenState extends State<AddCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wifiNameController = TextEditingController();
  final _wifiCodesController = TextEditingController();
  final _customDurationController = TextEditingController();

  String _selectedDuration = '1 Hour';
  Color _selectedColor = Colors.red;
  bool _showCustomDuration = false;

  final List<String> _durationOptions = [
    '1 Hour',
    '1 Day',
    '1 Month',
    'Custom...',
  ];

  @override
  void dispose() {
    _wifiNameController.dispose();
    _wifiCodesController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  void _handleDurationChange(String? value) {
    if (value == null) return;

    setState(() {
      _selectedDuration = value;
      _showCustomDuration = value == 'Custom...';
    });
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _addCodes() {
    if (!_formKey.currentState!.validate()) return;

    final wifiName = _wifiNameController.text.trim();
    final colorHex = ColorUtils.toHex(_selectedColor);
    final codesText = _wifiCodesController.text.trim();

    if (codesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Determine the final duration value
    String duration = _selectedDuration;
    if (_showCustomDuration) {
      final customDuration = _customDurationController.text.trim();
      if (customDuration.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a custom duration'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      duration = customDuration;
    }

    // Parse codes (one per line)
    final codesList = codesText
        .split('\n')
        .map((code) => code.trim())
        .where((code) => code.isNotEmpty)
        .toList();

    if (codesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid codes found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create WifiCode objects for each code
    final now = DateTime.now().toIso8601String();
    final newCodes = codesList
        .map((code) => WifiCode(
      id: DateTime.now().millisecondsSinceEpoch.toString() + code,
      code: code,
      duration: duration,
      wifiName: wifiName,
      fontColor: colorHex,
      createdAt: now,
    ))
        .toList();

    // Add codes using provider
    Provider.of<WifiCodeProvider>(context, listen: false)
        .addMultipleCodes(newCodes);

    // Reset form
    _wifiCodesController.clear();
    _customDurationController.clear();
    setState(() {
      _selectedDuration = '1 Hour';
      _showCustomDuration = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${newCodes.length} code(s) successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _wifiNameController,
              decoration: const InputDecoration(
                labelText: 'WiFi Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a WiFi name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Color selection
            Row(
              children: [
                const Text('Font Color: '),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openColorPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _openColorPicker,
                  child: const Text('Change Color'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Codes text area
            TextFormField(
              controller: _wifiCodesController,
              decoration: const InputDecoration(
                labelText: 'WiFi Codes (one per line)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter at least one code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Duration dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
              value: _selectedDuration,
              items: _durationOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _handleDurationChange,
            ),
            const SizedBox(height: 16),

            // Custom duration field (conditional)
            if (_showCustomDuration)
              TextFormField(
                controller: _customDurationController,
                decoration: const InputDecoration(
                  labelText: 'Custom Duration',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 2 Weeks',
                ),
                validator: (value) {
                  if (_showCustomDuration &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Please enter a custom duration';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _addCodes,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add Codes'),
            ),
          ],
        ),
      ),
    );
  }
}
