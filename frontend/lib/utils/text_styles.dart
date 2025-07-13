import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Splash Screen Text Styles
  static const TextStyle splashLogo = TextStyle(
    color: AppColors.splashPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const TextStyle splashAppName = TextStyle(
    color: AppColors.splashWhite,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle splashTagline = TextStyle(
    color: AppColors.splashWhite70,
    fontSize: 16,
  );

  static const TextStyle splashButton = TextStyle(fontWeight: FontWeight.bold);

  // Onboarding Screen Text Styles
  static const TextStyle onboardingHeading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onboardingBrownDark,
  );

  static const TextStyle onboardingDescription = TextStyle(
    fontSize: 16,
    color: AppColors.onboardingTextSecondary,
  );

  static const TextStyle onboardingButton = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.white,
  );

  static const TextStyle onboardingSkip = TextStyle(
    color: AppColors.onboardingBrown,
    fontSize: 16,
  );

  // Login Screen Text Styles
  static const TextStyle loginTitle = onboardingHeading;

  static const TextStyle loginSubtitle = onboardingDescription;

  static const TextStyle loginButton = onboardingButton;

  static const TextStyle forgotPassword = TextStyle(
    color: AppColors.onboardingBrown,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle signUpLink = TextStyle(
    color: AppColors.onboardingBrown,
    fontWeight: FontWeight.bold,
  );

  static var appBarTitle;
}
