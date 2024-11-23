// lib/widgets/button/sign_in_buttons.dart
import 'package:flutter/material.dart';
import 'sign_in_button.dart';

class SigninButtons extends StatelessWidget {
  const SigninButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth - 48.0; // 좌우 패딩 고려

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SigninButton(
          iconPath: 'lib/assets/sign_in/google_sign_in.png',
          onPressed: () {
            // TODO: Implement Google login
          },
          size: buttonWidth,
        ),
        const SizedBox(height: 16),
        SigninButton(
          iconPath: 'lib/assets/sign_in/naver_sign_in.png',
          onPressed: () {
            // TODO: Implement Naver login
          },
          size: buttonWidth,
        ),
        const SizedBox(height: 16),
        SigninButton(
          iconPath: 'lib/assets/sign_in/kakao_sign_in.png',
          onPressed: () {
            // TODO: Implement Kakao login
          },
          size: buttonWidth,
        ),
      ],
    );
  }
}