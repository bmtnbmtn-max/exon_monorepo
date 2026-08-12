import 'package:exon_teacher/models/student_model.dart';
import 'package:exon_teacher/services/auth_service.dart';
import 'package:exon_teacher/services/storage_service.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class StudentRegistrationScreen extends StatefulWidget {
  final Student? student; // Update කරනවා නම් පරණ දත්ත මෙතනට එනවා

  const StudentRegistrationScreen({super.key, this.student});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappNoController = TextEditingController();
  final _schoolController = TextEditingController();
  final _addressController = TextEditingController();
  final _bDayController = TextEditingController();
  final _guardianController = TextEditingController();
  final _gurPhoneNoController = TextEditingController();
  final _gurWhatsappNoController = TextEditingController();

  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  File? _pickedImage;
  final _picker = ImagePicker();
  final _storageService = StorageService();
  String? _existingImageUrl;
  final String? currentId = AuthService.userId;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990), // ශිෂ්‍යයාගේ අවම උපන් වර්ෂය
      lastDate: DateTime.now(), // අදින් පසු දින තෝරාගත නොහැක
    );

    if (picked != null) {
      setState(() {
        // ඔබට අවශ්‍ය format එකට (YYYY-MM-DD) මෙතනදී සකසා ගත හැක
        _bDayController.text = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      // Gallery එකෙන් photo එකක් ගන්න
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality:
            50, // Image size එක අඩු කරන්න compress කරනවා (highly recommended)
      );

      if (image != null) {
        setState(() {
          _pickedImage = File(image.path); // ෆයිල් එක temp save කරගන්න
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // පිටුවට එන විට පරණ දත්ත තිබේ නම් ඒවා TextFields වලට ඇතුළත් කරනවා
    if (widget.student != null) {
      _nameController.text = widget.student!.name;
      _phoneController.text = widget.student!.phoneNo;
      _whatsappNoController.text = widget.student!.whatsappNo;
      _schoolController.text = widget.student!.school;
      _addressController.text = widget.student!.address;
      _bDayController.text = widget.student!.bDay;
      _guardianController.text = widget.student!.guardian;
      _gurPhoneNoController.text = widget.student!.gurPhoneNo;
      _gurWhatsappNoController.text = widget.student!.gurWhatsappNo;
      _existingImageUrl = widget.student!.photoUrl;
    }
  }

  Future<void> _saveData() async {
    if (_pickedImage == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo first!')),
      );
      return; // පින්තූරයක් නැත්නම් මෙතනින් නතර වෙනවා
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? finalPhotoUrl = _existingImageUrl; // පරණ URL එක හෝ හිස් අගය

        // 1. අලුත් Photo එකක් තෝරාගෙන තිබේ නම් එය Upload කරන්න
        if (_pickedImage != null) {
          // temporary ID එකක් හෝ student ID එකක් පාවිච්චි කරන්න පුළුවන්
          // මෙහිදී අපි student ගේ phone number එක unique නමක් ලෙස පාවිච්චි කරමු
          // final String fileName = "stu_${_phoneController.text}";
          final String fileName =
              "stu_${_phoneController.text}_${DateTime.now().millisecondsSinceEpoch}";

          // StorageService එක හරහා upload කර URL එක ලබා ගැනීම
          final uploadedUrl = await _storageService.uploadStudentPhoto(
            _pickedImage!,
            fileName,
          );

          if (uploadedUrl != null) {
            finalPhotoUrl = uploadedUrl; // අලුත් URL එක ලබා ගනී
          }
        }

        // 2. Student Object එක සාදාගැනීම (අලුත් photoUrl එකත් සමඟ)
        final studentData = Student(
          // Edit mode එකේදී ID එක අනිවාර්යයි
          id: widget.student?.id,
          name: _nameController.text,
          phoneNo: _phoneController.text,
          whatsappNo: _whatsappNoController.text,
          school: _schoolController.text,
          address: _addressController.text,
          bDay: _bDayController.text,
          guardian: _guardianController.text,
          gurPhoneNo: _gurPhoneNoController.text,
          gurWhatsappNo: _gurWhatsappNoController.text,
          photoUrl: finalPhotoUrl!, // මෙතැනට අලුත් URL එක වැටේ
          teacherId: currentId!,
        );

        // 3. Database එකට යැවීම
        if (widget.student == null) {
          // Insert
          await _dbService.insertData('students', studentData.toMap());
        } else {
          // Update
          if (_pickedImage != null) {
            await _storageService.deleteStudentPhoto(_existingImageUrl!);
          }

          await _dbService.updateData(
            'students',
            widget.student!.id!,
            studentData.toMap(),
          );
        }

        // සාර්ථක පණිවිඩය
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Saved successfully!')));
          Navigator.pop(context, true); // true යවන්නේ list එක refresh කිරීමටයි
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        title: Text(
          widget.student == null ? 'Student Registration' : 'Edit Student',
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
                  label: 'Student Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _phoneController,
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
                  controller: _whatsappNoController,
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
                  controller: _schoolController,
                  label: 'School',
                  icon: Icons.account_circle_rounded,
                ),

                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.account_circle_rounded,
                ),

                CustomTextField(
                  controller: _bDayController,
                  label: 'Birth Day',
                  icon: Icons.account_circle_rounded,
                  readOnly: true, // keyboard එක පෙන්වීම වැළැක්වීමට
                  onTap: () => _selectDate(context),
                ),

                CustomTextField(
                  controller: _guardianController,
                  label: 'Guardian Name',
                  icon: Icons.account_circle_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _gurPhoneNoController,
                  label: 'Guardian Phone Number',
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
                  controller: _gurWhatsappNoController,
                  label: 'Guardian Whatsapp Number',
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

                // Widget build(BuildContext context) ඇතුළත
                Column(
                  children: [
                    const SizedBox(height: 16),
                    // Photo Picker Widget
                    GestureDetector(
                      onTap: _pickImage, // click කරාම gallery open වෙනවා
                      child: Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _pickedImage != null
                                  ? FileImage(
                                      _pickedImage!,
                                    ) // 1. අලුතින් තේරූ photo එක
                                  : (_existingImageUrl != null &&
                                        _existingImageUrl!.isNotEmpty)
                                  ? NetworkImage(
                                      _existingImageUrl!,
                                    ) // 2. කලින් සේව් කළ URL එක
                                  : null, // 3. දෙකම නැත්නම් null
                              child:
                                  (_pickedImage == null &&
                                      (_existingImageUrl == null ||
                                          _existingImageUrl!.isEmpty))
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            // යටින් පොඩි කැමරා icon එකක්
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

                CustomButton(
                  text: widget.student == null ? 'Save' : 'Update',
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
    _phoneController.dispose();
    _whatsappNoController.dispose();
    _schoolController.dispose();
    _addressController.dispose();
    _bDayController.dispose();
    _guardianController.dispose();
    _gurPhoneNoController.dispose();
    _gurWhatsappNoController.dispose();
    super.dispose();
  }
}
