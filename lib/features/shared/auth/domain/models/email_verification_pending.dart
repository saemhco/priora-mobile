/// Response of POST /auth/register and POST /auth/resend-verification.
///
/// The account exists but the email still needs OTP confirmation. No tokens
/// are issued until POST /auth/verify-email succeeds.
class EmailVerificationPending {
  const EmailVerificationPending({
    required this.requiresEmailVerification,
    required this.email,
    required this.sent,
    required this.retryAfterSeconds,
    required this.remainingToday,
  });

  factory EmailVerificationPending.fromJson(Map<String, dynamic> json) {
    return EmailVerificationPending(
      requiresEmailVerification: json['requiresEmailVerification'] == true,
      email: json['email']?.toString() ?? '',
      sent: json['sent'] == true,
      retryAfterSeconds: (json['retryAfterSeconds'] as num?)?.toInt() ?? 0,
      remainingToday: (json['remainingToday'] as num?)?.toInt() ?? 0,
    );
  }

  final bool requiresEmailVerification;
  final String email;
  final bool sent;
  final int retryAfterSeconds;
  final int remainingToday;
}
