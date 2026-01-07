import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_model.dart';
import 'package:wood_service/views/Seller/data/views/order_data/order_provider.dart';

// class SearchBar extends StatelessWidget {
//   const SearchBar();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrdersViewModel>(
//       builder: (context, viewModel, child) {
//         return Container(
//           // margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
//           margin: EdgeInsets.only(left: 20, right: 20),
//           child: CustomTextFormField(
//             hintText: 'Search by name or order #',
//             prefixIcon: Icon(Icons.search_sharp, size: 24),
//           ),
//         );
//       },
//     );
//   }
// }

class StatusFilterBar extends StatelessWidget {
  const StatusFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null, viewModel),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', OrderStatus.delivered, viewModel),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Processing',
                  OrderStatus.processing,
                  viewModel,
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Shipped', OrderStatus.shipped, viewModel),
                const SizedBox(width: 8),
                _buildFilterChip('Cancelled', OrderStatus.cancelled, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    OrderStatus? status,
    OrdersViewModel viewModel,
  ) {
    // Use the correct getter name
    final isSelected = viewModel.selectedStatus == status;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        // Use the correct method name
        onSelected: (selected) {
          viewModel.setStatusFilter(selected ? status : null);
        },
        backgroundColor: Colors.grey[100],
        selectedColor: status?.color ?? const Color(0xFF667EEA),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? (status?.color ?? const Color(0xFF667EEA))
                : Colors.grey[300]!,
            width: isSelected ? 0 : 1,
          ),
        ),
        elevation: isSelected ? 2 : 0,
        shadowColor: (status?.color ?? const Color(0xFF667EEA)).withOpacity(
          0.3,
        ),
      ),
    );
  }
}
