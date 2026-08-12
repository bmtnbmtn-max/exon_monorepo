import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report_column.dart';

class PdfReportGenerator {
  // 1. Reusable PDF Generation Function
  static Future<void> generateAndPrintPdf({
    required String reportTitle,
    required String subTitle,
    required List<ReportColumn> columns,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "EXON EDUCATION INSTITUTE",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      reportTitle,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (subTitle.isNotEmpty)
                      pw.Text(
                        subTitle,
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Total Records: ${data.length}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text("Date: ${DateTime.now().toString().split(' ')[0]}"),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.blue900, thickness: 1.5),
            pw.SizedBox(height: 15),

            // Dynamic Table
            pw.Table.fromTextArray(
              headers: ['#', ...columns.map((c) => c.title)],
              data: List.generate(data.length, (index) {
                final row = data[index];
                return [
                  (index + 1).toString(),
                  ...columns.map((c) => row[c.key]?.toString() ?? '-'),
                ];
              }),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue900,
              ),
              cellHeight: 25,
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignments: {
                0: pw.Alignment.center,
                for (int i = 0; i < columns.length; i++)
                  (i + 1): columns[i].alignment,
              },
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Generated via Exon System",
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "${reportTitle.replaceAll(' ', '_')}.pdf",
    );
  }

  // 2. Pure Dart CSV Export Function (No external CSV Converter needed!)
  static Future<void> exportToCsv({
    required String reportTitle,
    required List<ReportColumn> columns,
    required List<Map<String, dynamic>> data,
  }) async {
    StringBuffer csvBuffer = StringBuffer();

    // Table Headers
    List<String> headers = ["#", ...columns.map((c) => c.title)];
    csvBuffer.writeln(headers.join(","));

    // Table Rows
    for (int i = 0; i < data.length; i++) {
      final row = data[i];
      List<String> rowData = [
        (i + 1).toString(),
        ...columns.map((c) {
          String val = row[c.key]?.toString() ?? '';
          // Commas / Newlines handling for CSV
          if (val.contains(',') || val.contains('\n')) {
            val = '"$val"';
          }
          return val;
        }),
      ];
      csvBuffer.writeln(rowData.join(","));
    }

    // Save File locally
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${reportTitle.replaceAll(' ', '_')}.csv";
    final file = File(path);
    await file.writeAsString(csvBuffer.toString());

    // Share File using standard share_plus
    await Share.shareXFiles([XFile(path)], text: '$reportTitle CSV Report');
  }
}
