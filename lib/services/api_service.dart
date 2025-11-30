import 'package:dio/dio.dart';
import '../config/api.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: Api.baseUrl));

  /// LOGIN
  Future<Response> login(String email, String password) {
    return _dio.post("/auth/login",
        data: {"email": email, "password": password});
  }

  /// REGISTER
  Future<Response> register(String name, String email, String password) {
    return _dio.post(
      "/auth/register",
      options: Options(
        headers: {"Content-Type": "application/json"},
      ),
      data: {
        "email": email.trim(),
        "password": password.trim(),
        "name": name.trim(),
      },
    );
  }


  /// GET USER PROFILE
  Future<Response> getProfile(String token) {
    return _dio.get(
      "/users/me",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// UPDATE NAME ONLY
  Future<Response> updateName(String token, String name) {
    return _dio.put(
      "/users/me",
      data: {"name": name},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// UPDATE PASSWORD
  Future<Response> updatePassword(
      String token, String oldPass, String newPass) {
    return _dio.put(
      "/users/me/password",
      data: {
        "old_password": oldPass,
        "new_password": newPass,
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// GET DAILY GOALS
  Future<Response> getSettings(String token) {
    return _dio.get(
      "/settings/me",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// UPDATE DAILY GOALS
  Future<Response> updateGoals(
    String token,
    int calories,
    int protein,
    int fat,
    int carbs,
  ) {
    return _dio.put(
      "/settings/me",
      data: {
        "daily_calorie_goal": calories,
        "daily_protein_goal": protein,
        "daily_fat_goal": fat,
        "daily_carbs_goal": carbs,
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// USDA SEARCH
  Future<Response> usdaSearch(String query) {
    return _dio.get(
      "/api/usda/search",
      queryParameters: {"query": query},
    );
  }

  /// LOG USDA FOOD
  Future<Response> addUsdaLog(
    String token,
    String foodName,
    double cal,
    double protein,
    double fat,
    double carbs, {
    int servings = 1,
  }) {
    return _dio.post(
      "/dashboard/log-usda",
      data: {
        "food_name": foodName,
        "calories": cal,
        "protein_g": protein,
        "fat_g": fat,
        "carbs_g": carbs,
        "servings": servings,
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// PREDICT
  Future<Response> predict(String filePath, String token) async {
    final form = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
    });

    return _dio.post(
      "/predict/",
      data: form,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// AUTO LOG
  Future<Response> autoLog(String filePath, int servings, String token) async {
    final form = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
      "servings": servings,
    });

    return _dio.post(
      "/predict/auto-log",
      data: form,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// HISTORY
  Future<Response> getHistory(String token) {
    return _dio.get(
      "/dashboard/history",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// TODAY
  Future<Response> getToday(String token) {
    return _dio.get(
      "/dashboard/today",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}
