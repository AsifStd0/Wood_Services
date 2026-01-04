// lib/views/Buyer/widgets/product_review_widget.dart
import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// lib/views/Buyer/widgets/reviews_preview_section.dart
import 'package:provider/provider.dart';
import 'package:wood_service/views/Buyer/payment/rating/review_provider.dart';

class ReviewsPreviewSection extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewsPreviewSection({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ReviewsPreviewSection> createState() => _ReviewsPreviewSectionState();
}

class _ReviewsPreviewSectionState extends State<ReviewsPreviewSection> {
  List<dynamic> _reviews = [];
  Map<String, dynamic> _stats = {'average': 0.0, 'total': 0};
  bool _isLoading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = false;
      });

      final reviewProvider = context.read<ReviewProvider>();
      final result = await reviewProvider.getProductReviewsWithStats(
        productId: widget.productId,
        limit: 2, // Show 2 reviews in preview
      );

      if (result['success'] == true) {
        setState(() {
          _reviews = result['reviews'] ?? [];
          _stats = result['stats'] ?? {};
        });
      } else {
        setState(() => _error = true);
      }
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() => _error = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalReviews = _stats['total'] ?? 0;
    final averageRating = _stats['average'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Reviews',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (totalReviews > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Star Rating
                        ...List.generate(5, (index) {
                          return Icon(
                            index < averageRating.floor()
                                ? Icons.star
                                : index < averageRating.ceil()
                                ? Icons.star_half
                                : Icons.star_border,
                            size: 18,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($totalReviews ${totalReviews == 1 ? 'review' : 'reviews'})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // Rating Distribution (Optional)
                    if (_stats['ratingDistribution'] != null) ...[
                      const SizedBox(height: 8),
                      _buildRatingDistribution(),
                    ],
                  ],
                ],
              ),
            ),

            // View All Button (only if there are reviews)
            if (totalReviews > 2)
              TextButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AllProductReviewsScreen(
                  //       productId: widget.productId,
                  //       productName: widget.productName,
                  //     ),
                  //   ),
                  // );
                },
                child: const Text('View All'),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // Loading State
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        // Error State
        else if (_error)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Unable to load reviews',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadReviews,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          )
        // No Reviews State
        else if (_reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.reviews_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to review this product',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        // Reviews List
        else
          Column(
            children: [
              ..._reviews.map((review) {
                return Column(
                  children: [
                    ProductReviewWidget(review: review),
                    if (_reviews.indexOf(review) < _reviews.length - 1)
                      const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildRatingDistribution() {
    final distribution = _stats['ratingDistribution'] ?? {};

    return Column(
      children: [
        for (int rating = 5; rating >= 1; rating--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(
                  '$rating',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value:
                        (distribution['$rating'] ?? 0) / (_stats['total'] ?? 1),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${((distribution['$rating'] ?? 0) / (_stats['total'] ?? 1) * 100).toInt()}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ProductReviewWidget extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool showVerifiedBadge;

  const ProductReviewWidget({
    super.key,
    required this.review,
    this.showVerifiedBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final buyerName = review['buyerName'] ?? 'Anonymous';
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final title = review['title'] ?? '';
    final createdAt = review['createdAt'] != null
        ? DateTime.parse(review['createdAt']).toLocal()
        : DateTime.now();
    final verifiedPurchase = review['verifiedPurchase'] ?? false;
    final buyerImage = review['buyerImage'];
    final helpfulCount = review['helpfulVotes'] ?? review['helpfulCount'] ?? 0;
    final productName = review['productName'] ?? '';

    // Construct full image URL
    String? fullImageUrl;
    if (buyerImage != null && buyerImage.isNotEmpty) {
      if (buyerImage.startsWith('http')) {
        fullImageUrl = buyerImage;
      } else if (buyerImage.startsWith('/uploads/')) {
        fullImageUrl = 'http://192.168.10.20:5001$buyerImage';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buyer Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipOval(child: _buildAvatar(fullImageUrl, buyerName)),
              ),

              const SizedBox(width: 12),

              // Buyer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            buyerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Verified Purchase Badge
                        if (verifiedPurchase && showVerifiedBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Rating Stars
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            size: 18,
                            color: index < rating
                                ? Colors.amber
                                : Colors.grey[400],
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // Review Date
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review Title (if exists)
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
          ],

          // Review Comment
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),

          // Product Name (Optional)
          if (productName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Purchased: $productName',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          // Helpful Votes
          if (helpfulCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.thumb_up_rounded, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '$helpfulCount ${helpfulCount == 1 ? 'person' : 'people'} found this helpful',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, String buyerName) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(radius: 60);
      // CachedNetworkImage(
      //   imageUrl: imageUrl,
      //   fit: BoxFit.cover,
      //   placeholder: (context, url) => Container(
      //     color: Colors.grey[200],
      //     child: Center(
      //       child: Text(
      //         buyerName.isNotEmpty ? buyerName[0].toUpperCase() : '?',
      //         style: const TextStyle(
      //           color: Colors.grey,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //   ),
      //   errorWidget: (context, url, error) => Container(
      //     color: Colors.grey[200],
      //     child: Center(
      //       child: Text(
      //         buyerName.isNotEmpty ? buyerName[0].toUpperCase() : '?',
      //         style: const TextStyle(
      //           color: Colors.grey,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //   ),
      // );
    } else {
      return Container(
        color: Colors.blue[100],
        child: Center(
          child: Text(
            buyerName.isNotEmpty ? buyerName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
