import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  static const String baseUrl = "http://10.0.2.2:8000";
  static const storage = FlutterSecureStorage();

  // GET /settings/me
  static Future<Map<String, dynamic>?> getSettings() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/settings/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // PUT /settings/me
  static Future<bool> updateSettings(Map<String, dynamic> updates) async {
    final token = await storage.read(key: "token");
    if (token == null) return false;

    final response = await http.put(
      Uri.parse("$baseUrl/settings/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(updates),
    );

    return response.statusCode == 200;
  }
}
