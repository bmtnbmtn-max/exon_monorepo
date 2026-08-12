import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exon_core/exon_core.dart';
import '../widgets/custom_text_field.dart';

import '../widgets/custom_button.dart';

class InstituteRegistrationScreen extends StatefulWidget {
  final Institute? institute; // Update කරනවා නම් පරණ දත්ත මෙතනට එනවා

  const InstituteRegistrationScreen({super.key, this.institute});

  @override
  State<InstituteRegistrationScreen> createState() =>
      _InstituteRegistrationScreenState();
}

class _InstituteRegistrationScreenState
    extends State<InstituteRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _ownerController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    // පිටුවට එන විට පරණ දත්ත තිබේ නම් ඒවා TextFields වලට ඇතුළත් කරනවා
    if (widget.institute != null) {
      _nameController.text = widget.institute!.name;
      _addressController.text = widget.institute!.address;
      _ownerController.text = widget.institute!.owner;
      _phone1Controller.text = widget.institute!.phone1;
      _phone2Controller.text = widget.institute!.phone2;
    }
  }

  Future<void> _saveData() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phone1Controller.text.isEmpty ||
        _phone2Controller.text.isEmpty ||
        _ownerController.text.isEmpty ||
        widget.institute == null && _usernameController.text.isEmpty ||
        widget.institute == null && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add all the essential details')),
      );
      return;
    }

    try {
      // 1. අලුතින් රෙජිස්ටර් වෙන වෙලාවකදී විතරක් Auth එකේ User කෙනෙක් හදමු
      String? userId =
          widget.institute?.id; // පරණ කෙනෙක් නම් එයාගේ ID එක ගන්නවා

      if (widget.institute == null) {
        final AuthResponse res = await Supabase.instance.client.auth.signUp(
          email: _usernameController.text
              .trim(), // මෙතන email එකට usernameController එක පාවිච්චි කරනවා නම් ඒක දෙන්න
          password: _passwordController.text.trim(),
        );
        userId = res.user?.id;
      }

      // මුලින්ම පෝරමයේ ඇති දත්ත වලින් Institute Object එකක් හදාගනිමු
      final instituteData = Institute(
        id: userId,
        name: _nameController.text,
        address: _addressController.text,
        phone1: _phone1Controller.text,
        phone2: _phone2Controller.text,
        owner: _ownerController.text,
      );

      if (widget.institute == null) {
        // අලුත් දත්තයක් ඇතුළත් කිරීම (Insert)
        await _dbService.insertData('institutes', instituteData.toMap());
      } else {
        // තියෙන දත්තයක් වෙනස් කිරීම (Update)
        await _dbService.updateData(
          'institutes',
          widget.institute!.id!,
          instituteData.toMap(),
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
          widget.institute == null
              ? 'Institute Registration'
              : 'Edit Institute',
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
                  label: 'Institute Name',
                  icon: Icons.business,
                ),

                CustomTextField(
                  controller: _addressController,
                  label: 'Location',
                  icon: Icons.location_on,
                ),

                CustomTextField(
                  controller: _phone1Controller,
                  label: 'Conrtact Number',
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
                  controller: _phone2Controller,
                  label: 'Whatsapp Number',
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
                  controller: _ownerController,
                  label: 'Owner Name',
                  icon: Icons.person,
                ),

                CustomTextField(
                  controller: _usernameController,
                  label: 'Login Email',
                  icon: Icons.account_circle_rounded,
                  enabled: widget.institute == null,
                ),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true, // මේකෙන් අකුරු තරු (*) ලකුණු විදිහට පේන්නේ
                  enabled: widget.institute == null,
                  validator: (value) {
                    if (widget.institute != null) {
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
                  text: widget.institute == null ? 'Save' : 'Update',
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
    _addressController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _ownerController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
