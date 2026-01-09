import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/views/seller_home/view_request_provider.dart';

Widget buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today_rounded, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(
          'No Visit Requests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Visit requests from buyers will appear here',
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading Visit Requests',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while we fetch your requests',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    ),
  );
}

Widget buildErrorState(VisitRequestsViewModel viewModel) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Something Went Wrong',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: viewModel.loadVisitRequests,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: Color(0xFF667EEA).withOpacity(0.3),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 22),
            label: const Text(
              'Try Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildFilterTab(
  String title,
  VisitFilter filter,
  VisitRequestsViewModel viewModel,
) {
  final isSelected = viewModel.currentFilter == filter;

  return Expanded(
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.primaryGradient : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: () => viewModel.setFilter(filter),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}
