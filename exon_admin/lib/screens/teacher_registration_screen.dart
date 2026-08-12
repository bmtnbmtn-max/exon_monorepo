import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';
import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  final Teacher? teacher; // Update කරනවා නම් පරණ දත්ත මෙතනට එනවා

  const TeacherRegistrationScreen({super.key, this.teacher});

  @override
  State<TeacherRegistrationScreen> createState() =>
      _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    // පිටුවට එන විට පරණ දත්ත තිබේ නම් ඒවා TextFields වලට ඇතුළත් කරනවා
    if (widget.teacher != null) {
      _nameController.text = widget.teacher!.name;
      _subjectController.text = widget.teacher!.subject;
      _phone1Controller.text = widget.teacher!.phone1;
      _phone2Controller.text = widget.teacher!.phone2;
    }
  }

  Future<void> _saveData() async {
    if (_nameController.text.isEmpty ||
        _phone1Controller.text.isEmpty ||
        _phone2Controller.text.isEmpty ||
        _subjectController.text.isEmpty ||
        widget.teacher == null && _usernameController.text.isEmpty ||
        widget.teacher == null && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add all the essential details')),
      );
      return;
    }

    try {
      // 1. අලුතින් රෙජිස්ටර් වෙන වෙලාවකදී විතරක් Auth එකේ User කෙනෙක් හදමු
      String? userId = widget.teacher?.id; // පරණ කෙනෙක් නම් එයාගේ ID එක ගන්නවා

      if (widget.teacher == null) {
        final AuthResponse res = await Supabase.instance.client.auth.signUp(
          email: _usernameController.text
              .trim(), // මෙතන email එකට usernameController එක පාවිච්චි කරනවා නම් ඒක දෙන්න
          password: _passwordController.text.trim(),
        );
        userId = res.user?.id;
      }

      // මුලින්ම පෝරමයේ ඇති දත්ත වලින් Institute Object එකක් හදාගනිමු
      final teacherData = Teacher(
        id: userId, // Edit කරනවා නම් පරණ ID එක, නැත්නම් null
        name: _nameController.text,
        phone1: _phone1Controller.text,
        phone2: _phone2Controller.text,
        subject: _subjectController.text,
      );

      if (widget.teacher == null) {
        // අලුත් දත්තයක් ඇතුළත් කිරීම (Insert)
        await _dbService.insertData('teachers', teacherData.toMap());
      } else {
        // තියෙන දත්තයක් වෙනස් කිරීම (Update)
        await _dbService.updateData(
          'teachers',
          widget.teacher!.id!,
          teacherData.toMap(),
        );
      }

      // සාර්ථක පණිවිඩයක් පෙන්වා පෙර තිරයට යන්න
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.teacher == null ? 'Teacher Registration' : 'Edit Teacher',
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Teacher Name',
                  icon: Icons.person,
                ),

                CustomTextField(
                  controller: _subjectController,
                  label: 'Subject',
                  icon: Icons.subject,
                ),

                CustomTextField(
                  controller: _phone1Controller,
                  label: 'Conrtact Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Phone number';
                    }

                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit phone number.';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _phone2Controller,
                  label: 'Whatsapp Number',
                  icon: Icons.chat_outlined,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Phone number';
                    }

                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit phone number.';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _usernameController,
                  label: 'Login Username',
                  icon: Icons.account_circle_rounded,
                  enabled: widget.teacher == null,
                ),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true, // මේකෙන් අකුරු තරු (*) ලකුණු විදිහට පේන්නේ
                  enabled: widget.teacher == null,
                  validator: (value) {
                    if (widget.teacher != null) {
                      return null;
                    }
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                CustomButton(
                  text: widget.teacher == null ? 'Save' : 'Update',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveData();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
