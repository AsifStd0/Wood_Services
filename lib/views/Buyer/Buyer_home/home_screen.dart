import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_widget.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});
  @override
  State<BuyerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<BuyerHomeScreen> {
  String selectedCategory = 'All';
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < 3) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Search',
        showBackButton: false,
        showSearch: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const NotificationsScreen(),
              //   ),
              // );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  _buildCategoriesSection(),

                  // NEW Section
                  buildNewSection(),

                  const SizedBox(height: 3),
                  _buildFilterSection(),

                  // Products Grid
                  _buildProductsGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ! Products Actuall Dta
  // // ! Products Actual Data
  Widget _buildProductsGrid() {
    return Consumer<BuyerHomeViewProvider>(
      builder: (context, viewModel, child) {
        // Load products on first build
        if (viewModel.products.isEmpty &&
            !viewModel.isLoading &&
            !viewModel.hasError) {
          Future.microtask(() => viewModel.loadProducts());
        }

        // Show loading state
        if (viewModel.isLoading && viewModel.products.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // Show error state
        if (viewModel.hasError && viewModel.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text('Failed to load products'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => viewModel.refreshProducts(),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Use BuyerProductModel DIRECTLY - NO CONVERSION
        List<BuyerProductModel> filteredProducts = viewModel.products.where((
          product,
        ) {
          final matchesCategory = selectedCategory == 'All';
          return matchesCategory;
        }).toList();

        // Show empty state
        if (filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_outlined, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text('No products available'),
              ],
            ),
          );
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 5),

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5, // ✅ Increased spacing
            mainAxisSpacing: 5, // ✅ Increased spacing
            childAspectRatio: 0.72, // ✅ Adjusted for better proportions
            // mainAxisExtent: 320, // ✅ Fixed height for all cards
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return buildProductCard(
              filteredProducts[index], // Pass BuyerProductModel directly
              context,
            );
          },
        );
      },
    );
  }

  // ! *******
  // ! *******
  Widget _buildFilterSection() {
    return Consumer<BuyerHomeViewProvider>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  viewModel
                      .filter
                      .length, // ✅ FIX: Changed from filteredProducts to filter
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index == viewModel.filter.length - 1 ? 0 : 12,
                    ),
                    child: buildCategoryChip(
                      viewModel.filter[index].name,
                      isSelected: viewModel.filter[index].isSelected,
                      onTap: () => viewModel.selectFilter(index),
                    ),
                  ),
                ),
              ),
            ),
            // CustomText("Products"),
          ],
        );
      },
    );
  }

  Widget _buildImageSlider() {
    return Consumer<BuyerHomeViewProvider>(
      builder: (context, viewModel, child) {
        return SizedBox(
          height: 140,

          child: PageView.builder(
            controller: _pageController,
            itemCount: 4,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              viewModel.updateSliderIndex(index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/sofa.jpg'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: Stack(
                  children: [
                    // Indicators positioned at bottom center
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: _buildSliderIndicators(
                        _currentPage,
                        4, // Changed to 4 since we have 4 items
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSliderIndicators(int currentIndex, int totalItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalItems, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            border: index == currentIndex
                ? null
                : Border.all(color: Colors.white, width: 1),
          ),
        );
      }),
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<BuyerHomeViewProvider>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  viewModel.categories.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index == viewModel.categories.length - 1 ? 0 : 12,
                    ),
                    child: buildCategoryChip(
                      viewModel.categories[index].name,
                      isSelected: viewModel.categories[index].isSelected,
                      onTap: () => viewModel.selectCategory(index),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 3),

            // Image Slider with Auto-slide
            _buildImageSlider(),
          ],
        );
      },
    );
  }
}
