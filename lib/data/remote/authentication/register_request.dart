class RegisterRequest {
  final String password;
  final String email;
  final String fullName;
  String? avatarImage;

  RegisterRequest({
    required this.password,
    required this.email,
    required this.fullName,
    this.avatarImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'email': email,
      'fullName': fullName,
      'avatarImage': avatarImage,
    };
  }
}
