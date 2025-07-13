import 'package:flutter/material.dart';
import 'package:ubuntu_app/utils/colors.dart';
import 'package:ubuntu_app/utils/text_styles.dart';
import 'onboard_1.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.splashPrimary, AppColors.splashSecondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo placeholder
              Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  color: AppColors.splashWhite,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("Ubuntu", style: AppTextStyles.splashLogo),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Ubuntu Interiors",
                style: AppTextStyles.splashAppName,
              ),

              const SizedBox(height: 8),
              const Text(
                "United by Culture. Inspired\nThrough Art",
                textAlign: TextAlign.center,
                style: AppTextStyles.splashTagline,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen1(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.splashWhite,
                  foregroundColor: AppColors.splashPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Start with Ubuntu",
                  style: AppTextStyles.splashButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
