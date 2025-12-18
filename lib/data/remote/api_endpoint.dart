class ApiEndpoint {
  static const String baseUrl = 'https://api-gateway.nhaxehaihong.top/';
  static const String login = '/api/auth/login';
  static const String googleLogin = '/api/auth/login-google';
  static const String register = '/api/auth/register';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendCode = '/api/auth/resend-verification-code';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/resend-password-code';
  static const String changePassword = '/api/auth/change-password';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String getCourses = '/api/courses/user';
  static const String getUnitsByCourseId = '/api/units/user';
  static const String getTheoriesByUnitId = '/api/theories/user';
  static const String getProfile = '/api/auth/profile';
  static const String getQuestions = '/api/questions/user';
  static const String patchProgress = '/api/progress';
  static const String getProgress = '/api/progress';
  static const String getCourseById = '/api/courses/';
  static const String getMistakes = '/api/mistakes';
  static const String addMistake = '/api/mistakes';
  static const String patchMistake = '/api/mistakes';
}
