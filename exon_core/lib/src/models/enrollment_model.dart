class Enrollment {
  final String? id;
  final String studentId;
  final String classId;
  final String joinedDate;

  Enrollment({
    this.id,
    required this.studentId,
    required this.classId,
    required this.joinedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'class_id': classId,
      'joined_date': joinedDate,
    };
  }
}
