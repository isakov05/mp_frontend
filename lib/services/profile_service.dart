import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  static const String baseUrl = "http://10.0.2.2:8000";
  static const storage = FlutterSecureStorage();

  // ---------------------------
  // GET /users/me
  // ---------------------------
  static Future<Map<String, dynamic>?> getProfile() async {
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

  // ---------------------------
  // PUT /users/me
  // ---------------------------
  static Future<bool> updateProfile(String? name) async {
    final token = await storage.read(key: "token");
    if (token == null) return false;

    final url = Uri.parse("$baseUrl/users/me");

    final body = jsonEncode({"name": name});

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: body,
    );

    return response.statusCode == 200;
  }

  // ---------------------------
  // PUT /users/me/password
  // ---------------------------
  static Future<String?> changePassword(
      String oldPass, String newPass) async {
    final token = await storage.read(key: "token");
    if (token == null) return "Not logged in";

    final url = Uri.parse("$baseUrl/users/me/password");

    final body = jsonEncode({
      "old_password": oldPass,
      "new_password": newPass,
    });

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return null; // success
    }

    return jsonDecode(response.body)["detail"];
  }
}
