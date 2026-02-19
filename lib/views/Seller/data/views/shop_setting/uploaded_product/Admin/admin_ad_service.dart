import 'dart:developer';

import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/Admin/admin_ad_model.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/uploaded_product/SellerAds/seller_ad_model.dart';

/// Admin Ad Service
/// This service will be connected to API later
/// For now, it uses dummy data with seller information
class AdminAdService {
  // ========== DUMMY DATA ==========
  // This will be replaced with API calls later
  static final List<Map<String, dynamic>> _dummyAds = [
    {
      'id': 'ad_001',
      'title': 'Premium Wood Furniture Collection',
      'description':
          'Showcase your premium wood furniture collection to reach more customers',
      'imageUrl':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7',
      'status': 'approved',
      'createdAt': '2026-01-25T10:00:00Z',
      'approvedAt': '2026-01-26T10:00:00Z',
      'startDate': '2026-01-26T00:00:00Z',
      'endDate': '2026-02-26T00:00:00Z',
      'budget': 500.0,
      'impressions': 1250,
      'clicks': 45,
      'targetAudience': 'Homeowners, Interior Designers',
      'category': 'Furniture',
      'seller': {
        'id': 'seller_001',
        'name': 'John Woodcraft',
        'email': 'john@woodcraft.com',
        'phone': '+1234567890',
        'businessName': 'Woodcraft Furniture Co.',
        'shopName': 'Woodcraft Shop',
      },
    },
    {
      'id': 'ad_002',
      'title': 'Custom Wood Installation Services',
      'description': 'Promote your custom wood installation services',
      'imageUrl':
          'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237',
      'status': 'pending',
      'createdAt': '2026-01-29T14:30:00Z',
      'budget': 300.0,
      'targetAudience': 'Business Owners',
      'category': 'Services',
      'seller': {
        'id': 'seller_002',
        'name': 'Sarah Timber',
        'email': 'sarah@timber.com',
        'phone': '+1234567891',
        'businessName': 'Timber Installation Services',
        'shopName': 'Timber Shop',
      },
    },
    {
      'id': 'ad_003',
      'title': 'Handcrafted Wood Art Pieces',
      'description': 'Advertise your unique handcrafted wood art pieces',
      'imageUrl':
          'https://images.unsplash.com/photo-1503602642458-232111445657',
      'status': 'rejected',
      'createdAt': '2026-01-28T09:15:00Z',
      'rejectionReason': 'Image quality does not meet our standards',
      'budget': 200.0,
      'category': 'Art',
      'seller': {
        'id': 'seller_003',
        'name': 'Mike Artisan',
        'email': 'mike@artisan.com',
        'phone': '+1234567892',
        'businessName': 'Artisan Woodworks',
        'shopName': 'Artisan Gallery',
      },
    },
    {
      'id': 'ad_004',
      'title': 'Wood Flooring Solutions',
      'description': 'Promote your professional wood flooring installation',
      'imageUrl':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7',
      'status': 'completed',
      'createdAt': '2026-01-20T08:00:00Z',
      'approvedAt': '2026-01-21T08:00:00Z',
      'startDate': '2026-01-21T00:00:00Z',
      'endDate': '2026-01-28T00:00:00Z',
      'budget': 400.0,
      'impressions': 890,
      'clicks': 32,
      'category': 'Installation',
      'seller': {
        'id': 'seller_004',
        'name': 'Emma Flooring',
        'email': 'emma@flooring.com',
        'phone': '+1234567893',
        'businessName': 'Premium Flooring Co.',
        'shopName': 'Flooring Solutions',
      },
    },
    {
      'id': 'ad_005',
      'title': 'Luxury Wood Cabinets',
      'description':
          'Showcase luxury custom wood cabinets for kitchens and bathrooms',
      'imageUrl': 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1',
      'status': 'pending',
      'createdAt': '2026-01-30T10:00:00Z',
      'budget': 600.0,
      'targetAudience': 'Homeowners, Contractors',
      'category': 'Cabinets',
      'seller': {
        'id': 'seller_005',
        'name': 'David Cabinet',
        'email': 'david@cabinet.com',
        'phone': '+1234567894',
        'businessName': 'Cabinet Masters',
        'shopName': 'Cabinet Showroom',
      },
    },
  ];

