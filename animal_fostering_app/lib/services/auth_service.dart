import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_response.dart'; 

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static String? _token;
  static User? _currentUser;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
    }
  }

  static String? get token => _token;
  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _token != null && _currentUser != null;
  static bool get isAdmin => _currentUser?.isAdmin == true;

  static Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(LoginRequest(email: email, password: password).toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      await _saveAuthData(authResponse);
      return authResponse;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      ).toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      await _saveAuthData(authResponse);
      return authResponse;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

    static Future<String> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Return token for next steps
    } else {
      throw Exception('Failed to send reset code');
    }
  }

  static Future<String> verifyResetCode(String token, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-reset-code'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'token': token,
        'resetCode': code,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Return verified token
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Invalid reset code');
    }
  }

  static Future<void> resetPassword(String token, String newPassword, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to reset password');
    }
  }

  static Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: authHeaders,
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to change password');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
    _token = null;
    _currentUser = null;
  }

  static Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', authResponse.token);
    await prefs.setString('current_user', json.encode(authResponse.user.toJson()));
    _token = authResponse.token;
    _currentUser = authResponse.user;
  }

  static Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}