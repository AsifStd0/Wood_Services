import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Buyer/Buyer_home/buyer_home_model.dart';
import 'package:wood_service/views/Buyer/Buyer_home/home_provider.dart';

// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NWY0N2I5ZTIxZGVjMTRjMDg0Mzc2ZiIsImlhdCI6MTc2NzkzNDY4MywiZXhwIjoxNzcwNTI2NjgzfQ.EhD26aua5ngVyY2f5YUZ-nRrVal2scWfy4AlcvJsSN8

class ShopPreviewCard extends StatelessWidget {
  final BuyerProductModel product;

  const ShopPreviewCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final sellerInfo = product.sellerInfo;

    // Use the correct field names
    final shopName = sellerInfo?['businessName'] ?? 'Unknown Shop';
    final sellerName = sellerInfo?['name'] ?? 'Unknown Seller';
    final shopLogo = sellerInfo?['shopLogo'];
    final totalProducts = sellerInfo?['totalProducts'] ?? 0;
    final verificationStatus = sellerInfo?['verificationStatus'] ?? 'pending';

    return GestureDetector(
      onTap: () {
        _showShopDetailsDialog(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Shop Logo with verification badge
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    image: shopLogo != null
                        ? DecorationImage(
                            image: NetworkImage(_getFullImageUrl(shopLogo)),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage(
                              'assets/images/shop_placeholder.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                if (verificationStatus == 'verified')
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green),
                      ),
                      child: Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Shop Name and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shopName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Seller Name
                  Text(
                    sellerName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      // Products count
                      Icon(
                        Icons.inventory,
                        size: 12,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$totalProducts products',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Verification status badge
                      if (verificationStatus != 'verified')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            verificationStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      if (verificationStatus == 'verified')
                        Row(
                          children: [
                            Icon(Icons.verified, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(Icons.chevron_right, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://192.168.137.78:5001$imagePath';
  }

  void _showShopDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleShopDialog(product: product),
    );
  }
}

class SimpleShopDialog extends StatefulWidget {
  final BuyerProductModel product;

  const SimpleShopDialog({super.key, required this.product});

  @override
  State<SimpleShopDialog> createState() => _SimpleShopDialogState();
}

class _SimpleShopDialogState extends State<SimpleShopDialog> {
  bool _isRequestingVisit = false;
  String? _visitStatus;
  final TextEditingController _messageController = TextEditingController();
  String? _selectedDate;
  String? _selectedTime;
  List<Map<String, dynamic>> _myVisitRequests = [];

  @override
  void initState() {
    super.initState();
    _loadVisitStatus();
    _loadMyVisitRequests();
  }

  void _loadVisitStatus() {
    final viewModel = Provider.of<BuyerHomeViewModel>(context, listen: false);
    final sellerId = widget.product.sellerId?.toString();
    if (sellerId != null) {
      _visitStatus = viewModel.getVisitStatusForSeller(sellerId);
    }
  }

  Future<void> _loadMyVisitRequests() async {
    try {
      final viewModel = Provider.of<BuyerHomeViewModel>(context, listen: false);
      _myVisitRequests = await viewModel.getMyVisitRequests();

      // Update local status based on actual requests
      final sellerId = widget.product.sellerId?.toString();
      if (sellerId != null) {
        final myRequest = _myVisitRequests.firstWhere(
          (req) => req['seller']?['id'] == sellerId,
          orElse: () => {},
        );

        if (myRequest.isNotEmpty) {
          setState(() {
            _visitStatus = myRequest['status']?.toString();
          });
        }
      }
    } catch (error) {
      print('Error loading visit requests: $error');
    }
  }

  Future<void> _requestVisit() async {
    final sellerId = widget.product.sellerId?.toString();
    final shopName =
        widget.product.sellerInfo?['businessName'] ?? 'Unknown Shop';

    if (sellerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seller ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isRequestingVisit = true;
    });

    try {
      final viewModel = Provider.of<BuyerHomeViewModel>(context, listen: false);

      final result = await viewModel.requestVisitToShop(
        sellerId: sellerId,
        shopName: shopName,
        message: _messageController.text.isNotEmpty
            ? _messageController.text
            : null,
        preferredDate: _selectedDate,
        preferredTime: _selectedTime,
        context: context,
      );

      // If result has error about existing request
      if (result['hasExistingRequest'] == true) {
        // Show options to cancel existing request
        _showExistingRequestDialog(sellerId, shopName);
        return;
      }

      // Update local status
      setState(() {
        _visitStatus = 'pending';
      });

      // Reload requests
      await _loadMyVisitRequests();

      // Close the form dialog (not the main dialog)
      Navigator.of(context).pop(); // This closes the AlertDialog with the form
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingVisit = false;
        });
      }
    }
  }

  void _showExistingRequestDialog(String sellerId, String shopName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Existing Request Found'),
        content: Text(
          'You already have a pending visit request for $shopName.\n\n'
          'Would you like to cancel it first?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep It'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close this dialog
              await _cancelExistingRequest(sellerId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel & Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelExistingRequest(String sellerId) async {
    try {
      // Find the existing request
      final existingRequest = _myVisitRequests.firstWhere(
        (req) => req['seller']?['id'] == sellerId && req['status'] == 'pending',
        orElse: () => {},
      );

      if (existingRequest.isNotEmpty && existingRequest['id'] != null) {
        final viewModel = Provider.of<BuyerHomeViewModel>(
          context,
          listen: false,
        );

        await viewModel.cancelShopVisit(
          sellerId: sellerId,
          requestId: existingRequest['id'].toString(),
          context: context,
        );

        // Update local state
        setState(() {
          _visitStatus = null;
        });

        // Show the form again
        _showVisitRequestForm();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling request: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVisitRequestForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Shop Visit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Request to visit: ${widget.product.sellerInfo?['businessName'] ?? 'Unknown Shop'}',
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 16),

              // Message field
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message (Optional)',
                  hintText: 'Tell the seller why you want to visit...',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Date picker
              ElevatedButton.icon(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _selectedDate =
                          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate ?? 'Select Preferred Date'),
              ),

              const SizedBox(height: 12),

              // Time picker
              ElevatedButton.icon(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _selectedTime =
                          '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    });
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(_selectedTime ?? 'Select Preferred Time'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isRequestingVisit ? null : _requestVisit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: _isRequestingVisit
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _showVisitDetails() {
    final sellerId = widget.product.sellerId?.toString();
    final shopName =
        widget.product.sellerInfo?['businessName'] ?? 'Unknown Shop';

    // Find the accepted request details
    final acceptedRequest = _myVisitRequests.firstWhere(
      (req) => req['seller']?['id'] == sellerId && req['status'] == 'accepted',
      orElse: () => {},
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visit Approved!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your visit request to $shopName has been approved!'),
            const SizedBox(height: 16),
            if (acceptedRequest['visitDate'] != null)
              Text('📅 Date: ${acceptedRequest['visitDate']}'),
            if (acceptedRequest['visitTime'] != null)
              Text('⏰ Time: ${acceptedRequest['visitTime']}'),
            if (acceptedRequest['location'] != null)
              Text('📍 Location: ${acceptedRequest['location']}'),
            if (acceptedRequest['duration'] != null)
              Text('⏱️ Duration: ${acceptedRequest['duration']}'),
            const SizedBox(height: 12),
            if (acceptedRequest['sellerResponse']?['message'] != null)
              Text(
                '💬 Seller Message: ${acceptedRequest['sellerResponse']['message']}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitButton() {
    final sellerId = widget.product.sellerId?.toString();
    final shopName =
        widget.product.sellerInfo?['businessName'] ?? 'Unknown Shop';

    if (sellerId == null) {
      return const SizedBox.shrink();
    }

    // Check if we have a pending request for this seller
    final myRequest = _myVisitRequests.firstWhere(
      (req) => req['seller']?['id'] == sellerId,
      orElse: () => {},
    );

    // Use actual status from server or local status
    final status = myRequest.isNotEmpty
        ? myRequest['status']?.toString()
        : _visitStatus;

    if (status == null || status == 'cancelled' || status == 'declined') {
      // No request yet or request was cancelled/declined - show request button
      return ElevatedButton(
        onPressed: _isRequestingVisit ? null : _showVisitRequestForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isRequestingVisit
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : const Text('Request Visit'),
      );
    }

    switch (status) {
      case 'pending':
        return OutlinedButton.icon(
          onPressed: () {
            _showPendingRequestOptions();
          },
          icon: const Icon(Icons.pending, size: 18),
          label: const Text('Pending Approval'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
          ),
        );

      case 'accepted':
        return ElevatedButton.icon(
          onPressed: _showVisitDetails,
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Visit Approved'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        );

      case 'declined':
        return OutlinedButton.icon(
          onPressed: _showVisitRequestForm,
          icon: const Icon(Icons.cancel, size: 18),
          label: const Text('Request Declined'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
        );

      default:
        return ElevatedButton(
          onPressed: _showVisitRequestForm,
          child: const Text('Request Visit'),
        );
    }
  }

  void _showPendingRequestOptions() {
    final sellerId = widget.product.sellerId?.toString();
    final shopName =
        widget.product.sellerInfo?['businessName'] ?? 'Unknown Shop';

    if (sellerId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pending Visit Request'),
        content: Text(
          'You have a pending visit request for $shopName.\n\n'
          'What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Wait'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show details of pending request
              _showRequestDetails();
            },
            child: const Text('View Details'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelPendingRequest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails() {
    final sellerId = widget.product.sellerId?.toString();
    final shopName =
        widget.product.sellerInfo?['businessName'] ?? 'Unknown Shop';

    final myRequest = _myVisitRequests.firstWhere(
      (req) => req['seller']?['id'] == sellerId,
      orElse: () => {},
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shop: $shopName'),
            const SizedBox(height: 8),
            Text('Status: ${myRequest['status']?.toUpperCase() ?? 'Unknown'}'),
            const SizedBox(height: 8),
            if (myRequest['message'] != null && myRequest['message'].isNotEmpty)
              Text('Your Message: ${myRequest['message']}'),
            const SizedBox(height: 8),
            if (myRequest['preferredDate'] != null)
              Text('Preferred Date: ${myRequest['preferredDate']}'),
            if (myRequest['preferredTime'] != null)
              Text('Preferred Time: ${myRequest['preferredTime']}'),
            const SizedBox(height: 8),
            Text(
              'Requested: ${myRequest['requestedDate'] != null ? DateTime.parse(myRequest['requestedDate']).toString().split(' ')[0] : 'N/A'}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelPendingRequest() async {
    final sellerId = widget.product.sellerId?.toString();

    if (sellerId == null) return;

    try {
      final viewModel = Provider.of<BuyerHomeViewModel>(context, listen: false);

      // Find the request ID
      final myRequest = _myVisitRequests.firstWhere(
        (req) => req['seller']?['id'] == sellerId && req['status'] == 'pending',
        orElse: () => {},
      );

      if (myRequest.isNotEmpty && myRequest['id'] != null) {
        await viewModel.cancelShopVisit(
          sellerId: sellerId,
          requestId: myRequest['id'].toString(),
          context: context,
        );

        // Update local state
        setState(() {
          _visitStatus = null;
          _myVisitRequests.removeWhere(
            (req) => req['seller']?['id'] == sellerId,
          );
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellerInfo = widget.product.sellerInfo ?? {};
    final shopName = sellerInfo['businessName'] ?? 'Unknown Shop';
    final sellerName = sellerInfo['name'] ?? 'Unknown Seller';
    final email = sellerInfo['email'];
    final phone = sellerInfo['phone'];
    final shopLogo = sellerInfo['shopLogo'];
    final verificationStatus = sellerInfo['verificationStatus'] ?? 'pending';
    final shopLocation = sellerInfo['address'] is Map
        ? _formatAddress(sellerInfo['address'])
        : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shop Logo
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    color: Colors.grey.shade100,
                  ),
                  child: shopLogo != null && shopLogo.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _getFullImageUrl(shopLogo),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.store,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.store, size: 40, color: Colors.grey),
                ),
                if (verificationStatus == 'verified')
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.verified, color: Colors.green, size: 18),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Shop Name
            Text(
              shopName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Seller Name
            Text(
              sellerName,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Contact Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  // Email
                  if (email != null && email.isNotEmpty)
                    _buildContactItem(
                      icon: Icons.email,
                      title: 'Email',
                      value: email,
                    ),

                  if (email != null && email.isNotEmpty)
                    const SizedBox(height: 10),

                  // Phone
                  if (phone != null && phone.isNotEmpty)
                    _buildContactItem(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: phone,
                    ),

                  if (shopLocation != null && shopLocation.isNotEmpty)
                    const SizedBox(height: 10),

                  // Location
                  if (shopLocation != null && shopLocation.isNotEmpty)
                    _buildContactItem(
                      icon: Icons.location_on,
                      title: 'Location',
                      value: shopLocation,
                    ),
                ],
              ),
            ),

            // Visit Request Status
            if (_visitStatus != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(_visitStatus!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(_visitStatus!).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(_visitStatus!),
                      color: _getStatusColor(_visitStatus!),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStatusMessage(_visitStatus!, shopName),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(_visitStatus!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        _buildVisitButton(),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'accepted':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusMessage(String status, String shopName) {
    switch (status) {
      case 'pending':
        return 'Visit request sent to $shopName. Waiting for approval.';
      case 'accepted':
        return 'Your visit to $shopName has been approved!';
      case 'declined':
        return 'Your visit request to $shopName was declined.';
      default:
        return 'Visit status: $status';
    }
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://192.168.18.107:5001$imagePath';
  }

  String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return '';
    final parts = <String>[];
    if (address['street'] != null) parts.add(address['street']);
    if (address['city'] != null) parts.add(address['city']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['country'] != null) parts.add(address['country']);
    return parts.join(', ');
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ! ******
