import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000"; // Android emulator → localhost
  static const storage = FlutterSecureStorage();

  /// LOGIN
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "token", value: data["access_token"]);
      return data;
    } else {
      return null;
    }
  }

  /// REGISTER
  static Future<bool> register(
      String email, String password, String name) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "name": name,
      }),
    );

    return response.statusCode == 200;
  }

  /// GET CURRENT USER
  static Future<Map<String, dynamic>?> getMe() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/users/me");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
