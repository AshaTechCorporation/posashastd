class LoginResponse {
  final String? message;
  final String? accessToken;
  final String? refreshToken;

  LoginResponse({
    this.message,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
