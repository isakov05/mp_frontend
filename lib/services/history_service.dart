import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HistoryService {
  static const String baseUrl = "http://10.0.2.2:8000";
  static const storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>?> getHistory() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/dashboard/history");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);   // returns Map { history: [...] }
    } else {
      print("History error: ${response.statusCode} → ${response.body}");
      return null;
    }
  }
}
