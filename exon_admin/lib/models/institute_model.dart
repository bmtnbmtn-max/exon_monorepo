class Institute {
  final String? id;
  final String name;
  final String address;
  final String phone1;
  final String phone2;
  final String owner;

  Institute({
    this.id,
    required this.name,
    required this.address,
    required this.phone1,
    required this.phone2,
    required this.owner,
  });

  // 1. Flutter Class එක Database එකට යැවිය හැකි Map එකක් බවට පත් කිරීම
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone1': phone1,
      'phone2': phone2,
      'owner': owner,
    };
  }

  // 2. Database එකෙන් එන Map එකක් නැවත Flutter Class එකක් බවට පත් කිරීම
  factory Institute.fromMap(Map<String, dynamic> map, String id) {
    return Institute(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone1: map['phone1'] ?? '',
      phone2: map['phone2'] ?? '',
      owner: map['owner'] ?? '',
    );
  }
}
