import 'package:flutter/foundation.dart';
import 'package:wood_service/core/error/failure.dart';
import 'package:wood_service/data/models/user_model.dart';
import 'package:wood_service/data/repositories/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;

  AuthProvider({required this.authService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _user;
  UserModel? get user => _user;

  Failure? _error;
  Failure? get error => _error;
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await authService.login(email: email, password: password);

    result.fold(
      (failure) {
        _error = failure;
        _user = null;
      },
      (user) {
        _user = user;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
