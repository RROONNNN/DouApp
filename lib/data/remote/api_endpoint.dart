class ApiEndpoint {
  static const String baseUrl = 'http://localhost:3000/';
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendCode = '/api/auth/resend-verification-code';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/resend-password-code';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
}
