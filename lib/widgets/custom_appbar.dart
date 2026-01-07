import 'package:flutter/material.dart';

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 5); // Decrease by 5 pixels

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
    return Row(
      children: [
        // Dropdown area
        Row(
          children: const [
            Text(
              "All",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),

        // Search field
        Expanded(
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Ensure row items are centered
              children: [
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.0,
                    ), // Control text height
                    decoration: const InputDecoration(
                      hintText: "Search products...",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                      fillColor: Colors.white,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: 12,
                        right: 8,
                        bottom: 5,
                      ), // Adjust bottom padding
                      isDense: true,
                    ),
                  ),
                ),

                // Search icon - centered vertically
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  alignment: Alignment.center, // Center the icon
                  child: const Icon(Icons.search, color: Colors.grey, size: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    // Circular back button with subtle shadow and ripple effect
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onBackPressed ?? () => Navigator.of(context).pop(),
          customBorder: const CircleBorder(),
          splashColor: Colors.black12,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white, // background of the circle
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.arrow_back, size: 20, color: Colors.black87),
          ),
        ),
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
