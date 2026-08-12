import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_column.dart';
import '../services/database_service.dart';
import 'generic_report_screen.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final DatabaseService _dbService = DatabaseService();

  String? selectedClassId;
  DateTime selectedDate = DateTime.now();

  List<Map<String, dynamic>> classList = [];
  bool isLoadingClasses = true;

  // Table Columns Setup
  final List<ReportColumn> attendanceColumns = [
    ReportColumn(title: "Student ID", key: "student_id"),
    ReportColumn(title: "Student Name", key: "student_name"),
    ReportColumn(title: "Class Name", key: "class_name"),
    ReportColumn(title: "Date", key: "date"),
    ReportColumn(title: "Time", key: "time"),
    ReportColumn(title: "Status", key: "status"),
  ];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  // Database එකෙන් Classes Dropdown එක සඳහා දත්ත ගෙන්නීම
  Future<void> _loadClasses() async {
    try {
      final response = await Supabase.instance.client
          .from('classes')
          .select('id, class_name');

      setState(() {
        classList = List<Map<String, dynamic>>.from(response);
        isLoadingClasses = false;
      });
    } catch (e) {
      debugPrint("Error loading classes: $e");
      setState(() => isLoadingClasses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericReportScreen(
      reportTitle: "Attendance Report",
      columns: attendanceColumns,
      // Supabase Data Fetching
      fetchData: () async {
        return await _dbService.getAttendanceReportData(
          classId: selectedClassId,
          selectedDate: selectedDate,
        );
      },
      // Filters Bar (Clean Layout with no Overflow)
      filterWidget: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 1. Class Selection Dropdown
              Expanded(
                flex: 3,
                child: isLoadingClasses
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : DropdownButtonFormField<String?>(
                        isExpanded: true,
                        value: selectedClassId,
                        decoration: const InputDecoration(
                          labelText: "Class",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              "All Classes",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ...classList.map(
                            (c) => DropdownMenuItem<String?>(
                              value: c['id'].toString(),
                              child: Text(
                                c['class_name'] ?? 'Class',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedClassId = val;
                          });
                        },
                      ),
              ),
              const SizedBox(width: 8),

              // 2. Date Selection Button
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    selectedDate.toString().split(' ')[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
