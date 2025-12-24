// lib/providers/buyer_profile_viewmodel.dart
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/views/Buyer/Service/profile_service.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup_model.dart';

class BuyerProfileViewProvider extends ChangeNotifier {
  final BuyerProfileService _profileService;

  // Profile data from BuyerModel
  BuyerModel? _currentBuyer;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  String? _successMessage;

  // For image updates
  File? _newProfileImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Getters
  BuyerModel? get currentBuyer => _currentBuyer;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  File? get newProfileImage => _newProfileImage;
  // Convenience getters
  String get fullName => _currentBuyer?.fullName ?? '';
  String get email => _currentBuyer?.email ?? '';
  String get contactName => _currentBuyer?.contactName ?? '';
  String get businessName => _currentBuyer?.businessName ?? '';
  String get address => _currentBuyer?.address ?? '';
  String get description => _currentBuyer?.description ?? '';
  String get bankName => _currentBuyer?.bankName ?? '';
  String get iban => _currentBuyer?.iban ?? '';
  String? get profileImagePath => _currentBuyer?.profileImagePath;
  bool get hasData => _currentBuyer != null;
  bool get isLoggedIn => hasData;

  // Constructor
  BuyerProfileViewProvider({BuyerProfileService? profileService})
    : _profileService = profileService ?? locator<BuyerProfileService>() {
    log('🔄 BuyerProfileViewModel initialized');
    loadProfile();
  }

  // Load profile data
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final buyer = await _profileService.getCurrentBuyer();

      if (buyer != null) {
        _currentBuyer = buyer;
        log('✅ Profile loaded: ${buyer.fullName} ${buyer.iban}');
      } else {
        log('⚠️ No profile found');
      }
    } catch (e) {
      log('❌ Error loading profile: $e');
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh from API
  Future<void> refreshProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final buyer = await _profileService.fetchProfileFromApi();

      if (buyer != null) {
        _currentBuyer = buyer;
        _successMessage = 'Profile refreshed successfully';
        log('✅ Profile refreshed: ${buyer.fullName}');
      } else {
        _errorMessage = 'Failed to refresh profile';
      }
    } catch (e) {
      log('❌ Error refreshing profile: $e');
      _errorMessage = 'Failed to refresh profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add this method to set new profile image
  void setNewProfileImage(File image) {
    _newProfileImage = image;
    notifyListeners();
    log('📸 Profile image set for update');
  }

  // Update profile with text data
  Future<bool> updateProfileData({
    String? fullName,
    String? email,
    String? contactName,
    String? businessName,
    String? address,
    String? description,
    String? bankName,
    String? iban,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      print('🔄 Starting profile update...');
      print(
        '📝 Updates: fullName=$fullName, businessName=$businessName, bankName=$bankName, iban=$iban',
      );

      final updates = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) {
        updates['fullName'] = fullName;
        print('✅ Adding fullName: $fullName');
      }
      if (email != null && email.isNotEmpty) {
        updates['email'] = email;
        print('✅ Adding email: $email');
      }
      if (contactName != null) {
        updates['contactName'] = contactName;
        print('✅ Adding contactName: $contactName');
      }
      if (businessName != null) {
        updates['businessName'] = businessName;
        print('✅ Adding businessName: $businessName');
      }
      if (address != null) {
        updates['address'] = address;
        print('✅ Adding address: $address');
      }
      if (description != null) {
        updates['description'] = description;
        print('✅ Adding description: $description');
      }
      if (bankName != null) {
        updates['bankName'] = bankName;
        print('✅ Adding bankName: $bankName');
      }
      if (iban != null) {
        updates['iban'] = iban;
        print('✅ Adding iban: $iban');
      }

      print('📤 Sending updates to service: $updates');

      final result = await _profileService.updateProfileBuyer(
        updates: updates,
        profileImage: _newProfileImage,
      );

      print('📥 Received result: ${result['success']}');
      print('📥 Message: ${result['message']}');
      print('📥 Buyer data: ${result['buyer']}');

      if (result['success'] == true) {
        _currentBuyer = result['buyer'];
        _successMessage = result['message'];
        _isEditing = false;
        _newProfileImage = null;

        print('✅ Profile updated successfully: ${_currentBuyer?.fullName}');
        print('✅ New businessName: ${_currentBuyer?.businessName}');
        print('✅ New bankName: ${_currentBuyer?.bankName}');
        print('✅ New iban: ${_currentBuyer?.iban}');

        // Force notify all listeners
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        print('❌ Update failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      _errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      _isLoading = false;
      // Make sure to notify listeners
      notifyListeners();
      print('🏁 Update process completed');
    }
  }

  // Pick new profile image
  Future<void> pickProfileImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        _newProfileImage = File(image.path);
        log('📸 New profile image selected: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking image: $e';
      log('❌ Error picking profile image: $e');
      notifyListeners();
    }
  }

  // Clear new profile image
  void clearNewProfileImage() {
    _newProfileImage = null;
    notifyListeners();
  }

  // Logout
  Future<bool> logout(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _profileService.logout();

      _currentBuyer = null;
      _successMessage = 'Logged out successfully';

      // Navigate to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      });

      log('✅ Logout completed');
      return true;
    } catch (e) {
      log('❌ Error during logout: $e');
      _errorMessage = 'Logout failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set editing mode
  void setEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Update individual fields
  void updateField(String field, String value) {
    if (_currentBuyer != null) {
      // Create a temporary updated buyer
      final updatedBuyer = BuyerModel(
        id: _currentBuyer!.id,
        fullName: field == 'fullName' ? value : _currentBuyer!.fullName,
        email: field == 'email' ? value : _currentBuyer!.email,
        password: _currentBuyer!.password,
        contactName: field == 'contactName'
            ? value
            : _currentBuyer!.contactName,
        businessName: field == 'businessName'
            ? value
            : _currentBuyer!.businessName,
        address: field == 'address' ? value : _currentBuyer!.address,
        description: field == 'description'
            ? value
            : _currentBuyer!.description,
        bankName: field == 'bankName' ? value : _currentBuyer!.bankName,
        iban: field == 'iban' ? value : _currentBuyer!.iban,
        profileImagePath: _currentBuyer!.profileImagePath,
        profileCompleted: true,
        isActive: true,
      );

      _currentBuyer = updatedBuyer;
      notifyListeners();
    }
  }
}
