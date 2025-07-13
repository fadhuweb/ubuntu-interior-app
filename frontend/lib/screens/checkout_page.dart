import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Payment method selection
  String? _selectedPaymentMethod;

  // Credit Card Controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Mobile Money Controllers
  final _phoneNumberController = TextEditingController();
  final _pinController = TextEditingController();

  // Shipping Address Controllers
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  String? _selectedMobileProvider;
  bool _isProcessing = false;
  int _currentStep = 0;

  final List<String> _mobileProviders = [
    'MTN Mobile Money',
    'Airtel Money',
    'Tigo Cash',
    'Orange Money',
  ];

  @override
  void initState() {
    super.initState();
    _countryController.text = 'Rwanda';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _phoneNumberController.dispose();
    _pinController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += value[i];
    }
    return formatted;
  }

  String _formatExpiry(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B4513),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildPaymentMethodStep(),
                _buildPaymentDetailsStep(),
                _buildShippingAddressStep(),
              ],
            ),
          ),
          // Bottom Navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepIndicator(0, 'Payment Method'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'Payment Details'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'Shipping Address'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF8B4513) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF8B4513) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    bool isActive = _currentStep > step;
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? const Color(0xFF8B4513) : Colors.grey[300],
    );
  }

  Widget _buildPaymentMethodStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 20),

          // Order Summary
          _buildOrderSummary(),

          const SizedBox(height: 30),

          // Payment Methods
          _buildPaymentMethodCard(
            'Credit Card',
            Icons.credit_card,
            'Pay with your credit or debit card',
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodCard(
            'Mobile Money',
            Icons.phone_android,
            'Pay with mobile money services',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String method,
    IconData icon,
    String description,
  ) {
    bool isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B4513) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? const Color(0xFF8B4513) : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF8B4513)
                          : const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: const Color(0xFF8B4513),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details - $_selectedPaymentMethod',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedPaymentMethod == 'Credit Card')
              _buildCreditCardForm()
            else if (_selectedPaymentMethod == 'Mobile Money')
              _buildMobileMoneyForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Column(
      children: [
        // Card Number
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            prefixIcon: Icon(Icons.credit_card),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          onChanged: (value) {
            String formatted = _formatCardNumber(value);
            if (formatted != value) {
              _cardNumberController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.replaceAll(' ', '').length < 16) {
              return 'Card number must be 16 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // Expiry Date
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: 'MM/YY',
                  prefixIcon: Icon(Icons.date_range),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (value) {
                  String formatted = _formatExpiry(value);
                  if (formatted != value) {
                    _expiryController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length < 5) {
                    return 'Invalid date';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),

            // CVV
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length < 3) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Card Holder Name
        TextFormField(
          controller: _cardHolderController,
          decoration: const InputDecoration(
            labelText: 'Card Holder Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card holder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMobileMoneyForm() {
    return Column(
      children: [
        // Mobile Provider
        DropdownButtonFormField<String>(
          value: _selectedMobileProvider,
          decoration: const InputDecoration(
            labelText: 'Select Provider',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          items: _mobileProviders.map((provider) {
            return DropdownMenuItem(value: provider, child: Text(provider));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMobileProvider = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a provider';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone Number
        TextFormField(
          controller: _phoneNumberController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
            hintText: '+250 7XX XXX XXX',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // PIN
        TextFormField(
          controller: _pinController,
          decoration: const InputDecoration(
            labelText: 'PIN',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          obscureText: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PIN';
            }
            if (value.length < 4) {
              return 'PIN must be 4 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildShippingAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 20),

          // Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.home),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // City
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Postal Code
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    prefixIcon: Icon(Icons.markunread_mailbox),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Country
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Country',
              prefixIcon: Icon(Icons.flag),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter country';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),

          // Items
          ...widget.cartItems
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item['title']} x${item['quantity']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const Divider(),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              Text(
                '\$${widget.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B4513),
                  side: const BorderSide(color: Color(0xFF8B4513)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(_currentStep == 2 ? 'Complete Order' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      // Validate payment method selection
      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment method')),
        );
        return;
      }
      _nextStep();
    } else if (_currentStep == 1) {
      // Validate payment details
      if (_formKey.currentState?.validate() ?? false) {
        _nextStep();
      }
    } else if (_currentStep == 2) {
      // Complete order
      _completeOrder();
    }
  }

  void _completeOrder() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Order Successful!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text('Payment via $_selectedPaymentMethod was successful!'),
                const SizedBox(height: 8),
                Text('Order Total: \$${widget.totalAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                const Text('You will receive a confirmation email shortly.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to cart
                  Navigator.pop(context); // Go back to home
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}
