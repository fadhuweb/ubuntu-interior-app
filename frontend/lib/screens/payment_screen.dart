import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/charge_request.dart';
import 'package:flutterwave_standard/view/view_utils.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  void _makePayment(BuildContext context) async {
    final style = FlutterwaveStyle(
      appBarText: "Ubuntu Interiors",
      buttonColor: const Color(0xFFB79891),
      buttonTextStyle: const TextStyle(color: Colors.white),
      appBarColor: const Color(0xFF6F4E37),
      dialogCancelTextStyle: const TextStyle(color: Colors.redAccent),
    );

    final Customer customer = Customer(
      name: "Test User",
      phoneNumber: "0780000000",
      email: "test@example.com",
    );

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      style: style,
      publicKey: "FLWPUBK_TEST-19f3dd4a1e7083069f25a0d8eaea06f0-X",
      currency: "RWF",
      amount: "5000",
      email: customer.email,
      fullName: customer.name,
      txRef: "ubuntu-${DateTime.now().millisecondsSinceEpoch}",
      isDebugMode: true,
      phoneNumber: customer.phoneNumber,
      acceptCardPayment: true,
      acceptUSSDPayment: false,
      acceptAccountPayment: false,
      acceptMpesaPayment: false,
      acceptFrancophoneMobileMoney: false,
      acceptGhanaPayment: false,
      acceptPaypalPayment: false,
      acceptZambiaPayment: false,
      acceptRwandaMoneyPayment: true,
      onComplete: (response) {
        print("✅ Payment Response: ${response?.status}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment ${response?.status}")),
        );
      },
      onCancelled: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Cancelled")),
        );
      },
    );

    await flutterwave.charge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Make Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _makePayment(context),
          child: const Text("Pay Now"),
        ),
      ),
    );
  }
}
