import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController(text: "edyneoxzpp@gmail.com");
  final passwordController = TextEditingController(text: "mispadres12");
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void handleLogin(BuildContext context, bool isLoading) {
    if (isLoading) return;
    /*if (kDebugMode) {
      context.go('/patient');
      return;
    }*/
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: password),
    );
  }

  void handleGoogleLogin(BuildContext context, bool isLoading) {
    if (isLoading) return;
    context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
