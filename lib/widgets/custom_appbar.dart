import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  /// Optional. When set, the search [TextField] is controlled so it doesn't reset on rebuild.
  final TextEditingController? searchController;
  final bool showNotification;
  final int? notificationCount;

  /// When null, uses [Theme.appBarTheme.backgroundColor] or [ColorScheme.surface].
  final Color? backgroundColor;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double? fontSize;
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.showSearch = false,
    this.onSearchChanged,
    this.searchController,
    this.showNotification = false,
    this.notificationCount,
    this.backgroundColor,
    this.centerTitle = true,
    this.automaticallyImplyLeading = false,
    this.fontSize,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 5); // Decrease by 5 pixels

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarBg =
        backgroundColor ??
        theme.appBarTheme.backgroundColor ??
        colorScheme.surface;
    return AppBar(
      backgroundColor: appBarBg,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0.5,
      centerTitle: centerTitle,
      leading: showBackButton ? _buildBackButton(context) : null,
      title: showSearch ? _buildSearchBar(context) : _buildTitle(context),
      actions: [
        if (showNotification) _buildNotificationButton(),
        ...?_buildActionButtons(),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.appBarTheme.titleTextStyle?.color ?? theme.colorScheme.onSurface;
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize ?? 18,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final borderColor = colorScheme.outline.withOpacity(0.5);
    final hintColor = colorScheme.onSurface.withOpacity(0.5);
    return Row(
      children: [
        // // Dropdown area
        // Row(
        //   children: [
        //     Text(
        //       "All",
        //       style: TextStyle(
        //         fontWeight: FontWeight.w600,
        //         fontSize: 14,
        //         color: colorScheme.onSurface,
        //       ),
        //     ),
        //     const SizedBox(width: 4),
        //     Icon(Icons.arrow_drop_down, size: 18, color: colorScheme.onSurface),
        //   ],
        // ),

        // Search field
        Expanded(
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      hintStyle: TextStyle(fontSize: 14, color: hintColor),
                      border: InputBorder.none,
                      fillColor: surface,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        left: 12,
                        right: 8,
                        bottom: 5,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  alignment: Alignment.center,
                  child: Icon(Icons.search, color: hintColor, size: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onBackPressed ?? () => Navigator.of(context).pop(),
          customBorder: const CircleBorder(),
          splashColor: colorScheme.onSurface.withOpacity(0.12),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back,
              size: 20,
              color: colorScheme.onSurface,
            ),
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
