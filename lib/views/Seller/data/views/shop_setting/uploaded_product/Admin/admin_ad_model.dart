import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/SellerAds/seller_ad_model.dart';

/// Admin Ad Model - Extends Seller Ad with seller information
class AdminAdModel extends SellerAdModel {
  final String sellerId;
  final String sellerName;
  final String? sellerEmail;
  final String? sellerPhone;
  final String? sellerBusinessName;
  final String? sellerShopName;

  AdminAdModel({
    required super.id,
    required super.title,
    required super.description,
    super.imageUrl,
    super.videoUrl,
    required super.status,
    required super.createdAt,
    super.approvedAt,
    super.startDate,
    super.endDate,
    super.budget,
    super.impressions,
    super.clicks,
    super.rejectionReason,
    super.targetAudience,
    super.category,
    required this.sellerId,
    required this.sellerName,
    this.sellerEmail,
    this.sellerPhone,
    this.sellerBusinessName,
    this.sellerShopName,
  }) : super();

  factory AdminAdModel.fromSellerAd(
    SellerAdModel ad,
    Map<String, dynamic> sellerInfo,
  ) {
    return AdminAdModel(
      id: ad.id,
      title: ad.title,
      description: ad.description,
      imageUrl: ad.imageUrl,
      videoUrl: ad.videoUrl,
      status: ad.status,
      createdAt: ad.createdAt,
      approvedAt: ad.approvedAt,
      startDate: ad.startDate,
      endDate: ad.endDate,
      budget: ad.budget,
      impressions: ad.impressions,
      clicks: ad.clicks,
      rejectionReason: ad.rejectionReason,
      targetAudience: ad.targetAudience,
      category: ad.category,
      sellerId:
          sellerInfo['id']?.toString() ?? sellerInfo['_id']?.toString() ?? '',
      sellerName: sellerInfo['name']?.toString() ?? 'Unknown Seller',
      sellerEmail: sellerInfo['email']?.toString(),
      sellerPhone: sellerInfo['phone']?.toString(),
      sellerBusinessName: sellerInfo['businessName']?.toString(),
      sellerShopName: sellerInfo['shopName']?.toString(),
    );
  }

  factory AdminAdModel.fromJson(Map<String, dynamic> json) {
    final sellerInfo = json['seller'] as Map<String, dynamic>? ?? {};
    final adData = Map<String, dynamic>.from(json);
    adData.remove('seller');

    return AdminAdModel.fromSellerAd(
      SellerAdModel.fromJson(adData),
      sellerInfo,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['seller'] = {
      'id': sellerId,
      'name': sellerName,
      'email': sellerEmail,
      'phone': sellerPhone,
      'businessName': sellerBusinessName,
      'shopName': sellerShopName,
    };
    return json;
  }

  bool get canApprove => status == AdStatus.pending;
  bool get canReject => status == AdStatus.pending;
  bool get canEdit => status == AdStatus.pending || status == AdStatus.rejected;
}
