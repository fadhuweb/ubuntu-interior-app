import 'package:flutter/material.dart';
import 'package:ubuntu_app/utils/colors.dart';
import 'package:ubuntu_app/utils/text_styles.dart';
import 'onboard_3.dart';
import 'login_page.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                  color: AppColors.onboardingGreyLight,
                ),
                child: const Center(child: Text("Image Placeholder")),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                "Connect with African Artists",
                style: AppTextStyles.onboardingHeading,
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                "Discover talented creators and engage with African art communities across the continent.",
                textAlign: TextAlign.center,
                style: AppTextStyles.onboardingDescription,
              ),
              const SizedBox(height: 48),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen3(),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: AppTextStyles.onboardingButton,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Skip Button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text("Skip", style: AppTextStyles.onboardingSkip),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
