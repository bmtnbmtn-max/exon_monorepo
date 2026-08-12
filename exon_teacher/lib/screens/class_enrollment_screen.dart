import 'package:exon_teacher/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ClassEnrollmentScreen extends StatefulWidget {
  const ClassEnrollmentScreen({super.key});

  @override
  State<ClassEnrollmentScreen> createState() => _ClassEnrollmentScreenState();
}

class _ClassEnrollmentScreenState extends State<ClassEnrollmentScreen> {
  final DatabaseService _dbService = DatabaseService();
  final String? currentId = AuthService.userId;

  String? selectedStudentId;
  String? selectedClassId;
  final TextEditingController _studentSearchController =
      TextEditingController();

  // Enrollment එකක් සේව් කිරීම
  void _enrollStudent() async {
    if (selectedStudentId == null || selectedClassId == null) {
      _showSnackBar('කරුණාකර ශිෂ්‍යයා සහ පන්තිය යන දෙකම තෝරන්න', Colors.orange);
      return;
    }

    try {
      await _dbService.insertData('enrollments', {
        'student_id': selectedStudentId,
        'class_id': selectedClassId,
      });
      _showSnackBar('ලියාපදිංචිය සාර්ථකයි!', Colors.green);

      // සේව් වුණාට පස්සේ fields clear කරන්න ඕනේ නම්:
      setState(() {});
    } catch (e) {
      _showSnackBar('දෝෂයකි: $e', Colors.blue);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _showDeleteDialog(
    String enrollmentId,
    String studentName,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog එකෙන් පිටත එබූ විට වැසෙන්නේ නැත
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('දත්ත ඉවත් කිරීම'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$studentName ව මෙම පන්තියෙන් ඉවත් කිරීමට ඔබට සහතිකද?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('නැත', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'ඔව්, ඉවත් කරන්න',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                // context එක mounted ද කියා පරීක්ෂා කිරීම ආරක්ෂිතයි
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                navigator.pop(); // Dialog එක වසන්න

                try {
                  await _dbService.deleteData('enrollments', enrollmentId);

                  setState(() {});

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('සාර්ථකව ඉවත් කළා!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('දෝෂයකි: $e'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Enrollment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. ශිෂ්‍යයා සෙවීමේ කොටස (Searchable Autocomplete)
            _buildStudentSearch(),
            const SizedBox(height: 15),

            // 2. පන්තිය තේරීම (Dropdown)
            _buildClassSelector(),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _enrollStudent,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Enroll Now'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),

            const Divider(height: 40, thickness: 2),

            // 3. යටින් පෙන්වන Filtered Enrollment Details
            Expanded(child: _buildFilteredEnrollmentList()),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  // ශිෂ්‍යයා සෙවීමට Autocomplete Widget එක
  Widget _buildStudentSearch() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.getFilteredStream('students', 'teacher_id', currentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        List<Map<String, dynamic>> students = snapshot.data!;

        return Autocomplete<Map<String, dynamic>>(
          displayStringForOption: (option) => option['name'],
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') return const Iterable.empty();
            return students.where(
              (st) => st['name'].toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },
          onSelected: (selection) {
            setState(() {
              selectedStudentId = selection['id'].toString();
              _studentSearchController.text = selection['name'];
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Search Student Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            );
          },
        );
      },
    );
  }

  // පන්තිය තේරීමට Dropdown එක
  Widget _buildClassSelector() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.getFilteredStream('classes', 'teacher_id', currentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Class',
            prefixIcon: Icon(Icons.class_),
            border: OutlineInputBorder(),
          ),
          value: selectedClassId,
          items: snapshot.data!.map((cl) {
            return DropdownMenuItem(
              value: cl['id'].toString(),
              child: Text("${cl['class_name']} (${cl['subject']})"),
            );
          }).toList(),
          onChanged: (val) => setState(() => selectedClassId = val),
        );
      },
    );
  }

  // පහළින් පෙන්වන ලිස්ට් එක (Filtered)
  Widget _buildFilteredEnrollmentList() {
    String filterCol = 'student_id';
    String? filterVal = selectedStudentId;

    if (selectedStudentId == null && selectedClassId == null) {
      filterCol = 'teacher_id';
      filterVal = currentId;
    }

    // ශිෂ්‍යයෙක් තෝරා නැතිනම් පන්තිය අනුව filter කරයි
    if (selectedStudentId == null && selectedClassId != null) {
      filterCol = 'class_id';
      filterVal = selectedClassId;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            selectedStudentId != null
                ? "Student's Registered Classes"
                : "Class Enrollment List",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            // මෙතනදී අපි SQL View එක පාවිච්චි කරනවා
            stream: _dbService.getFilteredStream(
              'full_enrollment_details',
              filterCol,
              filterVal,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Center(child: Text("No records found."));

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(
                        data['student_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${data['class_name']} | ${data['teacher_name']}\n${data['institute_name']}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _showDeleteDialog(
                            data['enrollment_id'],
                            data['student_name'],
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
