// lib/widgets/common/sign_in_header.dart
import 'package:flutter/material.dart';
import 'package:picto/utils/app_color.dart';

class SigninHeader extends StatelessWidget {
  const SigninHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'lib/assets/sign_in/picto_logo.png',
              width: 80,
              height: 80,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF8F9BB3),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'PICTO',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.myMarker,
          ),
        ),
      ],
    );
  }
}