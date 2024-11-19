// lib/views/sign_in/sign_in.dart
import 'package:flutter/material.dart';
import 'package:picto/widgets/button/sign_in_buttons.dart';

import '../../widgets/common/sign_in_header.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SigninHeader(),
              SizedBox(height: 60),
              SigninButtons(),
            ],
          ),
        ),
      ),
    );
  }
}