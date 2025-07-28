import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Initialize Stripe
  static void initialize() {
    Stripe.publishableKey = 'pk_test_51RogKfRwPzE7J33vm0solBTz8ZN3Ygr9d6nqzq41wcV7GqRHnnZurI6BH2PBGAkiymeiERFVrZNikbNB3tJM1Tsj00iIDsDOJt'; // Replace with your publishable key
    Stripe.merchantIdentifier = 'Ubuntu Interior';
  }

  // Create payment intent
  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String artworkId,
    required String artistId,
    String currency = 'usd',
  }) async {
    try {
      // Convert dollars to cents for Stripe
      final amountInCents = (amount * 100).round();
      
      print('🟡 Calling Firebase function with amount: $amountInCents cents (\$${amount.toStringAsFixed(2)})');
      
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('createPaymentIntent');

      final result = await callable.call({
        'amount': amountInCents, // ✅ Now in cents
        'currency': currency,
        'artworkId': artworkId,
        'artistId': artistId,
      });

      print('✅ Firebase function response: ${result.data}');
      return result.data;
    } catch (e) {
      print('❌ Error creating payment intent: $e');
      return null;
    }
  }

  // Process payment
  Future<bool> processPayment({
    required String clientSecret,
    required BuildContext context,
  }) async {
    try {
      print('🟡 Presenting payment sheet...');
      
      // Present payment sheet
      await Stripe.instance.presentPaymentSheet(
        parameters: PresentPaymentSheetParameters(
          clientSecret: clientSecret,
          confirmPayment: true,
        ),
      );

      print('✅ Payment sheet completed successfully');
      // Payment successful
      return true;
    } on StripeException catch (e) {
      print('❌ Stripe error: ${e.error.localizedMessage}');
      
      // Don't show error for user cancellation
      if (e.error.code != FailureCode.Canceled) {
        _showPaymentError(context, e.error.localizedMessage ?? 'Payment failed');
      }
      return false;
    } catch (e) {
      print('❌ Payment error: $e');
      _showPaymentError(context, 'Payment failed. Please try again.');
      return false;
    }
  }

  // Initialize payment sheet
  Future<bool> initializePaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    try {
      print('🟡 Initializing payment sheet...');
      
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.system,
          testEnv: true, // ✅ Important for test mode
          billingDetails: const BillingDetails(
            email: null, // You can pre-fill customer email if available
          ),
        ),
      );
      
      print('✅ Payment sheet initialized successfully');
      return true;
    } catch (e) {
      print('❌ Error initializing payment sheet: $e');
      return false;
    }
  }

  // Confirm payment with backend
  Future<bool> confirmPayment(String paymentIntentId) async {
    try {
      print('🟡 Confirming payment with backend...');
      
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('confirmPayment');

      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
      });

      final success = result.data['success'] ?? false;
      print(success ? '✅ Payment confirmed successfully' : '❌ Payment confirmation failed');
      
      return success;
    } catch (e) {
      print('❌ Error confirming payment: $e');
      return false;
    }
  }

  // Get payment status
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentIntentId) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('getPaymentStatus');

      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
      });

      return result.data;
    } catch (e) {
      print('Error getting payment status: $e');
      return null;
    }
  }

  void _showPaymentError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// Payment result model
class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? error;

  PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.error,
  });
}