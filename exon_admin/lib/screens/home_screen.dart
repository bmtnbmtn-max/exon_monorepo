import 'package:exon_admin/screens/institute_list_screen.dart';
import 'package:exon_admin/screens/link_teacher_screen.dart';
import 'package:exon_admin/screens/student_card_generate.dart';
import 'package:exon_admin/screens/teacher_list_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exon Admin Dashboard'),
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
              'Institutes',
              Icons.business,
              Colors.blue,
              const InstituteListScreen(),
            ),
            _buildMenuCard(
              context,
              'Teachers',
              Icons.person,
              Colors.green,
              const TeacherListScreen(),
            ),
            _buildMenuCard(
              context,
              'Link Teacher',
              Icons.link,
              Colors.orange,
              const LinkTeacherScreen(),
            ),
            _buildMenuCard(
              context,
              'Generate Card',
              Icons.card_membership_outlined,
              Colors.orange,
              const StudentCardGenerateScreen(),
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
