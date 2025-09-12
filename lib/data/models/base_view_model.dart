import 'package:flutter/material.dart';
import 'package:wood_service/core/utils/enums.dart';

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  bool _isSuccess = false;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  void setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isSuccess = false;
    notifyListeners();
  }

  void setSuccess(bool value) {
    _isSuccess = value;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
