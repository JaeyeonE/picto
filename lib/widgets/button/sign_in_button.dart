// lib/widgets/button/sign_in_button.dart
import 'package:flutter/material.dart';

class SigninButton extends StatefulWidget {
  final String iconPath;
  final VoidCallback onPressed;
  final double size;

  const SigninButton({
    super.key, 
    required this.iconPath,
    required this.onPressed,
    this.size = 280.0,  // 기본 버튼 너비
  });

  @override
  State<SigninButton> createState() => _SigninButtonState();
}

class _SigninButtonState extends State<SigninButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.98,
      upperBound: 1.0,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.reverse();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.forward();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.forward();
      },
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          width: widget.size,
          height: 48, // 높이는 고정
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isPressed ? [] : [

            ],
          ),
          child: Image.asset(
            widget.iconPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}