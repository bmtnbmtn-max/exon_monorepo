import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/database_service.dart';

class StudentCardGenerateScreen extends StatefulWidget {
  const StudentCardGenerateScreen({super.key});

  @override
  State<StudentCardGenerateScreen> createState() =>
      _StudentCardGenerateScreenState();
}

class _StudentCardGenerateScreenState extends State<StudentCardGenerateScreen> {
  final DatabaseService _dbService = DatabaseService();
  String? selectedTeacher;
  List<Map<String, dynamic>> pendingStudents = [];
  bool isLoading = false;

  // 1. ගුරුවරයා තෝරාගත් විට ශිෂ්‍යයන් ගණන ලබා ගැනීම
  void _fetchPendingStudents(String? teacherName) async {
    if (teacherName == null) return;
    setState(() => isLoading = true);

    final students = await _dbService.getPendingCardsByTeacher(teacherName);

    if (mounted) {
      setState(() {
        pendingStudents = students;
        isLoading = false;
      });
    }
  }

  // 2. PDF එක සාදා පින්ට් කිරීම සහ DB Update කිරීම
  Future<void> _generateAndPrintPDF() async {
    if (pendingStudents.isEmpty) return;

    final pdf = pw.Document();

    // පින්තූර ටික මුලින්ම Download කරගන්නවා
    List<pw.ImageProvider?> studentImages = [];
    for (var student in pendingStudents) {
      if (student['photo_url'] != null &&
          student['photo_url'].toString().isNotEmpty) {
        try {
          final netImage = await networkImage(student['photo_url']);
          studentImages.add(netImage);
        } catch (e) {
          studentImages.add(null);
        }
      } else {
        studentImages.add(null);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(
          21 * PdfPageFormat.cm,
          29.5 * PdfPageFormat.cm,
          marginTop: 0.5 * PdfPageFormat.cm,
          marginLeft: 7.7 * PdfPageFormat.cm,
          marginRight: 6 * PdfPageFormat.cm,
        ),
        build: (pw.Context context) {
          return [
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(pendingStudents.length, (index) {
                return _buildPDFCard(
                  pendingStudents[index],
                  studentImages[index],
                );
              }),
            ),
          ];
        },
      ),
    );

    // PDF එක පෙන්වීම (Print Preview)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    // පින්ට් කිරීමෙන් පසු DB Update කිරීම
    List<String> ids = pendingStudents
        .map((s) => s['student_id'].toString())
        .toList();
    await _dbService.markCardsAsPrinted(ids);

    // ලැයිස්තුව Refresh කිරීම
    _fetchPendingStudents(selectedTeacher);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cards marked as printed successfully!")),
      );
    }
  }

  // PDF එක ඇතුළේ Card එකේ Design එක
  pw.Widget _buildPDFCard(
    Map<String, dynamic> student,
    pw.ImageProvider? photo,
  ) {
    return pw.Container(
      width: 150,
      height: 235,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue900, width: 6),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(height: 5),
          // Header
          pw.Text(
            'STUDENT ID CARD',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.Text(
            student['teacher_name'] + " - " + student['institute_name'],
            style: pw.TextStyle(
              fontSize: 5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Container(height: 1, color: PdfColors.blue900),
          pw.SizedBox(height: 8),

          // Student Name
          pw.Text(
            student['student_name']?.toString().toUpperCase() ??
                "UNKNOWN STUDENT",
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 3),

          // Student Details Section
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow("Contact no", student['student_phone']),
                // _infoRow("Guardian", student['guardian']),
                _infoRow("Guardian tp", student['gur_phone_no']),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Container(
            width: 38,
            height: 38,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.grey200,
              image: photo != null
                  ? pw.DecorationImage(image: photo, fit: pw.BoxFit.cover)
                  : null,
              border: pw.Border.all(color: PdfColors.blue900, width: 1),
            ),
            child: photo == null
                ? pw.Center(
                    child: pw.Text(
                      "NO PHOTO",
                      style: const pw.TextStyle(fontSize: 5),
                    ),
                  )
                : null,
          ),

          pw.SizedBox(height: 8),

          pw.BarcodeWidget(
            data: student['student_id']?.toString() ?? "N/A",
            barcode: pw.Barcode.qrCode(),
            width: 60, // QR size එක 90 සිට 65 දක්වා අඩු කළා
            height: 60,
          ),

          pw.SizedBox(height: 8),

          pw.Container(
            height: 6,
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue900,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
          ),

          pw.SizedBox(height: 8),

          // Footer info
          pw.Text(
            "POWERED BY EXON - Contact 078 375 6656",
            style: const pw.TextStyle(fontSize: 5, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  // විස්තර පේළිය ලස්සනට පෙන්වීමට උදව් වන පොඩි widget එකක්
  pw.Widget _infoRow(String label, dynamic value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: "$label: ",
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(
              text: value?.toString() ?? "-",
              style: const pw.TextStyle(fontSize: 7),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Student Cards")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ගුරුවරුන් තෝරන Dropdown එක
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _dbService.getStream('teachers'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Teacher",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedTeacher,
                  items: snapshot.data!.map((t) {
                    return DropdownMenuItem(
                      value: t['name'].toString(),
                      child: Text(t['name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedTeacher = val);
                    _fetchPendingStudents(val);
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && selectedTeacher != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.style, size: 80, color: Colors.blue[900]),
                    const SizedBox(height: 20),
                    Text(
                      "${pendingStudents.length} Pending Cards Found",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "for this teacher",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    if (pendingStudents.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: _generateAndPrintPDF,
                        icon: const Icon(Icons.print),
                        label: const Text("Generate & Print PDF"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60),
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
