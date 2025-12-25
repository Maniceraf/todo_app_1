import 'package:flutter/material.dart';

/// Centralized text styles for the app
/// Makes it easy to maintain consistent typography
class AppTextStyles {
  // Headings
  static const TextStyle largeTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle title = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontSize: 14,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    fontWeight: FontWeight.bold,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Small text
  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  // AppBar title
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  // Subtitle
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
  );
}
