import 'package:pdf/widgets.dart' as pw;

class ReportColumn {
  final String title; // Header එකේ පෙනෙන නම (උදා: "Student Name")
  final String key; // Map එකේ අදාළ Field key එක (උදා: "name")
  final pw.Alignment alignment; // PDF එකේ Alignment එක
  final double? width; // Column width එක (Optional)

  ReportColumn({
    required this.title,
    required this.key,
    this.alignment = pw.Alignment.centerLeft,
    this.width,
  });
}
