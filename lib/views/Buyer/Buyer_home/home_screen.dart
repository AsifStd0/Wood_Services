// views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/furniture_product_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_widget.dart';
import 'package:wood_service/widgets/custom_appbar.dart';

class BuyerHomeScreen extends StatefulWidget {
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
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          title: 'Search',
          showBackButton: false,
          showSearch: true,
          actions: [Icon(Icons.notifications)],
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

            const SizedBox(height: 3),

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

  Widget _buildProductsGrid() {
    List<FurnitureProduct> filteredProducts = furnitureproducts.where((
      product,
    ) {
      final matchesCategory = selectedCategory == 'All';
      return matchesCategory;
    }).toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Changed to 2 for better layout
        crossAxisSpacing: 5,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70, // Adjusted for new content
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredProducts[index], context);
      },
    );
  }

  Widget _buildProductCard(FurnitureProduct product, BuildContext context) {
    final bool hasDiscount =
        product.originalPrice != null && product.originalPrice! > product.price;
    final double? discount = hasDiscount
        ? ((product.originalPrice! - product.price) /
                  product.originalPrice! *
                  100)
              .roundToDouble()
        : null;
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
          // Product Image with Discount Badge and Share Icon
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 90,
                  color: Colors.grey[200],
                  child: Center(
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),

              // Discount Badge - Only show if product has discount
              if (hasDiscount && discount != null && discount > 0)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${discount.toInt()}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 5, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        product.brand,
                        type: CustomTextType.captionMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.star, size: 14, color: Colors.amber[600]),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Product Name
                CustomText(
                  product.name,
                  type: CustomTextType.captionLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Product Name
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Price Section
                Row(
                  children: [
                    // Current Price
                    Text(
                      '\$${product.price.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 2),

                    // Original Price (Crossed) - Only show if has discount
                    if (hasDiscount)
                      Text(
                        '\$${product.originalPrice!.toInt()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),

                    const Spacer(),

                    // Delivery Info - Only show if free delivery
                    if (product.freeDelivery)
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Free Delivery',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Order Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () {
                      // Add to cart or order functionality
                      context.push('/productDetail/${product.id}');
                    },
                    child: const CustomText(
                      'Order',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    type: ButtonType.textButton,
                    backgroundColor: AppColors.yellowButton,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                padding: const EdgeInsets.symmetric(vertical: 4),
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
              buildCityFilter(viewModel),
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
}
