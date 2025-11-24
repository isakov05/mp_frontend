import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DashboardService {
  static const String baseUrl = "http://10.0.2.2:8000";
  static const storage = FlutterSecureStorage();

  // -------------------------------------------------
  // GET /dashboard/today  → summary + logs
  // -------------------------------------------------
  static Future<Map<String, dynamic>?> getToday() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/dashboard/today");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("TODAY RESPONSE: ${response.statusCode} → ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Normalize numerics
      data["total_calories"] =
          (data["total_calories"] as num?)?.toDouble() ?? 0.0;
      data["protein_g"] = (data["protein_g"] as num?)?.toDouble() ?? 0.0;
      data["fat_g"] = (data["fat_g"] as num?)?.toDouble() ?? 0.0;
      data["carbs_g"] = (data["carbs_g"] as num?)?.toDouble() ?? 0.0;

      if (data["logs"] != null) {
        data["logs"] = (data["logs"] as List).map((log) {
          log["calories"] = (log["calories"] as num?)?.toDouble() ?? 0.0;
          return log;
        }).toList();
      }

      return data;
    }
    return null;
  }

  // -------------------------------------------------
  // Optional: Summary
  // -------------------------------------------------
  static Future<Map<String, dynamic>?> getSummary() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final today = DateTime.now().toIso8601String().split("T")[0];
    final url = Uri.parse("$baseUrl/dashboard/summary?date=$today");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("SUMMARY RESPONSE: ${response.statusCode} → ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      data["total_calories"] =
          (data["total_calories"] as num?)?.toDouble() ?? 0.0;

      return data;
    }
    return null;
  }

  // -------------------------------------------------
  // GET /dashboard/chart → weekly calories
  // -------------------------------------------------
  static Future<List<dynamic>?> getWeekChart() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/dashboard/chart");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("CHART RESPONSE: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List chart = data["chart"] ?? [];

      // Normalize week chart numbers
      return chart.map((day) {
        day["total_calories"] =
            (day["total_calories"] as num?)?.toDouble() ?? 0.0;
        return day;
      }).toList();
    }
    return null;
  }
}
