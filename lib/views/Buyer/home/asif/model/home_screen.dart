// views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/home/asif/model/home_widget.dart';
import 'package:wood_service/widgets/advance_appbar.dart';

class SellerHomeScreen extends StatefulWidget {
  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
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
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: CustomAppBar(title: 'title'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // Wrap with SingleChildScrollView
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  _buildCategoriesSection(),

                  const SizedBox(height: 5),
                  // NEW Section
                  buildNewSection(),

                  const SizedBox(height: 5),
                  _buildFilterSection(),
                  const SizedBox(height: 5),

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

  Widget _buildCategoriesSection() {
    return Consumer<HomeViewModel>(
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

            const SizedBox(height: 16),

            // Image Slider with Auto-slide
            _buildImageSlider(),
          ],
        );
      },
    );
  }

  Widget _buildImageSlider() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          height: 220,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/sofa.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Indicators positioned at bottom center
                    Positioned(
                      bottom: 16,
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

  Widget _buildProductsGrid() {
    List<FurnitureProduct> filteredProducts = products.where((product) {
      final matchesCategory = selectedCategory == 'All';
      return matchesCategory;
    }).toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Disable GridView scroll
      shrinkWrap: true, // Important for SingleChildScrollView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.50,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredProducts[index], context);
      },
    );
  }

  Widget _buildProductCard(FurnitureProduct product, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with New Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: Container(
                  height: 110,
                  color: Colors.grey[200],
                  child: Center(
                    child: Image.asset(
                      'assets/images/sofa.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity, // Make image fill container
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '\$${product.price.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () {},
                    child: CustomText(
                      'Buy Now',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    type: ButtonType.textButton,
                    backgroundColor: AppColors.yellowButton,

                    height: 30,
                    padding: EdgeInsets.only(left: 5, right: 5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  viewModel.filter.length,
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
            _buildMoreFilterSection(),
          ],
        );
      },
    );
  }

  Widget _buildMoreFilterSection() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // More Filter Header
            GestureDetector(
              onTap: () => viewModel.toggleMoreFilters(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      "More Filter",
                      type: CustomTextType.bodyMediumBold,
                    ),
                    Icon(
                      viewModel.showMoreFilters
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Filter Options
            if (viewModel.showMoreFilters) ...[
              _buildCityFilter(viewModel),
              const SizedBox(height: 16),
              buildPriceFilter(viewModel),
              const SizedBox(height: 16),
              buildDeliveryFilter(viewModel),
              const SizedBox(height: 16),
              buildSalesFilter(viewModel),
              const SizedBox(height: 16),
              buildProviderFilter(viewModel),
              const SizedBox(height: 16),
              buildColorFilter(viewModel),
              const SizedBox(height: 20),
              // Filter Actions
              buildFilterActions(viewModel),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCityFilter(HomeViewModel viewModel) {
    final cities = [
      'New York',
      'Los Angeles',
      'Chicago',
      'Miami',
      'Dallas',
      'All Cities',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText('City', type: CustomTextType.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cities.map((city) {
            final isSelected = viewModel.selectedCity == city;
            return FilterChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (selected) {
                viewModel.setCity(selected ? city : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
