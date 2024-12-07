import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';

class LocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const LocationButton({
    super.key,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: FloatingActionButton(
        backgroundColor: backgroundColor ?? AppColors.primary,
        child: const Icon(Icons.my_location),
        onPressed: onPressed,
      ),
    );
  }
}