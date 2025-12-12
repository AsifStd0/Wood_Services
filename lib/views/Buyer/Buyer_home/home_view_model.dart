import 'package:flutter/material.dart';
import 'package:wood_service/views/Buyer/Buyer_home/furniture_product_model.dart';

class BuyerHomeViewModel with ChangeNotifier {
  int _currentSliderIndex = 0;
  String? _selectedOption;

  List<Category> _categories = [
    Category(name: "Living Room", isSelected: false),
    Category(name: "Dining Room", isSelected: false),
    Category(name: "Bedroom", isSelected: false),
    Category(name: "Entryway", isSelected: false),
  ];

  List<Category> _filter = [
    Category(name: "Sofa", isSelected: false),
    Category(name: "Tv Table", isSelected: false),
    Category(name: "Lights", isSelected: false),
    Category(name: "Bed", isSelected: false),
  ];

  final List<String> _allOptions = [
    "Indoor",
    "Outdoor",
    "Ready Product",
    "Customize Product",
  ];

  // Getters
  int get currentSliderIndex => _currentSliderIndex;
  List<Category> get categories => _categories;
  List<Category> get filter => _filter;
  List<String> get allOptions => _allOptions;
  String? get selectedOption => _selectedOption;

  bool isSelected(String option) => _selectedOption == option;

  void updateSliderIndex(int index) {
    _currentSliderIndex = index;
    notifyListeners();
  }

  void selectCategory(int index) {
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(isSelected: false);
    }
    _categories[index] = _categories[index].copyWith(isSelected: true);
    notifyListeners();
  }

  void selectFilter(int index) {
    for (int i = 0; i < _filter.length; i++) {
      _filter[i] = _filter[i].copyWith(isSelected: false);
    }
    _filter[index] = _filter[index].copyWith(isSelected: true);
    notifyListeners();
  }

  void selectOption(String option) {
    _selectedOption = option;
    notifyListeners();
  }

  // ! ******

  // More Filter states
  bool _showMoreFilters = false;
  String? _selectedCity;
  double _minPrice = 0;
  double _maxPrice = 10000;
  bool _freeDelivery = false;
  bool _onSale = false;
  String? _selectedProvider;
  String? _selectedColor;

  // Getters for more filters
  bool get showMoreFilters => _showMoreFilters;
  String? get selectedCity => _selectedCity;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get freeDelivery => _freeDelivery;
  bool get onSale => _onSale;
  String? get selectedProvider => _selectedProvider;
  String? get selectedColor => _selectedColor;

  // Methods for more filters
  void toggleMoreFilters() {
    _showMoreFilters = !_showMoreFilters;
    notifyListeners();
  }

  void setCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setFreeDelivery(bool value) {
    _freeDelivery = value;
    notifyListeners();
  }

  void setOnSale(bool value) {
    _onSale = value;
    notifyListeners();
  }

  void setProvider(String? provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  void setColor(String? color) {
    _selectedColor = color;
    notifyListeners();
  }

  void resetAllFilters() {
    _selectedCity = null;
    _minPrice = 0;
    _maxPrice = 10000;
    _freeDelivery = false;
    _onSale = false;
    _selectedProvider = null;
    _selectedColor = null;
    notifyListeners();
  }
}
