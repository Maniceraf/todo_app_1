import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.message,
    this.imagePath,
    this.icon,
    this.iconColor,
  }) : assert(
          imagePath != null || icon != null,
          'Either imagePath or icon must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (imagePath != null)
          Image(
            image: AssetImage(imagePath!),
            height: 100,
            width: 100,
          )
        else if (icon != null)
          Icon(
            icon,
            size: 100,
            color: iconColor ?? Colors.grey[400],
          ),
        const SizedBox(height: 20),
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
