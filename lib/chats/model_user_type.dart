enum UserType {
  seller,
  buyer,
  unknown;

  String get name {
    switch (this) {
      case UserType.seller:
        return 'Seller';
      case UserType.buyer:
        return 'Buyer';
      case UserType.unknown:
        return 'Unknown';
    }
  }

  factory UserType.fromString(String type) {
    switch (type.toLowerCase()) {
      case 'seller':
        return UserType.seller;
      case 'buyer':
        return UserType.buyer;
      default:
        return UserType.unknown;
    }
  }
}
