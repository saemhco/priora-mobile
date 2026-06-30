import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/controller/forgot_password_controller.dart';

class ForgotPasswordForm extends StatelessWidget {
  final ForgotPasswordController controller;

  const ForgotPasswordForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: controller.isSuccess
                ? _buildSuccessView(context, theme)
                : _buildFormView(context, theme),
          ),
        );
      },
    );
  }

  Widget _buildFormView(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome/Instruction Text
        Text(
          'Recuperar contraseña',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tu correo registrado para enviarte las instrucciones de restablecimiento.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),

        // Email Field
        const Text(
          'Correo electrónico',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !controller.isLoading,
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: Color(0xFF64748B),
              ),
              hintText: 'ejemplo@correo.com',
              hintStyle: TextStyle(color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading
                ? null
                : () => controller.handleForgotPassword(context),
            child: controller.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Enviar instrucciones'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // Back to Login Link
        Center(
          child: GestureDetector(
            onTap: controller.isLoading ? null : () => context.go('/login'),
            child: const Text(
              'Volver al Iniciar Sesión',
              style: TextStyle(
                color: Color(0xFF0256C2),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF16A34A),
            size: 56,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '¡Correo enviado!',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Hemos enviado un enlace a ${controller.emailController.text.trim()} para restablecer tu contraseña. Revisa tu bandeja de entrada o spam.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0256C2),
            ),
            child: const Text('Ir al Iniciar Sesión'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
