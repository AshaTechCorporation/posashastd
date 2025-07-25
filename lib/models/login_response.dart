class LoginResponse {
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final String? name;

  LoginResponse({this.message, this.accessToken, this.refreshToken, this.name});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(message: json['message'] ?? '', accessToken: json['accessToken'], refreshToken: json['refreshToken'], name: json['name']);
  }
}
