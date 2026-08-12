import 'package:exon_teacher/screens/class_enrollment_screen.dart';
import 'package:exon_teacher/screens/class_list_screen.dart';
import 'package:exon_teacher/screens/student_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'attendance_report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exon Teacher Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // පේළියකට කාඩ් 2 බැගින්
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              'Classes',
              LucideIcons.album,
              Colors.blue,
              const ClassListScreen(),
            ),
            _buildMenuCard(
              context,
              'Student',
              Icons.person,
              Colors.green,
              const StudentListScreen(),
            ),
            _buildMenuCard(
              context,
              'Link Teacher',
              Icons.link,
              Colors.orange,
              const ClassEnrollmentScreen(),
            ),
            _buildMenuCard(
              context,
              'Attendance Report',
              Icons.assignment_turned_in,
              Colors.blue,
              const AttendanceReportScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? nextScreen,
  ) {
    return InkWell(
      onTap: () {
        if (nextScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
