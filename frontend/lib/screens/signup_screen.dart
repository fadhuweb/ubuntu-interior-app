import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ubuntu_app/utils/colors.dart';
import 'package:ubuntu_app/utils/text_styles.dart';
import 'home_page.dart';
import 'package:ubuntu_app/screens/artist/artist_home_page.dart';

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

  bool _isLoading = false;

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
                  child: const Text(
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
                color: isSelected ? Colors.white : const Color(0xFFDF794E),
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFFDF805B),
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDD825D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Sign Up",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Please fill in all required fields", isError: true);
      return;
    }

    if (selectedRole == 'Customer' && nameController.text.trim().isEmpty) {
      _showSnackbar("Please enter your full name", isError: true);
      return;
    }

    if (selectedRole == 'Artist' &&
        (brandController.text.trim().isEmpty || portfolioController.text.trim().isEmpty)) {
      _showSnackbar("Please complete all artist fields", isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Optionally: store role or other info in Firestore

      _showSnackbar("Account created successfully!", isError: false);

      // Navigate based on role
      if (selectedRole == 'Customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ArtistHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? "Signup failed", isError: true);
    } catch (e) {
      _showSnackbar("An unexpected error occurred", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFCF7D5A),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    portfolioController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
