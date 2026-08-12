import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  // 1. Create - ඇතුළත් කිරීම
  Future<void> insertData(String tableName, Map<String, dynamic> data) async {
    try {
      await _supabase.from(tableName).insert(data);
    } catch (e) {
      throw Exception('Insert Error: $e');
    }
  }

  // 2. Read - ලැයිස්තුව ලබා ගැනීම (Realtime Stream)
  Stream<List<Map<String, dynamic>>> getStream(String tableName) {
    return _supabase.from(tableName).stream(primaryKey: ['id']);
  }

  // 3. Update - විස්තර වෙනස් කිරීම
  Future<void> updateData(
    String tableName,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _supabase.from(tableName).update(data).eq('id', id);
    } catch (e) {
      throw Exception('Update Error in $tableName: $e');
    }
  }

  // 4. Delete - ආයතනයක් මකා දැමීම
  Future<void> deleteData(String tableName, String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Delete Error: $e');
    }
  }

  // 1. පින්ට් නොකළ ශිෂ්‍යයන් ගුරුවරයා අනුව ලබාගැනීම
  Future<List<Map<String, dynamic>>> getPendingCardsByTeacher(
    String teacherName,
  ) async {
    try {
      // මෙහිදී අපි කරන්නේ enrollments හරහා ගොස් අදාළ ගුරුවරයාගේ,
      // තවමත් කාඩ් එක පින්ට් කර නැති (is_card_printed = false) ශිෂ්‍යයන් සෙවීමයි.
      final response = await _supabase
          .from('full_enrollment_details')
          .select('*')
          .eq('teacher_name', teacherName)
          .eq('is_card_printed', false); // පින්ට් නොකළ අය විතරයි

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching pending cards: $e");
      return [];
    }
  }

  // 2. පින්ට් කළාට පසු සියලු දෙනාගේම status එක එකවර update කිරීම (Batch Update)
  Future<void> markCardsAsPrinted(List<String> studentIds) async {
    try {
      await _supabase
          .from('students')
          .update({'is_card_printed': true})
          .inFilter(
            'id',
            studentIds,
          ); // ID ලැයිස්තුවට අදාළ සියලු දෙනාම update වේ
    } catch (e) {
      print("Error updating card status: $e");
    }
  }
}
