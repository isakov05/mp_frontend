import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

class PredictService {
  static const String baseUrl = "http://10.0.2.2:8000";
  static const storage = FlutterSecureStorage();

  // ===========================
  // 1️⃣ Predict Food
  // ===========================
  static Future<Map<String, dynamic>?> predictFood(File image) async {
    final uri = Uri.parse("$baseUrl/predict/");

    final token = await storage.read(key: "token");
    if (token == null) {
      print("❌ No token found. User not logged in.");
      return null;
    }

    final request = http.MultipartRequest("POST", uri)
      ..headers["Authorization"] = "Bearer $token"
      ..files.add(await http.MultipartFile.fromPath(
        "file",
        image.path,
        contentType: MediaType("image", "jpeg"),
      ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print("PREDICT RESPONSE: ${response.statusCode} → $responseBody");

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);

      return {
        "label": data["label"],
        "confidence": (data["confidence"] as num).toDouble(),
        "calories": (data["calories"] as num).toDouble(),
        "protein_g": (data["protein_g"] as num).toDouble(),
        "fat_g": (data["fat_g"] as num).toDouble(),
        "carbs_g": (data["carbs_g"] as num).toDouble(),
      };
    }

    return null;
  }

  // ===========================
  // 2️⃣ Auto Log Food
  // ===========================
  static Future<Map<String, dynamic>?> autoLogFood(
    File image, {
    int servings = 1,
  }) async {
    final token = await storage.read(key: "token");
    if (token == null) {
      print("❌ No token found.");
      return null;
    }

    final url = Uri.parse("$baseUrl/predict/auto-log");

    final request = http.MultipartRequest("POST", url)
      ..headers["Authorization"] = "Bearer $token"
      ..fields["servings"] = servings.toString()
      ..files.add(await http.MultipartFile.fromPath(
        "file",            // 🔥 MUST match backend
        image.path,
        contentType: MediaType("image", "jpeg"),
      ));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print("AUTO-LOG RESPONSE: ${response.statusCode} → $body");

    if (response.statusCode == 200) {
      return jsonDecode(body);
    }

    return null;
  }
}
