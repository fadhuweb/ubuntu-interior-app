import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class ArtworkPaymentWidget extends StatefulWidget {
  final String artworkId;
  final String artistId;
  final double price;
  final String artworkTitle;
  final String artistName;
  final VoidCallback? onPaymentSuccess;

  const ArtworkPaymentWidget({
    Key? key,
    required this.artworkId,
    required this.artistId,
    required this.price,
    required this.artworkTitle,
    required this.artistName,
    this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<ArtworkPaymentWidget> createState() => _ArtworkPaymentWidgetState();
}

class _ArtworkPaymentWidgetState extends State<ArtworkPaymentWidget> {
  bool _isProcessing = false;
  String _debugInfo = '';
  final PaymentService _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Artwork info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.artworkTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${widget.artistName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Price breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Artwork Price'),
                    Text('\$${widget.price.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Processing Fee'),
                    Text('\$${(widget.price * 0.029 + 0.30).toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${(widget.price + widget.price * 0.029 + 0.30).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // TEST MODE INDICATOR (for debugging)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.science, size: 16, color: Colors.orange[800]),
                const SizedBox(width: 8),
                Text(
                  'TEST MODE - Use card 4242 4242 4242 4242',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Purchase Artwork',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Debug info (only show in development)
          if (_debugInfo.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Debug: $_debugInfo',
                style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Security info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Secure payment powered by Stripe',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _debugInfo = 'Starting payment...';
    });

    try {
      // Calculate total amount (including fees)
      final totalAmount = widget.price + widget.price * 0.029 + 0.30;
      
      setState(() {
        _debugInfo = 'Creating payment intent for \$${totalAmount.toStringAsFixed(2)}...';
      });

      print('🟡 Starting payment process for artwork: ${widget.artworkId}');
      print('🟡 Total amount: \$${totalAmount.toStringAsFixed(2)}');

      // Create payment intent
      final paymentData = await _paymentService.createPaymentIntent(
        amount: totalAmount,
        artworkId: widget.artworkId,
        artistId: widget.artistId,
      );

      if (paymentData == null) {
        _showError('Failed to initialize payment. Please try again.');
        setState(() {
          _debugInfo = 'ERROR: Payment intent creation failed';
        });
        return;
      }

      print('✅ Payment intent created successfully');
      print('🔑 Client secret received: ${paymentData['clientSecret']?.substring(0, 20)}...');

      final clientSecret = paymentData['clientSecret'];
      final paymentIntentId = paymentData['paymentIntentId'];

      setState(() {
        _debugInfo = 'Initializing payment sheet...';
      });

      // Initialize payment sheet
      final initialized = await _paymentService.initializePaymentSheet(
        clientSecret: clientSecret,
        merchantDisplayName: 'Ubuntu Interior',
      );

      if (!initialized) {
        _showError('Failed to initialize payment. Please try again.');
        setState(() {
          _debugInfo = 'ERROR: Payment sheet initialization failed';
        });
        return;
      }

      print('✅ Payment sheet initialized successfully');

      setState(() {
        _debugInfo = 'Processing payment...';
      });

      // Process payment
      final success = await _paymentService.processPayment(
        clientSecret: clientSecret,
        context: context,
      );

      if (success) {
        print('✅ Payment processed successfully');
        setState(() {
          _debugInfo = 'Confirming payment...';
        });
        
        // Confirm payment with backend
        final confirmed = await _paymentService.confirmPayment(paymentIntentId);
        
        if (confirmed) {
          print('✅ Payment confirmed successfully');
          _showSuccess('Payment successful! You now own this artwork.');
          setState(() {
            _debugInfo = 'Payment completed successfully!';
          });
          widget.onPaymentSuccess?.call();
        } else {
          _showError('Payment processed but confirmation failed. Please contact support.');
          setState(() {
            _debugInfo = 'ERROR: Payment confirmation failed';
          });
        }
      } else {
        print('❌ Payment processing failed');
        setState(() {
          _debugInfo = 'Payment was cancelled or failed';
        });
      }

    } catch (e) {
      print('❌ Payment error: $e');
      _showError('Payment failed: ${e.toString()}');
      setState(() {
        _debugInfo = 'ERROR: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}