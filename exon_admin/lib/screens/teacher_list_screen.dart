import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../services/database_service.dart';
import 'teacher_registration_screen.dart';
import '../universal_search.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UniversalSearchDelegate(
                  tableName: 'teachers',
                  searchField: 'name',
                  onSelected: (data) {
                    final selectedTeacher = Teacher.fromMap(
                      data,
                      data['id'].toString(),
                    );
                    // Teacher Edit පේජ් එකට යන්න
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TeacherRegistrationScreen(teacher: selectedTeacher),
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
        stream: _dbService.getStream('teachers'),
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

          final teacher = snapshot.data!
              .map((item) => Teacher.fromMap(item, item['id'].toString()))
              .toList();

          return ListView.builder(
            itemCount: teacher.length,
            itemBuilder: (context, index) {
              final teach = teacher[index];

              // **මකා දැමීමේ පහසුකම (Dismissible)**
              return Dismissible(
                key: Key(teach.id!), // අනිවාර්යයෙන්ම ID එක දෙන්න
                direction: DismissDirection.startToEnd, // වමට Swipe කළ විට
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
                  _dbService.deleteData('teachers', teach.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teacher Deleted !')),
                  );
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
                      teach.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(teach.subject),
                    // trailing: const Icon(Icons.edit, size: 20, color: Colors.indigo),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TeacherRegistrationScreen(teacher: teach),
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
              builder: (context) => const TeacherRegistrationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
