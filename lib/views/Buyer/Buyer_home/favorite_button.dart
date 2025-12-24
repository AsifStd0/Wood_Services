import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';

class FavoriteButton extends StatefulWidget {
  final String productId;
  final bool initialIsFavorited;

  const FavoriteButton({
    Key? key,
    required this.productId,
    this.initialIsFavorited = false,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorited;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.initialIsFavorited;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        // Get current favorite status
        final providerStatus = favoriteProvider.isProductFavorited(
          widget.productId,
        );
        final isFavorited = providerStatus ?? _isFavorited;
        final isLoading = favoriteProvider.isLoading || _isLoading;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () => _toggleFavorite(context, favoriteProvider, isFavorited),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.grey,
                      size: 20,
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    FavoriteProvider favoriteProvider,
    bool currentStatus,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await favoriteProvider.toggleFavorite(widget.productId);

      // Update local state
      setState(() {
        _isFavorited = !currentStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentStatus ? 'Added to favorites!' : 'Removed from favorites!',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
// // widgets/favorite_button.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wood_service/views/Buyer/Favorite_Screen/favorite_provider.dart';

// class FavoriteButton extends StatefulWidget {
//   final String productId;
//   final bool initialIsFavorited;

//   const FavoriteButton({
//     Key? key,
//     required this.productId,
//     this.initialIsFavorited = false,
//   }) : super(key: key);

//   @override
//   State<FavoriteButton> createState() => _FavoriteButtonState();
// }

// class _FavoriteButtonState extends State<FavoriteButton> {
//   late bool _isFavorited;

//   @override
//   void initState() {
//     super.initState();
//     _isFavorited = widget.initialIsFavorited;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FavoriteProvider>(
//       builder: (context, favoriteProvider, child) {
//         // Use provider state if available, otherwise use local state
//         final providerStatus = favoriteProvider.isProductFavorited(
//           widget.productId,
//         );
//         final isFavorited = providerStatus ?? _isFavorited;
//         final isLoading = favoriteProvider.isLoading;

//         return GestureDetector(
//           onTap: isLoading
//               ? null
//               : () => _toggleFavorite(context, favoriteProvider, isFavorited),
//           child: Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: isLoading
//                   ? SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : Icon(
//                       isFavorited ? Icons.favorite : Icons.favorite_border,
//                       color: isFavorited ? Colors.red : Colors.grey,
//                       size: 20,
//                     ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _toggleFavorite(
//     BuildContext context,
//     FavoriteProvider favoriteProvider,
//     bool currentStatus,
//   ) async {
//     try {
//       await favoriteProvider.toggleFavorite(widget.productId);

//       // Update local state
//       setState(() {
//         _isFavorited = !currentStatus;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             !currentStatus ? 'Added to favorites!' : 'Removed from favorites!',
//           ),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 1),
//         ),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${error.toString()}'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
// }
