import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  // Photo එකක් storage එකට upload කරලා public URL එක ලබා ගැනීමට
  Future<String?> uploadStudentPhoto(File imageFile, String studentId) async {
    try {
      // 1. File Extension එක හොයාගන්න (උදා: png, jpg)
      final fileName = imageFile.path.split('.').last;

      // 2. Storage path එක (උදා: profiles/stu_uuid.jpg)
      // studentId එක unique නිසා path එකත් unique වෙනවා.
      final path = '$studentId.$fileName';

      // 3. File එක Supabase 'students' bucket එකට upload කරන්න
      // update true මගින් කලින් තිබුණොත් replace වෙනවා.
      await _supabase.storage
          .from('students')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // 4. Upload වුණාට පස්සේ ඒ photo එක පෙන්වන්න පුළුවන් Public URL එක ලබාගන්න
      final String publicUrl = _supabase.storage
          .from('students')
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Storage Error: $e');
      return null; // Error වුණොත් null යවනවා
    }
  }

  // Storage එකෙන් පින්තූරයක් මකා දැමීම
  Future<void> deleteStudentPhoto(String imageUrl) async {
    try {
      // 1. URL එකෙන් file name එක වෙන් කර ගැනීම
      // උදා: .../storage/v1/object/public/students/stu_123.jpg -> stu_123.jpg
      final uri = Uri.parse(imageUrl);
      final String fileName = uri.pathSegments.last;

      // 2. Supabase storage එකෙන් අදාළ file එක ඉවත් කිරීම
      final List<FileObject> objects = await _supabase.storage
          .from('students')
          .remove([fileName]);

      if (objects.isNotEmpty) {
        print("Image deleted successfully: $fileName");
      }
    } catch (e) {
      print("Error deleting image from storage: $e");
      // මෙතනදී rethrow කරන්න එපා, මොකද image එක නැති වුණත් අපිට database record එක මකන්න ඕන නිසා
    }
  }
}
