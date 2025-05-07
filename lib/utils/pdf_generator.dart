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

    // Group codes in sets of 50 (10x5) per page
    const int codesPerPage = 50;

    for (var i = 0; i < codes.length; i += codesPerPage) {
      final pageItems = codes.skip(i).take(codesPerPage).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(10.0),
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
    return pw.GridView(
      crossAxisCount: 10,  // 10 columns
      childAspectRatio: 2.0,  // Double width, half height
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      children: codes.map((code) => _buildVoucherCard(code)).toList(),
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
              fontWeight: pw.FontWeight.bold,
              fontSize: 6,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            code.code,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'For ${code.duration}',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 5),
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

  // Optional: Create a version with QR codes included
  static Future<Uint8List> generateWifiCodesPdfWithQR(List<WifiCode> codes) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4;
    const int codesPerPage = 50;

    for (var i = 0; i < codes.length; i += codesPerPage) {
      final pageItems = codes.skip(i).take(codesPerPage).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(10.0),
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