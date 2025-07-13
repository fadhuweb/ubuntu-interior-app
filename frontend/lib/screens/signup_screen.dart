import 'package:flutter/material.dart';
import 'package:ubuntu_app/utils/colors.dart';
import 'package:ubuntu_app/utils/text_styles.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedRole = 'Customer';

  final TextEditingController nameController = TextEditingController(); // Customer
  final TextEditingController brandController = TextEditingController(); // Artist
  final TextEditingController portfolioController = TextEditingController(); // Artist
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account ",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCD7955),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign up as a ${selectedRole.toLowerCase()} to get started.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),

              _buildRoleSelector(),
              const SizedBox(height: 24),

              // Conditional fields
              if (selectedRole == 'Customer')
                _buildInput("Full Name", nameController, false),
              if (selectedRole == 'Artist') ...[
                _buildInput("Studio/Brand Name", brandController, false),
                const SizedBox(height: 16),
                _buildInput("Portfolio URL", portfolioController, false),
              ],
              const SizedBox(height: 16),

              _buildInput("Email", emailController, false),
              const SizedBox(height: 16),

              _buildInput("Password", passwordController, true),
              const SizedBox(height: 32),

              _buildSignUpButton(),
              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Color(0xFF8C4A2F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['Customer', 'Artist'].map((role) {
        final isSelected = selectedRole == role;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ChoiceChip(
            label: Text(
              role,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFFDF794E),
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: Color(0xFFDF805B),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFD57A55)),
            ),
            onSelected: (_) => setState(() => selectedRole = role),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          String msg;
          if (selectedRole == 'Customer') {
            msg =
            "Customer: ${nameController.text}, Email: ${emailController.text}";
          } else {
            msg =
            "Artist: ${brandController.text}, Portfolio: ${portfolioController.text}, Email: ${emailController.text}";
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Signed up as $msg"),
            backgroundColor: Color(0xFFCF7D5A),
          ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFDD825D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
