class Class {
  final String? id;
  final String teacherId;
  final String instituteId;
  final String className;
  final String subject;
  final String grade;
  final String day;
  final String startTime;
  final String endTime;
  final double monthlyFee;

  Class({
    this.id,
    required this.teacherId,
    required this.instituteId,
    required this.className,
    required this.subject,
    required this.grade,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.monthlyFee,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'teacher_id': teacherId,
      'institute_id': instituteId,
      'class_name': className,
      'subject': subject,
      'grade': grade,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'monthly_fee': monthlyFee,
    };
  }

  factory Class.fromMap(Map<String, dynamic> map, String id) {
    return Class(
      id: id,
      teacherId: map['teacher_id'] ?? '',
      instituteId: map['institute_id'] ?? '',
      className: map['class_name'] ?? '',
      subject: map['subject'] ?? '',
      grade: map['grade'] ?? '',
      day: map['day'] ?? '',
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
      monthlyFee: (map['monthly_fee'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
