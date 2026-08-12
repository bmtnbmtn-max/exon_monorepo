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
