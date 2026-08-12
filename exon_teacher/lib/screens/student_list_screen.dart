import 'package:exon_teacher/models/student_model.dart';
import 'package:exon_teacher/screens/student_registration_screen.dart';
import 'package:exon_teacher/services/auth_service.dart';
import 'package:exon_teacher/services/storage_service.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../universal_search.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final DatabaseService _dbService = DatabaseService();
  final String? currentId = AuthService.userId;

  // ශිෂ්‍යයා සහ පින්තූරය යන දෙකම මකා දැමීම
  Future<void> deleteStudentFull(Student student) async {
    // 1. මුලින්ම storage එකෙන් පින්තූරය මකන්න
    if (student.photoUrl.isNotEmpty) {
      await StorageService().deleteStudentPhoto(student.photoUrl);
    }

    // 2. ඊට පස්සේ database එකෙන් ශිෂ්‍යයාගේ record එක මකන්න
    _dbService.deleteData('students', student.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UniversalSearchDelegate(
                  tableName: 'students',
                  searchField: 'name',
                  onSelected: (data) {
                    final selectedStudent = Student.fromMap(
                      data,
                      data['id'].toString(),
                    );

                    // Student Edit පේජ් එකට යන්න
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentRegistrationScreen(student: selectedStudent),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dbService.getFilteredStream(
          'students',
          'teacher_id',
          currentId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Data ... '));
          }

          final student = snapshot.data!
              .map((item) => Student.fromMap(item, item['id'].toString()))
              .toList();

          return ListView.builder(
            itemCount: student.length,
            itemBuilder: (context, index) {
              final stu = student[index];

              // **මකා දැමීමේ පහසුකම (Dismissible)**
              return Dismissible(
                key: Key(stu.id!), // අනිවාර්යයෙන්ම ID එක දෙන්න
                direction: DismissDirection.endToStart, // වමට Swipe කළ විට
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                // මකන්න කලින් ඇහීමක් කිරීම
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm'),
                      content: const Text('Are you sure you want to delete ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Yes, Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  // ඩේටාබේස් එකෙන් මකා දැමීම
                  deleteStudentFull(stu);
                  // _dbService.deleteData('students', stu.id!);
                  // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student Deleted !')),);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(
                      stu.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(stu.school),
                    // trailing: const Icon(Icons.edit, size: 20, color: Colors.indigo),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentRegistrationScreen(student: stu),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentRegistrationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
