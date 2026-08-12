import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';
import '../models/institute_model.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';

int _streamKey = 0; // Stream එක Refresh කිරීමට ගන්නා අගයක්

class LinkTeacherScreen extends StatefulWidget {
  const LinkTeacherScreen({super.key});

  @override
  State<LinkTeacherScreen> createState() => _LinkTeacherScreenState();
}

class _LinkTeacherScreenState extends State<LinkTeacherScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // තෝරාගත් මොඩල්ස් ගබඩා කිරීමට
  Teacher? _selectedTeacher;
  Institute? _selectedInstitute;
  bool _isLoading = false;

  // 1. ගුරුවරු සහ ආයතන ලැයිස්තු ලබාගැනීමේ Future එක
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchAllData();
  }

  Future<Map<String, dynamic>> _fetchAllData() async {
    final teachersRes = await supabase.from('teachers').select();
    final institutesRes = await supabase.from('institutes').select();

    return {
      'teachers': (teachersRes as List)
          .map((e) => Teacher.fromMap(e, e['id'].toString()))
          .toList(),
      'institutes': (institutesRes as List)
          .map((e) => Institute.fromMap(e, e['id'].toString()))
          .toList(),
    };
  }

  // 2. දත්ත සම්බන්ධ කිරීම (Linking Logic)
  Future<void> _linkTeacherAndInstitute() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await supabase.from('teacher_institutes').insert({
          'teacher_id': _selectedTeacher!.id,
          'institute_id': _selectedInstitute!.id,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Linked successfully !')),
          );
          setState(() {
            _selectedTeacher = null;
            _selectedInstitute = null;
          });
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Error !';

          // Duplicate error එකදැයි පරීක්ෂා කිරීම
          if (e.toString().contains('23505')) {
            errorMessage =
                'This teacher is already Linked with this institution.';
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Teacher & Institute')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final teachers = snapshot.data!['teachers'] as List<Teacher>;
          final institutes = snapshot.data!['institutes'] as List<Institute>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // CustomDropdown පාවිච්චි කිරීම - Teachers
                  CustomDropdown<Teacher>(
                    labelText: 'Select Teacher',
                    prefixIcon: Icons.person,
                    value: _selectedTeacher,
                    items: teachers,
                    itemLabelBuilder: (teacher) => teacher.name,
                    onChanged: (val) => setState(() => _selectedTeacher = val),
                    validator: (val) => val == null ? 'Select a Teacher' : null,
                  ),

                  const SizedBox(height: 10),

                  // CustomDropdown පාවිච්චි කිරීම - Institutes
                  CustomDropdown<Institute>(
                    labelText: 'Select Institute',
                    prefixIcon: Icons.business,
                    value: _selectedInstitute,
                    items: institutes,
                    itemLabelBuilder: (inst) => inst.name,
                    onChanged: (val) =>
                        setState(() => _selectedInstitute = val),
                    validator: (val) =>
                        val == null ? 'Select a Institute' : null,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Link Now',
                      onPressed: _linkTeacherAndInstitute,
                    ),
                  ),

                  // Form එක අවසානයේ (Column එක ඇතුළේ) මෙය එක් කරන්න
                  const SizedBox(height: 20),
                  const Text(
                    'Linked Connections',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      key: ValueKey(
                        _streamKey,
                      ), // Key එක වෙනස් වූ සැණින් Stream එක නැවත පණ ගැන්වේ
                      // පියවර 1 දී සෑදූ View එක මෙතනට දාන්න
                      stream: supabase
                          .from('teacher_institute_details')
                          .stream(primaryKey: ['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No links found.'));
                        }

                        final links = snapshot.data!;

                        return ListView.builder(
                          itemCount: links.length,
                          itemBuilder: (context, index) {
                            final link = links[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ගුරුවරයාගේ නම පේළිය
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 18,
                                                color: Colors.blueGrey,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                link['teacher_name'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ), // පේළි දෙක අතර පරතරය
                                          // ආයතනයේ නම පේළිය (ගුරුවරයාට සමාන මට්ටමින්)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.business,
                                                size: 18,
                                                color: Colors.blueGrey,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                link['institute_name'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  // fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // මකා දැමීමේ බටන් එක
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        try {
                                          await supabase
                                              .from('teacher_institutes')
                                              .delete()
                                              .match({'id': link['id']});

                                          // දත්ත මැකූ පසු UI එක Force Refresh කිරීම
                                          if (mounted) {
                                            setState(() {
                                              _streamKey++;
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Unlinked successfully!',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint('Delete error: $e');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
