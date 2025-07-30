import 'package:flutter/material.dart';
import 'package:ubuntu_app/utils/colors.dart';
import 'package:ubuntu_app/utils/text_styles.dart';
import 'login_page.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image Placeholder
                        Container(
                          height: MediaQuery.of(context).orientation == Orientation.portrait ? 250 : 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.onboardingGreyLight,
                          ),
                          child: const Center(child: Text("Image Placeholder")),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        const Text(
                          "Shop Unique Creations",
                          style: AppTextStyles.onboardingHeading,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        const Text(
                          "Browse and purchase one-of-a-kind African pieces made by local artists and artisans.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.onboardingDescription,
                        ),
                        const Spacer(),

                        // Get Started Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.onboardingBrown,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Get Started",
                              style: AppTextStyles.onboardingButton,
                            ),
                          ),
                        ),

                        // Optional Skip Button
                        /*
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text("Skip", style: AppTextStyles.onboardingSkip),
                        ),
                        */
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
