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

  Future<List<Map<String, dynamic>>> getDataWithQuery(
    String tableName, {
    String? column,
    dynamic value,
  }) async {
    try {
      var query = _supabase.from(tableName).select();

      // column එකක් සහ value එකක් දුන්නොත් පමණක් filter කරයි
      if (column != null && value != null) {
        query = query.eq(column, value);
      }

      return await query;
    } catch (e) {
      throw Exception('Fetch Error: $e');
    }
  }

  // කොන්දේසියක් මත දත්ත Stream එකක් ලෙස ලබා ගැනීම
  Stream<List<Map<String, dynamic>>> getFilteredStream(
    String tableName,
    String column,
    String? value,
  ) {
    var query = _supabase.from(tableName).stream(primaryKey: ['id']);

    if (value != null && value.isNotEmpty) {
      return query.eq(column, value);
    }

    return query; // value එකක් නැත්නම් මුළු table එකම පෙන්වයි
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

  // teacher_institutes වගුවෙන් ගුරුවරයාට අදාළ ආයතන වල දත්ත පමණක් ලබා ගැනීම
  Future<List<Map<String, dynamic>>> fetchTeacherInstitutes(
    String teacherId,
  ) async {
    try {
      final response = await _supabase
          .from('teacher_institute_details')
          .select()
          .eq('teacher_id', teacherId);

      // print('Fetched Data for $teacherId: $response');

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      throw Exception('Error fetching teacher institutes from view: $e');
    }
  }
}
