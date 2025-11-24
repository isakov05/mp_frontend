import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatService {
  static const String baseUrl = "http://10.0.2.2:8000";
  static const storage = FlutterSecureStorage();

  // ---------------------------
  // SEND MESSAGE
  // ---------------------------
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    double? confidence,
    String? predictedLabel,
  }) async {
    final token = await storage.read(key: "token");

    if (token == null) {
      return {"reply": "You are not logged in.", "logged": false};
    }

    final url = Uri.parse("$baseUrl/ai/chat");

    final body = {
      "message": message,
      "confidence": confidence,
      "predicted_label": predictedLabel,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("CHAT SEND RESPONSE: ${response.statusCode} → ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {"reply": "Error contacting AI.", "logged": false};
  }

  // ---------------------------
  // LOAD CHAT HISTORY
  // ---------------------------
  static Future<List<Map<String, dynamic>>> loadHistory() async {
    final token = await storage.read(key: "token");
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/ai/history");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("CHAT HISTORY RESPONSE: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["history"]);
    }

    return [];
  }
}
