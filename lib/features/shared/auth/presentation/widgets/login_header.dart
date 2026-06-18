import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final double height;

  const LoginHeader({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0256C2).withOpacity(0.85),
                    const Color(0xFF0F172A).withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
