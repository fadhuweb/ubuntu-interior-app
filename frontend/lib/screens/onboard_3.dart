import 'package:flutter/material.dart';
import 'login_page.dart'; // ✅ Import the Login Page

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Placeholder
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                ),
                child: const Center(child: Text("Image Placeholder")),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                "Shop Unique Creations",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                "Browse and purchase one-of-a-kind African pieces made by local artists and artisans.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // ✅ Navigate to Login Page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text("Get Started"),
                ),
              ),
              const SizedBox(height: 16),

              // Skip Button
              //TextButton(
              //onPressed: () {
              // Optional: You can make this go to login as well
              //Navigator.pushReplacement(
              //context,
              //MaterialPageRoute(builder: (context) => const LoginPage()),
              //);
              //},
              //child: Text("Skip", style: TextStyle(color: Colors.brown[700])),
              //),
            ],
          ),
        ),
      ),
    );
  }
}
