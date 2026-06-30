import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/controller/register_controller.dart';
import 'package:priora/features/shared/auth/presentation/widgets/google_button.dart';

class RegisterForm extends StatelessWidget {
  final RegisterController controller;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: Color(0xFF64748B),
                  ),
                  hintText: 'nombre@ejemplo.com',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Password Field
            const Text(
              'Contraseña',
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
              child: TextFormField(
                controller: controller.passwordController,
                obscureText: controller.obscurePassword,
                enabled: !isLoading,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF64748B),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: isLoading
                        ? null
                        : controller.togglePasswordVisibility,
                  ),
                  hintText: 'Mínimo 8 caracteres',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Password Field
            const Text(
              'Confirmar contraseña',
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
              child: TextFormField(
                controller: controller.confirmPasswordController,
                obscureText: controller.obscureConfirmPassword,
                enabled: !isLoading,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFF64748B),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: isLoading
                        ? null
                        : controller.toggleConfirmPasswordVisibility,
                  ),
                  hintText: 'Repite tu contraseña',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Create Account Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => controller.handleRegister(context, isLoading),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0256C2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider "o regístrate con"
            const Row(
              children: [
                Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'o regístrate con',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              ],
            ),
            const SizedBox(height: 24),

            // Google Register Button
            GoogleButton(
              onTap: () => isLoading
                  ? null
                  : () => controller.handleGoogleRegister(context, isLoading),
              text: 'Continuar con Google',
            ),
            const SizedBox(height: 24),

            // Already have an account?
            Center(
              child: GestureDetector(
                onTap: isLoading ? null : () => context.go('/login'),
                child: RichText(
                  key: const ValueKey('goto_login_button'),
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    children: [
                      TextSpan(text: '¿Ya tengo cuenta? '),
                      TextSpan(
                        text: 'Iniciar sesión',
                        style: TextStyle(
                          color: Color(0xFF0256C2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Consent Footer
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Al registrarte, aceptas nuestros Términos de Servicio y Política de Privacidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
