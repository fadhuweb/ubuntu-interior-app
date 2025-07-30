import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  /// Email/Password Sign Up + Send Email Verification
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      if (!credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
      }

      return credential.user;
    } catch (e) {
      debugPrint('SignUp Error: $e');
      return null;
    }
  }

  /// Email/Password Login (only allow if email is verified)
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }

      return credential.user;
    } catch (e) {
      debugPrint('Login Error: $e');
      return null;
    }
  }

  /// Google Sign-In (always prompt account picker)
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // <-- Force account picker every time

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Sign Out
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;
}
