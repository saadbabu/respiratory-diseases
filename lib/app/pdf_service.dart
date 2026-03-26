import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_model.dart';

class PdfService {
  static Future<void> generateAndShareReport(List<UserDiseaseModel> results) async {
    final pdf = pw.Document();

    // Download/Load a Unicode-compliant font
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // Apply the font globally to the page
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          pw.Header(
              level: 0,
              child: pw.Text("Clinical Analysis Report",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))
          ),
          pw.SizedBox(height: 20),
          pw.Text("Generated on: ${DateTime.now().toString().split('.')[0]}"),
          pw.Divider(),

          ...results.map((disease) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 15),
                pw.Text("Condition: ${disease.name}",
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text("Affected Organ: ${disease.organ}"),
                pw.SizedBox(height: 10),
                pw.Text("Suggested Medications:"),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headers: ['Medicine Name', 'Price (Rs.)'],
                  data: disease.medications.map((m) => [
                    m['name'],
                    "Rs. ${m['price']}"
                  ]).toList(),
                ),
                pw.Divider(color: PdfColors.grey100),
              ],
            );
          }).toList(),

          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 40),
            child: pw.Text(
                "Disclaimer: This report is for informational purposes only. Please consult a qualified pharmacist or doctor before starting any medication.",
                style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Medical_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}