// class BuyerModel {
//   final String? id;
//   final String fullName;
//   final String email;
//   final String? password; // ✅ ADD THIS FIELD
//   final String businessName;
//   final String contactName;
//   final String? address;
//   final String? description;
//   final String? bankName;
//   final String? iban;
//   final String? profileImagePath;
//   final bool profileCompleted;
//   final bool isActive;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   BuyerModel({
//     this.id,
//     required this.fullName,
//     required this.email,
//     this.password, // ✅ ADD THIS
//     required this.businessName,
//     required this.contactName,
//     this.address,
//     this.description,
//     this.bankName,
//     this.iban,
//     this.profileImagePath,
//     required this.profileCompleted,
//     required this.isActive,
//     this.createdAt,
//     this.updatedAt,
//   });

//   // Factory constructor
//   factory BuyerModel.fromJson(Map<String, dynamic> json) {
//     return BuyerModel(
//       id: json['_id'] ?? json['id'],
//       fullName: json['fullName'] ?? '',
//       email: json['email'] ?? '',
//       // ✅ Password is usually not returned in GET requests for security
//       password: null,
//       businessName: json['businessName'] ?? '',
//       contactName: json['contactName'] ?? '',
//       address: json['address'],
//       description: json['description'],
//       bankName: json['bankDetails']?['bankName'],
//       iban: json['bankDetails']?['iban'],
//       profileImagePath: json['profileImage']?['url'],
//       profileCompleted: json['profileCompleted'] ?? false,
//       isActive: json['isActive'] ?? true,
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : null,
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.parse(json['updatedAt'])
//           : null,
//     );
//   }

//   // toJson() method - include password for registration
//   Map<String, dynamic> toJson() {
//     return {
//       if (id != null) '_id': id,
//       'fullName': fullName,
//       'email': email,
//       if (password != null) 'password': password, // ✅ Include password
//       'businessName': businessName,
//       'contactName': contactName,
//       if (address != null) 'address': address,
//       if (description != null) 'description': description,
//       if (bankName != null || iban != null)
//         'bankDetails': {
//           if (bankName != null) 'bankName': bankName,
//           if (iban != null) 'iban': iban,
//         },
//       if (profileImagePath != null)
//         'profileImage': {
//           'url': profileImagePath,
//           'publicId': profileImagePath?.split('/').last,
//         },
//       'profileCompleted': profileCompleted,
//       'isActive': isActive,
//       if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
//       if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
//     };
//   }

//   // Method to create a copy with password (for registration)
//   BuyerModel copyWithPassword(String password) {
//     return BuyerModel(
//       id: id,
//       fullName: fullName,
//       email: email,
//       password: password, // ✅ Set password
//       businessName: businessName,
//       contactName: contactName,
//       address: address,
//       description: description,
//       bankName: bankName,
//       iban: iban,
//       profileImagePath: profileImagePath,
//       profileCompleted: profileCompleted,
//       isActive: isActive,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//     );
//   }
// }
