import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'home_page.dart';
import 'package:ubuntu_app/screens/artist/artist_home_page.dart';
import 'reset_password_page.dart';
import 'package:ubuntu_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

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
              _buildInput("Email", emailController, false),
              const SizedBox(height: 20),
              _buildPasswordInput(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage()));
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF8C4A2F)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLoginButton(),
              const SizedBox(height: 16),
              _buildGoogleLoginButton(),
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

  Widget _buildPasswordInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: "Password",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailPasswordLogin,
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

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Image.asset("assets/google_logo.png", height: 20),
        label: Text("Continue with Google", style: TextStyle(color: Colors.black87)),
        onPressed: _isLoading ? null : _handleGoogleLogin,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _handleEmailPasswordLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Please fill in all fields", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(email, password);
      if (user == null) throw Exception("Login failed");

      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut(); // Sign out the unverified user
        _showSnackbar("Please verify your email before logging in.", isError: true);
        return;
      }

      await _redirectBasedOnRole(user.uid);
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? "Login failed", isError: true);
    } catch (e) {
      _showSnackbar("Login error: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _showSnackbar("Google sign-in cancelled", isError: true);
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': 'customer',
        });
      }

      await _redirectBasedOnRole(user.uid);
    } catch (e) {
      _showSnackbar("Google login error: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _redirectBasedOnRole(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = doc.data()?['role'];

    if (role == 'artist') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ArtistHomePage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
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