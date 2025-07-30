import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;

  const PaymentScreen({super.key, required this.cartItems, required this.totalPrice});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isProcessing = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _userEmail;
  String _selectedCurrency = 'USD';

  static const Map<String, double> _currencyRates = {
    'USD': 1.0,
    'RWF': 1200.0,
    'NGN': 1500.0,
    'KES': 160.0,
    'GHS': 15.0,
  };

  double get convertedTotal => widget.totalPrice * _currencyRates[_selectedCurrency]!;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userEmail = user?.email ?? 'test@example.com';
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _makePayment(BuildContext context) async {
    try {
      print("🚀 Entered _makePayment");

      if (!_formKey.currentState!.validate()) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      setState(() => _isProcessing = true);

      final txRef = "ubuntu-${DateTime.now().millisecondsSinceEpoch}";

      final customer = Customer(
        name: name,
        phoneNumber: phone,
        email: _userEmail!,
      );

      final flutterwave = Flutterwave(
        publicKey: "FLWPUBK_TEST-19f3dd4a1e7083069f25a0d8eaea06f0-X",
        currency: _selectedCurrency,
        amount: convertedTotal.toStringAsFixed(2),
        txRef: txRef,
        redirectUrl: "https://www.google.com",
        customer: customer,
        paymentOptions: "card,mobilemoneyrwanda",
        customization: Customization(title: "Ubuntu Interiors Payment"),
        isTestMode: true,
      );

      final ChargeResponse? response = await flutterwave.charge(context);

      print("📝 Flutterwave Response: ${response?.toJson()}");
      print("✅ Response success: ${response?.success}, status: ${response?.status}");

      if (response != null && response.status == 'successful') {
        print("✅ Payment success confirmed. Proceeding to place order...");
        await _placeOrder(context, user.uid, txRef, name, phone, address);
      } else if (response == null) {
        _showSnackBar(context, "Payment cancelled", Colors.orange);
      } else {
        _showSnackBar(context, "Payment failed: ${response.status}", Colors.red);
      }

      setState(() => _isProcessing = false);
    } catch (e, stack) {
      print("❌ Error in _makePayment: $e\n$stack");
      _showSnackBar(context, "Unexpected error: $e", Colors.red);
      setState(() => _isProcessing = false);
    }
  }

 Future<void> _placeOrder(BuildContext context, String userId, String txRef, String name, String phone, String address) async {
  print("🛒 Starting order placement");

  final orderRef = FirebaseFirestore.instance.collection('orders').doc();

  try {
    final items = widget.cartItems.map((item) => {
      'artworkId': item['id'],
      'title': item['title'],
      'price': item['price'],
      'quantity': item['quantity'],
      'artistId': item['artistId'],
      'status': 'Pending',
    }).toList();

    final artistIds = widget.cartItems
        .map((item) => item['artistId'])
        .toSet()
        .toList();

    print("🧾 Writing order to Firestore...");
    await orderRef.set({
      'userId': userId,
      'items': items,
      'artistIds': artistIds,
      'total': widget.totalPrice,
      'paymentRef': txRef,
      'paymentStatus': 'success',
      'date': FieldValue.serverTimestamp(),
      'currency': _selectedCurrency,
      'convertedTotal': convertedTotal,
      'shipping': {
        'recipient': name,
        'phone': phone,
        'address': address,
      },
      'status': 'Pending',
    });
    print("✅ Order written");

    // ✅ Add itemStatus subcollection per item (important for artist views)
    print("🧩 Creating itemStatus documents...");
    for (final item in items) {
      await orderRef.collection('itemStatus').add({
        'artworkId': item['artworkId'],
        'title': item['title'],
        'quantity': item['quantity'],
        'artistId': item['artistId'],
        'status': 'Pending',
      });
    }
    print("✅ itemStatus subcollection created");

    final cartCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('cart');
    final cartDocs = await cartCollection.get();

    print("🗑️ Deleting cart items...");
    for (var doc in cartDocs.docs) {
      try {
        await doc.reference.delete();
        print("🗑️ Deleted cart item: ${doc.id}");
      } catch (e) {
        print("❌ Failed to delete cart item ${doc.id}: $e");
      }
    }
    print("✅ Cart cleared");

    _showSnackBar(context, "Payment & order successful!", Colors.green);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    print("🚀 Redirecting to HomePage...");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  } catch (e, stack) {
    print("❌ Order error: $e");
    print("🔍 Stack trace: $stack");
    _showSnackBar(context, "Order error: ${e.toString()}", Colors.red);
  }
}



  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCurrency,
      items: _currencyRates.keys.map((currency) => DropdownMenuItem(
        value: currency,
        child: Text(currency),
      )).toList(),
      onChanged: (value) => setState(() => _selectedCurrency = value!),
      decoration: InputDecoration(
        labelText: "Currency",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStepContent() {
    return Form(
      key: _formKey,
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildFormCard([
            _buildValidatedField(_nameController, "Full Name", validator: (value) {
              if (value == null || value.trim().isEmpty) return "Full name is required";
              return null;
            }),
            const SizedBox(height: 16),
            _buildValidatedField(_phoneController, "Phone Number",
                inputType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Phone number is required";
                  if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) return "Enter a valid phone number (10+ digits)";
                  return null;
                }),
            const SizedBox(height: 16),
            _buildCurrencyDropdown(),
          ]),
          _buildFormCard([
            _buildValidatedField(_addressController, "Shipping Address", maxLines: 3, validator: (value) {
              if (value == null || value.trim().isEmpty) return "Shipping address is required";
              return null;
            })
          ]),
          _buildConfirmationCard(),
        ],
      ),
    );
  }

  Widget _buildValidatedField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ),
    );
  }

  Widget _buildConfirmationCard() {
    return _buildFormCard([
      const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      ...widget.cartItems.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text("${item['title']} x${item['quantity']}")),
            Text("${_selectedCurrency == 'USD' ? '\$' : ''}${(item['price'] * item['quantity'] * _currencyRates[_selectedCurrency]!).toStringAsFixed(2)} ${_selectedCurrency != 'USD' ? _selectedCurrency : ''}"),
          ],
        ),
      )),
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("${_selectedCurrency == 'USD' ? '\$' : ''}${convertedTotal.toStringAsFixed(2)} ${_selectedCurrency != 'USD' ? _selectedCurrency : ''}",
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    ]);
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: _isProcessing ? null : _previousStep,
            child: const Text("Back", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () {
                    if (_currentStep < 2) {
                      _nextStep();
                    } else {
                      _makePayment(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_currentStep == 2
                    ? "Pay ${_selectedCurrency == 'USD' ? '\$' : ''}${convertedTotal.toStringAsFixed(2)} ${_selectedCurrency != 'USD' ? _selectedCurrency : ''}"
                    : "Next",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepIndicator(0, 'Contact'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'Shipping'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'Confirm'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: isActive ? Colors.brown : Colors.grey[300],
          child: Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey[700])),
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isActive ? Colors.brown : Colors.grey[600]))
      ],
    );
  }

  Widget _buildStepLine(int step) {
    return Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 8), color: _currentStep > step ? Colors.brown : Colors.grey[300]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown,
        elevation: 3,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(child: _buildStepContent()),
          _buildBottomNav(),
        ],
      ),
    );
  }
}
