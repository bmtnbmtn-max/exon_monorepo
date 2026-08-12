import 'package:exon_teacher/models/class_model.dart';
import 'package:exon_teacher/screens/class_registration_screen.dart';
import 'package:exon_teacher/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../universal_search.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final DatabaseService _dbService = DatabaseService();
  final String? currentId = AuthService.userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UniversalSearchDelegate(
                  tableName: 'classes',
                  searchField: 'class_name',
                  onSelected: (data) {
                    final selectedClass = Class.fromMap(
                      data,
                      data['id'].toString(),
                    );
                    // Class Edit පේජ් එකට යන්න
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClassRegistrationScreen(clz: selectedClass),
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
          'classes',
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

          final clss = snapshot.data!
              .map((item) => Class.fromMap(item, item['id'].toString()))
              .toList();

          return ListView.builder(
            itemCount: clss.length,
            itemBuilder: (context, index) {
              final clz = clss[index];

              // **මකා දැමීමේ පහසුකම (Dismissible)**
              return Dismissible(
                key: Key(clz.id!), // අනිවාර්යයෙන්ම ID එක දෙන්න
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
                  _dbService.deleteData('classes', clz.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class Deleted !')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.save, color: Colors.white),
                    ),
                    title: Text(
                      clz.className,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(clz.subject),
                    // trailing: const Icon(Icons.edit, size: 20, color: Colors.indigo),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ClassRegistrationScreen(clz: clz),
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
              builder: (context) => const ClassRegistrationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
