import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  // 1. Create
  Future<void> insertData(String tableName, Map<String, dynamic> data) async {
    try {
      await _supabase.from(tableName).insert(data);
    } catch (e) {
      throw Exception('Insert Error: $e');
    }
  }

  // 2. Read
  Stream<List<Map<String, dynamic>>> getStream(String tableName) {
    return _supabase.from(tableName).stream(primaryKey: ['id']);
  }

  // 3. Update
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

  // 4. Delete
  Future<void> deleteData(String tableName, String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Delete Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingCardsByTeacher(
    String teacherName,
  ) async {
    try {
      final response = await _supabase
          .from('full_enrollment_details')
          .select('*')
          .eq('teacher_name', teacherName)
          .eq('is_card_printed', false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching pending cards: $e");
      return [];
    }
  }

  Future<void> markCardsAsPrinted(List<String> studentIds) async {
    try {
      await _supabase
          .from('students')
          .update({'is_card_printed': true})
          .inFilter('id', studentIds);
    } catch (e) {
      print("Error updating card status: $e");
    }
  }
}
