import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';

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
  final bool automaticallyImplyLeading;

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
    this.automaticallyImplyLeading = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0.5,
      centerTitle: centerTitle,
      leading: showBackButton ? _buildBackButton(context) : null,
      title: showSearch ? _buildSearchBar(context) : _buildTitle(),
      actions: [
        if (showNotification) _buildNotificationButton(),
        ...?_buildActionButtons(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),

      child: Row(
        children: [
          // Dropdown area ("All ▼")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                Text(
                  "All",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),

          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(fontSize: 17),
                border: InputBorder.none,
                fillColor: Colors.white10,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),

          // Search icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.search, color: Colors.black54, size: 22),
          ),
        ],
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

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 24),
          onPressed: () {},
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
    return actions!
        .map(
          (action) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: action,
          ),
        )
        .toList();
  }
}

// // lib/presentation/widgets/custom_app_bar.dart
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool showBackButton;
//   final List<Widget>? actions;
//   final VoidCallback? onBackPressed;
//   final bool showSearch;
//   final ValueChanged<String>? onSearchChanged;
//   final bool showNotification;
//   final int? notificationCount;
//   final Color backgroundColor;
//   final bool centerTitle;
//   final bool automaticallyImplyLeading;

//   const CustomAppBar({
//     super.key,
//     required this.title,
//     this.showBackButton = true,
//     this.actions,
//     this.onBackPressed,
//     this.showSearch = false,
//     this.onSearchChanged,
//     this.showNotification = false,
//     this.notificationCount,
//     this.backgroundColor = Colors.white,
//     this.centerTitle = true,
//     this.automaticallyImplyLeading = false,
//   });

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w700,
//           color: Colors.black87,
//           letterSpacing: -0.5,
//         ),
//       ),
//       backgroundColor: backgroundColor,
//       foregroundColor: Colors.black,
//       centerTitle: centerTitle,
//       automaticallyImplyLeading: automaticallyImplyLeading,
//       elevation: 0.5,
//       shadowColor: Colors.black.withOpacity(0.1),
//       leading: showBackButton ? _buildBackButton(context) : null,
//       actions: [
//         if (showSearch) _buildSearchButton(),
//         if (showNotification) _buildNotificationButton(),
//         ...?_buildActionButtons(),
//         const SizedBox(width: 8),
//       ],
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
//       ),
//     );
//   }

//   Widget _buildBackButton(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 8),
//       child: IconButton(
//         icon: Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: Colors.grey[50],
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey[200]!),
//           ),
//           child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
//         ),
//         onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
//         tooltip: 'Back',
//         splashRadius: 20,
//       ),
//     );
//   }

//   Widget _buildSearchButton() {
//     return IconButton(
//       icon: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: const Icon(Icons.search_rounded, size: 20),
//       ),
//       onPressed: () {
//         // Show search overlay or navigate to search screen
//         // _showSearch(context);
//       },
//       tooltip: 'Search',
//     );
//   }

//   Widget _buildNotificationButton() {
//     return Stack(
//       children: [
//         IconButton(
//           icon: Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             child: const Icon(Icons.notifications_outlined, size: 20),
//           ),
//           onPressed: () {
//             // Handle notification press
//           },
//           tooltip: 'Notifications',
//         ),
//         if (notificationCount != null && notificationCount! > 0)
//           Positioned(
//             right: 8,
//             top: 8,
//             child: Container(
//               padding: const EdgeInsets.all(2),
//               decoration: const BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
//               child: Text(
//                 notificationCount! > 9 ? '9+' : notificationCount.toString(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   List<Widget>? _buildActionButtons() {
//     if (actions == null) return null;

//     return actions!.map((action) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         child: action,
//       );
//     }).toList();
//   }
// }
