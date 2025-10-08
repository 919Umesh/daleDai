class AuthModel {
  final String userId;
  final String email;
  final bool error;
  final String? message;
  final String? code;

  AuthModel({
    required this.userId,
    required this.email,
    required this.error,
    this.message,
    this.code,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      error: json['error'] ?? true,
      message: json['message'],
      code: json['code'],
    );
  }
}