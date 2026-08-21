/// Thrown when the API returns 403 EMAIL_NOT_VERIFIED on login.
///
/// Carries the email that needs verification and the cooldown (seconds)
/// before another OTP can be requested, so the UI can route the user to the
/// verification screen.
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException({
    required this.email,
    this.retryAfterSeconds = 600,
  });

  final String email;
  final int retryAfterSeconds;
}
