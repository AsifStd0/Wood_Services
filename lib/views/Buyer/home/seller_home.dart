// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:wood_service/core/theme/app_test_style.dart';
// import 'package:wood_service/views/Buyer/buyer_main.dart';
// import 'package:wood_service/views/Buyer/home/asif/furniture_product.dart';
// import 'package:wood_service/views/Buyer/home/asif/model/home_screen.dart';
// import 'package:wood_service/widgets/custom_textfield.dart';

// class FurnitureHomeScreen extends StatefulWidget {
//   const FurnitureHomeScreen({super.key});

//   @override
//   State<FurnitureHomeScreen> createState() => _FurnitureHomeScreenState();
// }

// class _FurnitureHomeScreenState extends State<FurnitureHomeScreen> {
//   String selectedCategory = 'All';
//   String searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               _buildHeader(),

//               // Search Bar
//               _buildSearchBar(),

//               // Categories
//               _buildCategorySection(),

//               // Product Types
//               _buildProductTypes(),

//               // Products Grid
//               Expanded(child: _buildProductsGrid()),
//             ],
//           ),
//         ),
//       ),

//       // Bottom Filter Bar
//       // bottomNavigationBar: _buildBottomFilterBar(),
//     );
//   }

//   // Customization Point 1: Header
//   Widget _buildHeader() {
//     return Row(
//       children: [
//         Icon(Icons.menu, size: 28),

//         Spacer(),
//         CircleAvatar(
//           backgroundColor: Colors.brown,
//           child: Icon(Icons.person, color: Colors.white),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0),
//       child: CustomTextFormField(
//         suffixIcon: Icon(Icons.search, size: 25),
//         hintText: 'Search',
//         onChanged: (value) {
//           setState(() {
//             searchQuery = value;
//           });
//         },
//       ),
//     );
//   }

//   // Customization Point 3: Categories
//   Widget _buildCategorySection() {
//     return SizedBox(
//       height: 55,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: ChoiceChip(
//               label: CustomText(
//                 categories[index],
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//               // Text(categories[index]),
//               selected: selectedCategory == categories[index],
//               onSelected: (selected) {
//                 setState(() {
//                   selectedCategory = categories[index];
//                 });
//               },
//               selectedColor: Color(0xffE7B961),

//               //  Colors(0xffE7B961),
//               labelStyle: TextStyle(
//                 color: selectedCategory == categories[index]
//                     ? Colors.white
//                     : Colors.black,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Customization Point 4: Product Types
//   Widget _buildProductTypes() {
//     return SizedBox(
//       height: 40,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: productTypes.length,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemBuilder: (context, index) {
//           return Container(
//             margin: const EdgeInsets.only(right: 8),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: Text(
//               productTypes[index],
//               style: const TextStyle(fontSize: 12),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Customization Point 5: Products Grid
//   Widget _buildProductsGrid() {
//     List<FurnitureProduct> filteredProducts = products.where((product) {
//       final matchesCategory = selectedCategory == 'All';
//       return matchesCategory;
//     }).toList();

//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 16,
//         childAspectRatio: 0.59,
//       ),
//       itemCount: filteredProducts.length,
//       itemBuilder: (context, index) {
//         return _buildProductCard(filteredProducts[index]);
//       },
//     );
//   }

//   // Customization Point 6: Product Card
//   Widget _buildProductCard(FurnitureProduct product) {
//     return Padding(
//       padding: EdgeInsets.only(top: 10),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product Image with New Badge
//             Stack(
//               children: [
//                 Container(
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16),
//                     ),
//                   ),
//                   child: Center(
//                     child: Image.asset('assets/images/sofa.jpg'),
//                     // Icon(Icons.chair, size: 60, color: Colors.grey[400]),
//                   ),
//                 ),
//                 if (product.isNew)
//                   Positioned(
//                     top: 8,
//                     left: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text(
//                         'NEW',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),

//             // Product Details
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '\$${product.price.toInt()}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.brown,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // FIX: Corrected route path from 'procutDetail' to 'productDetail'
//                         // context.push('/productDetail', extra: product.id);
//                         Navigator.of(context).push(
//                           MaterialPageRoute(builder: (context) => HomeScreen()),
//                         );
// context.push('/productDetail/${product.id}');

//                         print('Navigating to product detail-----');
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.brown,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Buy Now',
//                         style: TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
