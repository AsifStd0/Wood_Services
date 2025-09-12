import 'package:wood_service/data/repositories/auth_service.dart';

import '../../../app/index.dart';
import 'package:flutter/material.dart';

class RegisterProvider with ChangeNotifier {
  final AuthService _authService;
  final ImageUploadService _imageUploadService;

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  File? profileImage;
  bool termsAccepted = false;
  bool isLoading = false;

  RegisterProvider({
    required AuthService authService,
    required ImageUploadService imageUploadService,
  }) : _authService = authService,
       _imageUploadService = imageUploadService;

  void updateName(String value) {
    name = value.trim();
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value.trim();
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    confirmPassword = value;
    notifyListeners();
  }

  void setProfileImage(File? image) {
    profileImage = image;
    notifyListeners();
  }

  void toggleTerms(bool? value) {
    termsAccepted = value ?? false;
    notifyListeners();
  }

  bool get isFormValid {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        profileImage != null &&
        termsAccepted &&
        password == confirmPassword;
  }

  Future<Map<String, dynamic>> register() async {
    if (!isFormValid) {
      return {'success': false, 'message': 'Please fill all fields correctly'};
    }

    isLoading = true;
    notifyListeners();

    try {
      // 1. Upload image and handle the Either result
      final uploadResult = await _imageUploadService.uploadImage(
        profileImage!,
        'profile_images',
      );

      // 2. Handle the upload result
      return uploadResult.fold(
        // If upload failed
        (uploadFailure) => {
          'success': false,
          'message': 'Image upload failed: ${uploadFailure.message}',
        },

        // If upload succeeded, proceed with registration
        (imageUrl) async {
          final result = await _authService.register(
            email: email,
            password: password,
            name: name,
            image: imageUrl, // Now this is a String!
          );
          return result.fold(
            (registerFailure) => {
              'success': false,
              'message': registerFailure.message,
            },
            (user) => {'success': true, 'user': user},
          );
        },
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setProfileImage(File(image.path)); // <-- directly update
    }
  }

  // ! when calling by api
  // Future<void> pickImage(BuildContext context, ImageSource source) async {
  //   final picker = ImagePicker();
  //   final image = await picker.pickImage(source: source, imageQuality: 80);
  //   if (image != null) {
  //     context.read<RegisterProvider>().setProfileImage(File(image.path));
  //   }
  // }
  void showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickImage(context, ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickImage(context, ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }
}
