import 'package:exon_teacher/services/auth_service.dart';
import 'package:exon_teacher/services/database_service.dart';
import 'package:exon_teacher/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/class_model.dart';
import '../models/institute_model.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';

class ClassRegistrationScreen extends StatefulWidget {
  final Class? clz;

  const ClassRegistrationScreen({super.key, this.clz});

  @override
  State<ClassRegistrationScreen> createState() => _ClassRegistrationScreen();
}

class _ClassRegistrationScreen extends State<ClassRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _classNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _feeController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  final DatabaseService _dbService = DatabaseService();

  Institute? _selectedInstitute;
  String? _selectedDay;
  bool _isLoading = false;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        // වෙලාව AM/PM සහිතව පිරිසිදු format එකකට සකස් කිරීම
        controller.text = picked.format(context);
      });
    }
  }

  late Future<List<Institute>> _institutesFuture;

  String? _tempInstituteId;

  @override
  void initState() {
    super.initState();
    _institutesFuture = _getTeacherInstitutes();
    if (widget.clz != null) {
      _tempInstituteId = widget.clz!.instituteId;
      _selectedDay = widget.clz!.day;
      _classNameController.text = widget.clz!.className;
      _subjectController.text = widget.clz!.subject;
      _startTimeController.text = widget.clz!.startTime;
      _endTimeController.text = widget.clz!.endTime;
      _gradeController.text = widget.clz!.grade;
      _feeController.text = widget.clz!.monthlyFee.toStringAsFixed(2);
    }
  }

  // ලොග් වී සිටින ගුරුවරයාට අදාළ ආයතන පමණක් ලබා ගැනීම
  Future<List<Institute>> _getTeacherInstitutes() async {
    // AuthService එකේ ඇති ID එක කෙලින්ම ලබා ගැනීම
    final String? currentId = AuthService.userId;

    if (currentId != null) {
      final List<Map<String, dynamic>> data = await _dbService
          .fetchTeacherInstitutes(currentId);
      return data.map((map) {
        return Institute(
          id: map['institute_id'].toString(), // View එකේ Key එක
          name: map['institute_name'] ?? '', // View එකේ Key එක
          address: '',
          phone1: '',
          phone2: '',
          owner: '',
        );
      }).toList();
    }
    return [];
  }

  Future<void> _saveClass() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final String? currentId = AuthService.userId;

        final classData = Class(
          id: widget.clz?.id,
          teacherId: currentId!,
          instituteId: _selectedInstitute!.id!,
          className: _classNameController.text,
          subject: _subjectController.text,
          grade: _gradeController.text,
          day: _selectedDay!,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          monthlyFee: double.parse(_feeController.text),
        );

        if (widget.clz == null) {
          // අලුත් දත්තයක් ඇතුළත් කිරීම (Insert)
          await _dbService.insertData('classes', classData.toMap());
        } else {
          // තියෙන දත්තයක් වෙනස් කිරීම (Update)
          await _dbService.updateData(
            'classes',
            widget.clz!.id!,
            classData.toMap(),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class registered successfully!')),
          );
          Navigator.pop(context); // සාර්ථක වූ පසු ආපසු යාම
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clz == null ? 'Register New Class' : 'Edit Class'),
      ),

      body: FutureBuilder<List<Institute>>(
        future: _institutesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final institutes = snapshot.data ?? [];

          // Edit කරන අවස්ථාවකදී, තාවකාලික ID එකෙන් නිවැරදි Object එක සොයා ගැනීම
          if (_tempInstituteId != null &&
              _selectedInstitute == null &&
              institutes.isNotEmpty) {
            try {
              _selectedInstitute = institutes.firstWhere(
                (inst) => inst.id == _tempInstituteId,
              );
            } catch (e) {
              debugPrint('Institute not found: $e');
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Class Name
                  CustomTextField(
                    controller: _classNameController,
                    label: 'Class Name',
                    icon: LucideIcons.bookOpen,
                  ),

                  // Subject
                  CustomTextField(
                    controller: _subjectController,
                    label: 'Subject',
                    icon: LucideIcons.waves,
                  ),

                  // Institute Dropdown
                  CustomDropdown<Institute>(
                    labelText: 'Select Institute',
                    prefixIcon: LucideIcons.twitch,
                    value: _selectedInstitute,
                    items: institutes,
                    itemLabelBuilder: (inst) => inst.name,
                    onChanged: (val) =>
                        setState(() => _selectedInstitute = val),
                    validator: (val) =>
                        val == null ? 'Select an Institute' : null,
                  ),
                  const SizedBox(height: 10),

                  // Day Dropdown
                  CustomDropdown<String>(
                    labelText: 'Select Day',
                    prefixIcon: Icons.calendar_today,
                    value: _selectedDay,
                    items: _days,
                    itemLabelBuilder: (day) => day,
                    onChanged: (val) => setState(() => _selectedDay = val),
                    validator: (val) => val == null ? 'Select a day' : null,
                  ),
                  const SizedBox(height: 10),

                  // Time Row (Start & End)
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Start Time',
                          hint: 'Select Time',
                          controller: _startTimeController,
                          readOnly: true, // keyboard එක පෙන්වීම වැළැක්වීමට
                          onTap: () => _selectTime(
                            context,
                            _startTimeController,
                          ), // Picker එක පෙන්වීමට
                          icon: Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextField(
                          label: 'End Time',
                          hint: 'Select Time',
                          controller: _endTimeController,
                          readOnly: true, // keyboard එක පෙන්වීම වැළැක්වීමට
                          onTap: () => _selectTime(
                            context,
                            _endTimeController,
                          ), // Picker එක පෙන්වීමට
                          icon: Icons.access_time,
                        ),
                      ),
                    ],
                  ),

                  // Fee
                  CustomTextField(
                    controller: _gradeController,
                    label: 'Grade',
                    icon: LucideIcons.currency,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),

                  CustomTextField(
                    controller: _feeController,
                    label: 'Monthly Fee',
                    icon: LucideIcons.currency,
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),

                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: widget.clz == null ? 'Save' : 'Update',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _saveClass();
                              }
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
