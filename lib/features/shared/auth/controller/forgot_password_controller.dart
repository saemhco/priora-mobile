import 'package:flutter/material.dart';
import 'package:priora/features/shared/auth/data/auth_repository.dart';

class ForgotPasswordController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final emailController = TextEditingController();
  
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  ForgotPasswordController({required this._authRepository});

  Future<void> handleForgotPassword(BuildContext context) async {
    if (isLoading) return;

    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu correo electrónico'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un correo electrónico válido'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      isSuccess = true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
