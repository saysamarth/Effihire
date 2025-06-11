import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const kAppWhite = Colors.white;
  static const kAppBlack = Colors.black;

  // Primary and Secondary Colors
  static const kPrimaryColor = Color(
    0xFF6200EE,
  ); // Example: Green (Adjust to your theme)
  static const kSecondaryColor = Color(
    0xFF03A9F4,
  ); // Example: Blue (Adjust to your theme)

  // Text Colors
  static const kTextPrimary = Color(0xFF212121); // Dark primary text
  static const kTextSecondary = Color(0xFF757575); // Light secondary text
  static const kTextTertiary = Color.fromARGB(255, 168, 175, 255);
  static const kTextLight = Color.fromARGB(255, 55, 55, 69);

  // Background Colors
  static const kBackgroundColor = Color(0xFFF5F5F5); // Light background color

  // Button Colors
  static const kButtonColor = Color(0xFF00B0FF); // Button background color
  static const kButtonTextColor = Colors.white; // Button text color

  // Error Colors
  static const kErrorColor = Color(0xFFD32F2F); // Error color (Red)
  static const kErrorTextColor = Colors.white; // Error text color

  // Success Colors
  static const kSuccessColor = Color(0xFF4CAF50); // Success color (Green)
  static const kSuccessTextColor = Colors.white; // Success text color

  // Custom Gray Colors
  static const kAppLightGrey = Color(
    0xFFF0F0F0,
  ); // Light gray color for loading state
  static const kAppRed = Color(
    0xFFD32F2F,
  ); // Red color for error (used in image error widget)
  static const kAppDarkGrey = Color(
    0xFF616161,
  ); // Dark gray color for other widgets
  static const kNavBarSelected = kPrimaryColor;
  static const klightpurple = Color(0xFF252432);
  static const kNavBarUnselected = Color(0xFF757575);

  static const Color kLightOptionBg = Color(0xFFF0F0F0); // Light gray
  static const Color kLightOptionIcon = Color(0xFF6200EE); // Purple
  static const Color kDarkOptionBg = Color.fromARGB(166, 43, 10, 82); // Dark purple
  static const Color kDarkOptionIcon = Color(0xFF6B6FAF); // Muted purple
  static const Color kDarkIconBg = Color(0xFF2A2A3E);
  static const Color kLightIconBg = Color(0xFFF0F0F0);
  // Light Mode Colors
  static const Color kSearchBgLight = Color(0xFFF5F5F5);
  static const Color kSearchBorderLight = Color(0xFFE0E0E0);
  static const Color kTextSecondaryLight = Color(0xFF757575);

  // Dark Mode Colors
  static const Color kSearchBgDark = Color(0xFF2A2A3E);
  static const Color kSearchBorderDark = Color(0xFF3E3E5E);
  static const Color kTextSecondaryDark = Color(0xFF9E9E9E);

  static const Color kCardLight = Color(
    0xFFFFFFFF,
  ); // White for light mode cards
  static const Color kCardDark = Color(
    0xFF2A2A3E,
  ); // Dark purple for dark mode cards
  static const Color kDarkBackground = Color(
    0xFF1A1A2E,
  ); // Darker purple for dark mode background

  static const Color kPrimary = Color(0xFF675AF0);
}
