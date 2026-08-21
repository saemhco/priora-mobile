import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_event.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

/// Screen where the user enters the 6-digit OTP sent to their email.
///
/// Reached after registering (the account is created but no tokens are
/// issued until the email is verified) or after logging in with an unverified
/// email (403 EMAIL_NOT_VERIFIED).
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({required this.email, super.key});

  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    final retryAfterSeconds = state is AuthEmailVerificationRequired
        ? state.retryAfterSeconds
        : 600;
    _startCountdown(retryAfterSeconds);
  }

  void _startCountdown(int seconds) {
    _resendTimer?.cancel();
    _secondsLeft = seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), _onResendTick);
  }

  void _onResendTick(Timer timer) {
    if (_secondsLeft <= 1) {
      timer.cancel();
      if (mounted) {
        setState(() => _secondsLeft = 0);
      }
    } else if (mounted) {
      setState(() => _secondsLeft--);
    }
  }

  String _formatCountdown(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  void _handleVerify() {
    final code = _codeController.text.trim();
    if (code.length != 6) return;
    context.read<AuthBloc>().add(
      AuthVerifyEmailRequested(email: widget.email, code: code),
    );
  }

  void _onCodeSubmitted(String _) {
    if (_codeController.text.trim().length == 6 &&
        context.read<AuthBloc>().state is! AuthLoading) {
      _handleVerify();
    }
  }

  void _handleResend() {
    context.read<AuthBloc>().add(
      AuthResendVerificationRequested(email: widget.email),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is AuthEmailVerificationRequired &&
        state.retryAfterSeconds > 0) {
      // Resend cooldown updated by the backend.
      _startCountdown(state.retryAfterSeconds);
    } else if (state is AuthAuthenticated) {
      if (!state.profileComplete) {
        context.go('/complete-profile');
      } else if (state.role == 'doctor' || state.role == 'professional') {
        context.go('/doctor');
      } else {
        context.go('/patient');
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleAuthState,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final canResend = _secondsLeft == 0 && !isLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.go('/login'),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_rounded,
                        color: Color(0xFF0256C2),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Verifica tu correo',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Te enviamos un código de 6 dígitos a\n${widget.email}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: 14,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '······',
                        hintStyle: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFCBD5E1),
                          letterSpacing: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF0256C2),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onSubmitted: _onCodeSubmitted,
                    ),
                    const SizedBox(height: 16),

                    ListenableBuilder(
                      listenable: _codeController,
                      builder: (context, child) {
                        final canVerify =
                            _codeController.text.trim().length == 6 &&
                            !isLoading;

                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: canVerify ? _handleVerify : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0256C2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFFBFDBFE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Verificar código'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: canResend
                          ? TextButton(
                              onPressed: _handleResend,
                              child: const Text(
                                'Reenviar código',
                                style: TextStyle(
                                  color: Color(0xFF0256C2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Text(
                              'Reenviar código en ${_formatCountdown(_secondsLeft)}',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Revisa también tu carpeta de spam.\nEl código caduca en 10 minutos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
