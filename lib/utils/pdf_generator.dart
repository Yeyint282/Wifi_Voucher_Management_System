import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/wifi_code.dart';

class PdfGenerator {
  static Future<Uint8List> generateWifiCodesPdf(List<WifiCode> codes) async {
    final pdf = pw.Document();

    // Define page format and margin
    final pageFormat = PdfPageFormat.a4;

    // Always put exactly 50 cards per page
    const int codesPerPage = 50;

    // Calculate number of pages needed
    final int numberOfPages = (codes.length / codesPerPage).ceil();

    for (int page = 0; page < numberOfPages; page++) {
      // Calculate start and end indices for this page
      final startIndex = page * codesPerPage;
      final endIndex = (startIndex + codesPerPage) < codes.length
          ? startIndex + codesPerPage
          : codes.length;

      // Extract codes for this page
      final pageItems = codes.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(6.0),
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(5.0),
              child: _buildVoucherGrid(pageItems),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildVoucherGrid(List<WifiCode> codes) {
    // If fewer than 50 codes, pad with empty cards
    final paddedCodes = List<WifiCode?>.from(codes);

    // Add null elements to make length 50 if needed
    while (paddedCodes.length < 50) {
      paddedCodes.add(null);
    }

    return pw.GridView(
      crossAxisCount: 5,  // 5 columns
      childAspectRatio: 1.5,  // Width to height ratio of 1.5
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      children: paddedCodes.map((code) {
        // Return empty space for null codes (padding)
        if (code == null) {
          return pw.Container();
        }
        // Otherwise build normal voucher card
        return _buildVoucherCard(code);
      }).toList(),
    );
  }

  static pw.Widget _buildVoucherCard(WifiCode code) {
    // Convert hex color to PdfColor
    final hexColor = code.fontColor.replaceAll('#', '');
    final r = int.parse(hexColor.substring(0, 2), radix: 16) / 255;
    final g = int.parse(hexColor.substring(2, 4), radix: 16) / 255;
    final b = int.parse(hexColor.substring(4, 6), radix: 16) / 255;
    final color = PdfColor(r, g, b);

    return pw.Container(
      margin: const pw.EdgeInsets.all(1.0),
      padding: const pw.EdgeInsets.all(2.0),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            code.wifiName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: color,
              fontSize: 12,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            code.code,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            ' ${code.duration}',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }

  static Future<void> printWifiCodes(List<WifiCode> codes) async {
    final pdfData = await generateWifiCodesPdf(codes);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  static Future<void> sharePdf(List<WifiCode> codes) async {
    final pdfData = await generateWifiCodesPdf(codes);
    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'wifi_voucher_codes.pdf',
    );
  }

  static Future<Uint8List?> generateQrCode(
      String wifiName, String password) async {
    // Generate QR code for WiFi access
    final qrData = 'WIFI:S:$wifiName;P:$password;T:WPA;;';

    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
      color: Colors.black,
      emptyColor: Colors.white,
    );

    final qrSize = 200.0;
    final qrImage = await qrPainter.toImage(qrSize);
    final ByteData? byteData =
    await qrImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return byteData.buffer.asUint8List();
    }
    return null;
  }
}