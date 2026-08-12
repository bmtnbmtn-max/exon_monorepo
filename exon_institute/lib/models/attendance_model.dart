class Attendance {
  final String? id;
  final String studentId;
  final String classId;
  final String? date; // YYYY-MM-DD format එකෙන් සේව් වෙන්න
  final DateTime? createdAt;

  Attendance({
    this.id,
    required this.studentId,
    required this.classId,
    this.date,
    this.createdAt,
  });

  // Database එකෙන් ගන්නකොට
  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      studentId: map['student_id'],
      classId: map['class_id'],
      date: map['date'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  // Database එකට දානකොට
  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'class_id': classId,
      // මෙතන date එක අතින් යවන්නත් පුළුවන්,
      // නැත්නම් DB එකේ DEFAULT CURRENT_DATE තියෙන නිසා අතෑරලා දාන්නත් පුළුවන්.
    };
  }
}
