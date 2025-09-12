class UserModel {
  final String id;
  final String name;
  final String email;
  // final String? phone;
  // final String? address;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    // this.phone,
    // this.address,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      // phone: json['phone'],
      // address: json['address'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      // 'phone': phone,
      // 'address': address,
      'profileImage': profileImage,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    // String? phone,
    // String? address,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      // phone: phone ?? this.phone,
      // address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
