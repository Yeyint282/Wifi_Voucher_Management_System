import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../models/wifi_code.dart';
import '../provides/wifi_code_provider.dart';
import '../utils/color_utils.dart';
import '../utils/pdf_generator.dart';
import '../widgets/wifi_card.dart';

class ViewCodesScreen extends StatelessWidget {
  const ViewCodesScreen({super.key});

  void _deleteAllCodes(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Codes'),
        content: const Text(
            'Are you sure you want to delete all codes? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<WifiCodeProvider>(context, listen: false)
                  .deleteAllCodes();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All codes have been deleted'),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf(BuildContext context, List<WifiCode> codes) async {
    if (codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No codes to export'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await PdfGenerator.sharePdf(codes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WifiCodeProvider>(
      builder: (context, provider, child) {
        final codes = provider.codes;

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _exportToPdf(context, codes),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export to PDF'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteAllCodes(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete All'),
                      style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : codes.isEmpty
                    ? const Center(child: Text('No voucher codes found'))
                    : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: codes.length,
                  itemBuilder: (context, index) {
                    return WifiCard(
                      code: codes[index],

                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, WifiCode code) async {
    final TextEditingController codeController =
    TextEditingController(text: code.code);
    final TextEditingController durationController =
    TextEditingController(text: code.duration);
    final TextEditingController nameController =
    TextEditingController(text: code.wifiName);

    Color selectedColor = ColorUtils.fromHex(code.fontColor);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit WiFi Code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'WiFi Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Font Color:'),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Pick a color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (color) {
                                selectedColor = color;
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (codeController.text.isNotEmpty &&
                  durationController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                final provider =
                Provider.of<WifiCodeProvider>(context, listen: false);

                final updatedCode = code.copyWith(
                  code: codeController.text.trim(),
                  duration: durationController.text.trim(),
                  wifiName: nameController.text.trim(),
                  fontColor: ColorUtils.toHex(selectedColor),
                );

                provider.updateCode(code.id, updatedCode);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
