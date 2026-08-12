import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/database_service.dart';
import '../models/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DatabaseService _dbService = DatabaseService();
  final MobileScannerController cameraController = MobileScannerController();

  String? scannedStudentId;
  String? scannedStudentName;
  bool isScanning = true;

  void _markAttendance(String classId, String className) async {
    if (scannedStudentId == null) return;

    final attendance = Attendance(
      studentId: scannedStudentId!,
      classId: classId,
    );

    try {
      await _dbService.insertData('attendance', attendance.toMap());
      _showSnackBar(
        '$scannedStudentName ව $className පන්තියට සටහන් කළා!',
        Colors.green,
      );
      _resetScanner();
    } catch (e) {
      _showSnackBar('දෝෂයකි: දැනටමත් පැමිණීම සටහන් කර ඇත.', Colors.blue);
    }
  }

  // Stuck වීම වැළැක්වීමට මෙතැන කැමරාව stop/start කරන්නේ නැත
  void _resetScanner() {
    setState(() {
      scannedStudentId = null;
      scannedStudentName = null;
      isScanning = true;
    });
  }

  Future<void> _fetchStudentName(String id) async {
    try {
      final data = await _dbService.getDataWithQuery(
        'students',
        column: 'id',
        value: id,
      );

      if (data.isNotEmpty) {
        setState(() {
          scannedStudentName = data.first['name'];
        });
      } else {
        _showSnackBar("ශිෂ්‍යයා හමු නොවීය!", Colors.orange);
        _resetScanner();
      }
    } catch (e) {
      _resetScanner();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Column(
        children: [
          // Scanner එක හැමවෙලේම තියෙනවා, පේන්නේ නැති කරන්න විතරයි කරන්නේ
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (BarcodeCapture capture) {
                    // isScanning false නම් ස්කෑන් ලොජික් එක වැඩ කරන්නේ නැහැ
                    if (!isScanning) return;

                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null) {
                        setState(() {
                          isScanning =
                              false; // මෙතනදී Scanner එක "Pause" වෙනවා වගේ වැඩක් වෙන්නේ
                          scannedStudentId = code;
                        });
                        _fetchStudentName(code);
                      }
                    }
                  },
                ),
                // ස්කෑන් වූ පසු කැමරාව උඩින් නිල් පාට Screen එකක් පෙන්වනවා
                if (!isScanning)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 80,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            scannedStudentName ?? "Loading...",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "ID: $scannedStudentId",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (!isScanning)
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                ),
                child: Column(
                  children: [
                    const Text(
                      "SELECT CLASS TO MARK PRESENT",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _dbService.getFilteredStream(
                          'full_enrollment_details',
                          'student_id',
                          scannedStudentId!,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("ලියාපදිංචි වී නැත."),
                            );
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data![index];
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    data['class_name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${data['subject']} | ${data['teacher_name']}",
                                  ),
                                  onTap: () => _markAttendance(
                                    data['class_id'],
                                    data['class_name'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scan Next QR"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
