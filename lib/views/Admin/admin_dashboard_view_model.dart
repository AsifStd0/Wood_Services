// view_models/admin_dashboard_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:wood_service/views/Admin/admin_model.dart';
import 'package:wood_service/views/Admin/admin_repository.dart';

class AdminDashboardViewModel with ChangeNotifier {
  final AdminRepository _adminRepository;

  AdminDashboardViewModel(this._adminRepository);

  // State variables
  AdminStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentTab = 0;

  // Getters
  AdminStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentTab => _currentTab;

  // Methods
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _adminRepository.getDashboardStats();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentTab(int tabIndex) {
    _currentTab = tabIndex;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
