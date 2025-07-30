import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'package:ubuntu_app/screens/artist/artist_home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedRole = 'Customer';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController portfolioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

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
              Text("Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCD7955),
                  )),
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
              _buildPasswordInput(),
              const SizedBox(height: 24),
              _buildSignUpButton(),
              const SizedBox(height: 16),

              if (selectedRole == 'Customer') _buildGoogleSignUpButton(),

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
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : const Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGoogleSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: Image.asset("assets/google_logo.png", height: 20),
        label: const Text("Sign up with Google"),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (!mounted) return;

      final user = userCredential.user!;
      await user.sendEmailVerification();

      if (!mounted) return;
      _showEmailVerificationDialog(user, email);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackbar(e.message ?? "Signup failed", isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackbar("An unexpected error occurred", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEmailVerificationDialog(User user, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Verify Your Email"),
        content: const Text("A verification email has been sent. Please verify and click Continue."),
        actions: [
          TextButton(
            onPressed: () async {
              await user.reload();
              final refreshedUser = FirebaseAuth.instance.currentUser;

              if (refreshedUser != null && refreshedUser.emailVerified) {
                final uid = refreshedUser.uid;

                await FirebaseFirestore.instance.collection('users').doc(uid).set({
                  'role': selectedRole.toLowerCase(),
                  'email': email,
                  'name': selectedRole == 'Customer'
                      ? nameController.text.trim()
                      : brandController.text.trim(),
                  'portfolio':
                      selectedRole == 'Artist' ? portfolioController.text.trim() : null,
                  'createdAt': Timestamp.now(),
                });

                if (!mounted) return;
                Navigator.of(context).pop(); // Close dialog
                _navigateAfterLogin();
              } else {
                if (!mounted) return;
                _showSnackbar("Email not verified yet", isError: true);
              }
            },
            child: const Text("Continue"),
          )
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (selectedRole != 'Customer') {
      _showSnackbar("Only customers can sign up with Google", isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      if (!mounted) return;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      final user = userCredential.user!;
      final uid = user.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'role': selectedRole.toLowerCase(),
          'email': user.email,
          'name': user.displayName ?? "",
          'portfolio': null,
          'createdAt': Timestamp.now(),
        });
      }

      if (!mounted) return;
      _navigateAfterLogin();
    } catch (e) {
      if (!mounted) return;
      _showSnackbar("Google sign-in failed", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateAfterLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            selectedRole == 'Customer' ? const HomePage() : const ArtistHomePage(),
      ),
    );
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
