// // lib/models/review_model.dart
// class Review {
//   final String id;
//   final String productId;
//   final String productName;
//   final String? productImage;
//   final String buyerId;
//   final String buyerName;
//   final String? buyerImage;
//   final String orderId;
//   final String orderItemId;
//   final int rating;
//   final String title;
//   final String comment;
//   final List<String> images;
//   final bool verifiedPurchase;
//   final String status;
//   final bool isEdited;
//   final DateTime? editedAt;
//   final int helpfulCount;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Review({
//     required this.id,
//     required this.productId,
//     required this.productName,
//     this.productImage,
//     required this.buyerId,
//     required this.buyerName,
//     this.buyerImage,
//     required this.orderId,
//     required this.orderItemId,
//     required this.rating,
//     required this.title,
//     required this.comment,
//     required this.images,
//     required this.verifiedPurchase,
//     required this.status,
//     required this.isEdited,
//     this.editedAt,
//     required this.helpfulCount,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Review.fromJson(Map<String, dynamic> json) {
//     return Review(
//       id: json['_id'] ?? '',
//       productId: json['productId'] ?? '',
//       productName: json['productName'] ?? '',
//       productImage: json['productImage'],
//       buyerId: json['buyerId'] ?? '',
//       buyerName: json['buyerName'] ?? '',
//       buyerImage: json['buyerImage'],
//       orderId: json['orderId'] ?? '',
//       orderItemId: json['orderItemId'] ?? '',
//       rating: json['rating'] ?? 0,
//       title: json['title'] ?? '',
//       comment: json['comment'] ?? '',
//       images: List<String>.from(
//         json['images']?.map((x) => x['url'] ?? x) ?? [],
//       ),
//       verifiedPurchase: json['verifiedPurchase'] ?? false,
//       status: json['status'] ?? 'pending',
//       isEdited: json['isEdited'] ?? false,
//       editedAt: json['editedAt'] != null
//           ? DateTime.parse(json['editedAt'])
//           : null,
//       helpfulCount: json['helpfulCount'] ?? 0,
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'productId': productId,
//       'productName': productName,
//       'productImage': productImage,
//       'buyerId': buyerId,
//       'buyerName': buyerName,
//       'buyerImage': buyerImage,
//       'orderId': orderId,
//       'orderItemId': orderItemId,
//       'rating': rating,
//       'title': title,
//       'comment': comment,
//       'images': images.map((url) => {'url': url}).toList(),
//       'verifiedPurchase': verifiedPurchase,
//       'status': status,
//       'isEdited': isEdited,
//       'editedAt': editedAt?.toIso8601String(),
//       'helpfulCount': helpfulCount,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }
// }

// class ReviewableItem {
//   final String orderId;
//   final DateTime orderDate;
//   final String orderItemId;
//   final String productId;
//   final String productName;
//   final String? productImage;
//   final int quantity;
//   final DateTime purchasedDate;
//   final bool canReview;

//   ReviewableItem({
//     required this.orderId,
//     required this.orderDate,
//     required this.orderItemId,
//     required this.productId,
//     required this.productName,
//     this.productImage,
//     required this.quantity,
//     required this.purchasedDate,
//     required this.canReview,
//   });

//   factory ReviewableItem.fromJson(Map<String, dynamic> json) {
//     return ReviewableItem(
//       orderId: json['orderId'] ?? '',
//       orderDate: DateTime.parse(json['orderDate']),
//       orderItemId: json['orderItemId'] ?? '',
//       productId: json['productId'] ?? '',
//       productName: json['productName'] ?? '',
//       productImage: json['productImage'],
//       quantity: json['quantity'] ?? 1,
//       purchasedDate: DateTime.parse(json['purchasedDate']),
//       canReview: json['canReview'] ?? false,
//     );
//   }
// }

// class ProductReviewStats {
//   final int rating5;
//   final int rating4;
//   final int rating3;
//   final int rating2;
//   final int rating1;
//   final double averageRating;
//   final int totalReviews;

//   ProductReviewStats({
//     required this.rating5,
//     required this.rating4,
//     required this.rating3,
//     required this.rating2,
//     required this.rating1,
//     required this.averageRating,
//     required this.totalReviews,
//   });

//   factory ProductReviewStats.fromJson(Map<String, dynamic> json) {
//     return ProductReviewStats(
//       rating5: json['5'] ?? 0,
//       rating4: json['4'] ?? 0,
//       rating3: json['3'] ?? 0,
//       rating2: json['2'] ?? 0,
//       rating1: json['1'] ?? 0,
//       averageRating: (json['average'] ?? 0).toDouble(),
//       totalReviews: json['total'] ?? 0,
//     );
//   }
// }