  /// Get all ads (DUMMY - will be replaced with API call)
  Future<List<AdminAdModel>> getAds({AdStatus? status}) async {
    log(
      '📢 [ADMIN] Fetching ads (DUMMY DATA) - Status: ${status?.name ?? "all"}',
    );

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    var ads = _dummyAds.map((json) => AdminAdModel.fromJson(json)).toList();

    if (status != null) {
      ads = ads.where((ad) => ad.status == status).toList();
    }

    return ads;
  }

  /// Get ad by ID (DUMMY - will be replaced with API call)
  Future<AdminAdModel?> getAdById(String id) async {
    log('📢 [ADMIN] Fetching ad by ID (DUMMY DATA): $id');

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final adJson = _dummyAds.firstWhere((ad) => ad['id'] == id);
      return AdminAdModel.fromJson(adJson);
    } catch (e) {
      return null;
    }
  }

  /// Approve ad (DUMMY - will be replaced with API call)
  Future<AdminAdModel> approveAd(String id, {String? note}) async {
    log('📢 [ADMIN] Approving ad (DUMMY DATA): $id');

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _dummyAds.indexWhere((ad) => ad['id'] == id);
    if (index != -1) {
      _dummyAds[index]['status'] = 'approved';
      _dummyAds[index]['approvedAt'] = DateTime.now().toIso8601String();
      if (note != null) {
        _dummyAds[index]['approvalNote'] = note;
      }
      return AdminAdModel.fromJson(_dummyAds[index]);
    }

    throw Exception('Ad not found');
  }

  /// Reject ad (DUMMY - will be replaced with API call)
  Future<AdminAdModel> rejectAd(String id, {required String reason}) async {
    log('📢 [ADMIN] Rejecting ad (DUMMY DATA): $id');

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _dummyAds.indexWhere((ad) => ad['id'] == id);
    if (index != -1) {
      _dummyAds[index]['status'] = 'rejected';
      _dummyAds[index]['rejectionReason'] = reason;
      return AdminAdModel.fromJson(_dummyAds[index]);
    }

    throw Exception('Ad not found');
  }

  /// Update ad (DUMMY - will be replaced with API call)
  Future<AdminAdModel> updateAd(String id, Map<String, dynamic> updates) async {
    log('📢 [ADMIN] Updating ad (DUMMY DATA): $id');

    await Future.delayed(const Duration(milliseconds: 600));

    final index = _dummyAds.indexWhere((ad) => ad['id'] == id);
    if (index != -1) {
      _dummyAds[index] = {..._dummyAds[index], ...updates};
      return AdminAdModel.fromJson(_dummyAds[index]);
    }

    throw Exception('Ad not found');
  }

  /// Delete ad (DUMMY - will be replaced with API call)
  Future<bool> deleteAd(String id) async {
    log('📢 [ADMIN] Deleting ad (DUMMY DATA): $id');

    await Future.delayed(const Duration(milliseconds: 400));

    final index = _dummyAds.indexWhere((ad) => ad['id'] == id);
    if (index != -1) {
      _dummyAds.removeAt(index);
      return true;
    }

    return false;
  }

  /// Get ad statistics (DUMMY - will be replaced with API call)
  Future<Map<String, dynamic>> getAdStats() async {
    log('📢 [ADMIN] Fetching ad stats (DUMMY DATA)');

    await Future.delayed(const Duration(milliseconds: 300));

    final ads = _dummyAds.map((json) => AdminAdModel.fromJson(json)).toList();

    return {
      'total': ads.length,
      'pending': ads.where((ad) => ad.status == AdStatus.pending).length,
      'approved': ads.where((ad) => ad.status == AdStatus.approved).length,
      'rejected': ads.where((ad) => ad.status == AdStatus.rejected).length,
      'completed': ads.where((ad) => ad.status == AdStatus.completed).length,
      'totalImpressions': ads.fold<int>(
        0,
        (sum, ad) => sum + (ad.impressions ?? 0),
      ),
      'totalClicks': ads.fold<int>(0, (sum, ad) => sum + (ad.clicks ?? 0)),
      'totalBudget': ads.fold<double>(
        0.0,
        (sum, ad) => sum + (ad.budget ?? 0.0),
      ),
      'totalSellers': ads.map((ad) => ad.sellerId).toSet().length,
    };
  }
}
