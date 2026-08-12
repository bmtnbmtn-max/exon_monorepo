class Student {
  final String? id;
  final String name;
  final String phoneNo;
  final String whatsappNo;
  final String school;
  final String address;
  final String bDay;
  final String guardian;
  final String gurPhoneNo;
  final String gurWhatsappNo;
  final String photoUrl;
  final String teacherId;

  Student({
    this.id,
    required this.name,
    required this.phoneNo,
    required this.whatsappNo,
    required this.school,
    required this.address,
    required this.bDay,
    required this.guardian,
    required this.gurPhoneNo,
    required this.gurWhatsappNo,
    required this.photoUrl,
    required this.teacherId,
  });

  // 1. Flutter Class එක Database එකට යැවිය හැකි Map එකක් බවට පත් කිරීම
  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'phone_no': phoneNo,
      'whatsapp_no': whatsappNo,
      'school': school,
      'address': address,
      'b_day': bDay,
      'guardian': guardian,
      'gur_phone_no': gurPhoneNo,
      'gur_whatsapp_no': gurWhatsappNo,
      'photo_url': photoUrl,
      'teacher_id': teacherId,
    };
  }

  // 2. Database එකෙන් එන Map එකක් නැවත Flutter Class එකක් බවට පත් කිරීම
  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      phoneNo: map['phone_no'] ?? '',
      whatsappNo: map['whatsapp_no'] ?? '',
      school: map['school'] ?? '',
      address: map['address'] ?? '',
      bDay: map['b_day'] ?? '',
      guardian: map['guardian'] ?? '',
      gurPhoneNo: map['gur_phone_no'] ?? '',
      gurWhatsappNo: map['gur_whatsapp_no'] ?? '',
      photoUrl: map['photo_url'] ?? '',
      teacherId: map['teacher_id'] ?? '',
    );
  }
}
