import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8C4A2F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reset Password",
          style: TextStyle(
            color: Color(0xFF8C4A2F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_emailSent) ...[
                  _buildLockIcon(),
                  const SizedBox(height: 24),
                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C4A2F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter your email address and we'll send you a reset link.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 32),
                  _buildEmailInput(),
                  const SizedBox(height: 24),
                  _buildSendButton(),
                  const SizedBox(height: 16),
                  _buildGoogleSignInButton(),
                  const SizedBox(height: 24),
                  if (currentUser != null && !currentUser!.emailVerified)
                    _buildVerifyEmailInfo(),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Login",
                          style: TextStyle(
                              color: Color(0xFF8C4A2F),
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ] else
                  _buildSuccessState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF8C4A2F).withValues(alpha: 26),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock_reset, size: 40, color: Color(0xFF8C4A2F)),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: "Enter your email address",
          prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF8C4A2F)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email address';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendResetEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8C4A2F),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text("Send Reset Link",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 60, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          "Email Sent!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8C4A2F),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "We've sent a reset link to\n${emailController.text}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => setState(() => _emailSent = false),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF8C4A2F)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Resend Email",
              style: TextStyle(
                  color: Color(0xFF8C4A2F), fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.login, color: Color(0xFF8C4A2F)),
        label: const Text(
          "Sign in with Google",
          style: TextStyle(
              color: Color(0xFF8C4A2F), fontWeight: FontWeight.w500),
        ),
        onPressed: _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF8C4A2F)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildVerifyEmailInfo() {
    return Column(
      children: [
        const Text(
          "Your email is not verified.",
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _sendEmailVerification,
          child: const Text(
            "Resend Verification Email",
            style: TextStyle(
                color: Color(0xFF8C4A2F), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text.trim());

        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _emailSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset email sent successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Signed in with Google successfully!"),
        backgroundColor: Colors.green,
      ));

      setState(() => currentUser = FirebaseAuth.instance.currentUser);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Google Sign-In failed: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _sendEmailVerification() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Verification email sent."),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to send verification email: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
