import 'package:flutter/material.dart';

// lib/presentation/widgets/custom_app_bar.dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  final bool showNotification;
  final int? notificationCount;
  final Color backgroundColor;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.showSearch = false,
    this.onSearchChanged,
    this.showNotification = false,
    this.notificationCount,
    this.backgroundColor = Colors.white,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: Colors.black,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: showBackButton ? _buildBackButton(context) : null,
      actions: [
        if (showSearch) _buildSearchButton(),
        if (showNotification) _buildNotificationButton(),
        ...?_buildActionButtons(),
        const SizedBox(width: 8),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
        splashRadius: 20,
      ),
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Icon(Icons.search_rounded, size: 20),
      ),
      onPressed: () {
        // Show search overlay or navigate to search screen
        // _showSearch(context);
      },
      tooltip: 'Search',
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Icon(Icons.notifications_outlined, size: 20),
          ),
          onPressed: () {
            // Handle notification press
          },
          tooltip: 'Notifications',
        ),
        if (notificationCount != null && notificationCount! > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                notificationCount! > 9 ? '9+' : notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget>? _buildActionButtons() {
    if (actions == null) return null;

    return actions!.map((action) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: action,
      );
    }).toList();
  }

  // void _showSearch(BuildContext context) {
  //   // You can implement search functionality here
  //   if (onSearchChanged != null) {
  //     showSearch(
  //       context: context,
  //       delegate: _CustomSearchDelegate(onSearchChanged: onSearchChanged!),
  //     );
  //   }
  // }
}

class _CustomSearchDelegate extends SearchDelegate {
  final ValueChanged<String> onSearchChanged;

  _CustomSearchDelegate({required this.onSearchChanged});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchContent();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchContent();
  }

  Widget _buildSearchContent() {
    onSearchChanged(query);
    return const Center(child: Text('Start typing to search...'));
  }
}
// class AdvancedAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool showBackButton;
//   final List<Widget>? actions;
//   final VoidCallback? onBackPressed;
//   final bool showSearch;
//   final ValueChanged<String>? onSearchChanged;
//   final bool showFilter;
//   final VoidCallback? onFilterPressed;
//   final Color backgroundColor;
//   final bool centerTitle;
//   final double elevation;

//   const AdvancedAppBar({
//     super.key,
//     required this.title,
//     this.showBackButton = true,
//     this.actions,
//     this.onBackPressed,
//     this.showSearch = false,
//     this.onSearchChanged,
//     this.showFilter = false,
//     this.onFilterPressed,
//     this.backgroundColor = Colors.white,
//     this.centerTitle = true,
//     this.elevation = 0,
//   });

//   @override
//   Size get preferredSize =>
//       const Size.fromHeight(kToolbarHeight + (kToolbarHeight * 0.5));

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: !showSearch
//           ? Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             )
//           : _buildSearchField(),
//       backgroundColor: backgroundColor,
//       foregroundColor: Colors.black,
//       centerTitle: centerTitle,
//       automaticallyImplyLeading: false,
//       elevation: elevation,
//       leading: showBackButton ? _buildBackButton(context) : null,
//       actions: [
//         if (showFilter) _buildFilterButton(),
//         if (showSearch) _buildSearchButton(context),
//         ...?actions,
//         const SizedBox(width: 8),
//       ],
//       bottom: showSearch ? _buildSearchBottom() : null,
//     );
//   }

//   Widget _buildBackButton(BuildContext context) {
//     return IconButton(
//       icon: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           shape: BoxShape.circle,
//         ),
//         child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
//       ),
//       onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
//       tooltip: 'Back',
//     );
//   }

//   Widget _buildSearchButton(BuildContext context) {
//     return IconButton(
//       icon: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           shape: BoxShape.circle,
//         ),
//         child: const Icon(Icons.search, size: 20),
//       ),
//       onPressed: () {
//         // Toggle search mode
//         // _showSearchDialog(context);
//       },
//       tooltip: 'Search',
//     );
//   }

//   Widget _buildFilterButton() {
//     return IconButton(
//       icon: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           shape: BoxShape.circle,
//         ),
//         child: const Icon(Icons.filter_list_rounded, size: 20),
//       ),
//       onPressed: onFilterPressed,
//       tooltip: 'Filter',
//     );
//   }

//   Widget _buildSearchField() {
//     return Container(
//       height: 40,
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: TextField(
//         onChanged: onSearchChanged,
//         decoration: InputDecoration(
//           hintText: 'Search...',
//           hintStyle: const TextStyle(color: Colors.grey),
//           prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(vertical: 8),
//         ),
//         style: const TextStyle(fontSize: 16),
//       ),
//     );
//   }

//   PreferredSizeWidget? _buildSearchBottom() {
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(1),
//       child: Container(color: Colors.grey[200], height: 1),
//     );
//   }

//   // void _showSearchDialog(BuildContext context) {
//   //   showSearch(
//   //     context: context,
//   //     delegate: CustomSearchDelegate(onSearchChanged: onSearchChanged),
//   //   );
//   // }
// }

// class CustomSearchDelegate extends SearchDelegate {
//   final ValueChanged<String>? onSearchChanged;

//   CustomSearchDelegate({this.onSearchChanged});

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return _buildSearchResults();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return _buildSearchResults();
//   }

//   Widget _buildSearchResults() {
//     return ListView.builder(
//       itemCount: 0,
//       itemBuilder: (context, index) => ListTile(
//         title: Text('Result $index'),
//         onTap: () {
//           close(context, 'Result $index');
//         },
//       ),
//     );
//   }
// }
