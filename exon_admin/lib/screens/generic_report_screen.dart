import 'package:flutter/material.dart';
import '../models/report_column.dart';
import '../services/pdf_report_generator.dart';

class GenericReportScreen extends StatefulWidget {
  final String reportTitle;
  final List<ReportColumn> columns;
  final Future<List<Map<String, dynamic>>> Function() fetchData;
  final Widget? filterWidget; // Custom filters (Class, Date, etc.) එකතු කරන්න

  const GenericReportScreen({
    super.key,
    required this.reportTitle,
    required this.columns,
    required this.fetchData,
    this.filterWidget,
  });

  @override
  State<GenericReportScreen> createState() => _GenericReportScreenState();
}

class _GenericReportScreenState extends State<GenericReportScreen> {
  List<Map<String, dynamic>> reportData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadReportData();
  }

  Future<void> loadReportData() async {
    setState(() => isLoading = true);
    final data = await widget.fetchData();
    if (mounted) {
      setState(() {
        reportData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reportTitle),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadReportData,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Custom Filter UI එකක් තියෙනවා නම් පෙන්වන්න
            if (widget.filterWidget != null) widget.filterWidget!,
            const SizedBox(height: 10),

            // Action Buttons (PDF / CSV)
            if (reportData.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => PdfReportGenerator.generateAndPrintPdf(
                      reportTitle: widget.reportTitle,
                      subTitle: "Exported Report",
                      columns: widget.columns,
                      data: reportData,
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("PDF"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => PdfReportGenerator.exportToCsv(
                      reportTitle: widget.reportTitle,
                      columns: widget.columns,
                      data: reportData,
                    ),
                    icon: const Icon(Icons.table_chart),
                    label: const Text("Excel"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                  ),
                ],
              ),
            const SizedBox(height: 10),

            // Data Table View
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reportData.isEmpty
                      ? const Center(child: Text("No records found"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: [
                                const DataColumn(label: Text("#")),
                                ...widget.columns.map((c) => DataColumn(label: Text(c.title))),
                              ],
                              rows: List.generate(reportData.length, (index) {
                                final row = reportData[index];
                                return DataRow(
                                  cells: [
                                    DataCell(Text("${index + 1}")),
                                    ...widget.columns.map((c) => DataCell(Text(row[c.key]?.toString() ?? '-'))),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}