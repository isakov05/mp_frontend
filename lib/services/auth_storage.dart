import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = "token";
  static const _goalCalKey = "goal_calories";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// SAVE GOAL
  static Future<void> saveGoal(int calories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalCalKey, calories);
  }

  /// GET GOAL
  static Future<int> getGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_goalCalKey) ?? 2000; // default fallback
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
