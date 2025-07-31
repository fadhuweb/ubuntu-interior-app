import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                        // Image Section
                        Container(
                          height: MediaQuery.of(context).orientation == Orientation.portrait ? 250 : 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1505421031134-e57263cae630?q=80&w=1145&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.onboardingGreyLight,
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.15), // Optional overlay
                                ),
                              ],
                            ),
                          ),
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
                        const Spacer(),

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
              ),
            );
          },
        ),
      ),
    );
  }
}
