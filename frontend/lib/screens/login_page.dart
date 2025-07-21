import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'home_page.dart';
import 'package:ubuntu_app/screens/artist/artist_home_page.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'Customer';
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
                "Welcome Back ",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C4A2F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Login to your account and continue exploring beautiful interior ideas.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              _buildRoleSelector(),
              const SizedBox(height: 24),
              _buildInput("Email", emailController, false),
              const SizedBox(height: 20),
              _buildInput("Password", passwordController, true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF8C4A2F)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLoginButton(),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                  },
                  child: Text(
                    "Don't have an account? Sign up",
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
                color: isSelected ? Colors.white : const Color(0xFF8C4A2F),
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFF8C4A2F),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF8C4A2F)),
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8C4A2F),
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
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "Login",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Please fill in all fields", isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      _showSnackbar("Login successful!", isError: false);

      // Navigate based on role
      if (selectedRole == 'Customer') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ArtistHomePage()));
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? "Login failed", isError: true);
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
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
