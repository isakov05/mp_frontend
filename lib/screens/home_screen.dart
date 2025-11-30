import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../widgets/section_card.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/macro_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();

  bool loading = true;

  int dailyGoal = 2000;

  double totalCalories = 0;
  double protein = 0;
  double fat = 0;
  double carbs = 0;

  double proteinGoal = 0;
  double fatGoal = 0;
  double carbsGoal = 0;

  List logs = [];

  @override
  void initState() {
    super.initState();
    loadDailyGoal();
    loadDashboard();
  }

  Future<void> loadDailyGoal() async {
    dailyGoal = await AuthStorage.getGoal();
    setState(() {});
  }

  Future<void> loadDashboard() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final settingsRes = await api.getSettings(token);

      dailyGoal = settingsRes.data["daily_calorie_goal"] ?? dailyGoal;
      proteinGoal = (settingsRes.data["daily_protein_goal"] as num).toDouble();
      fatGoal = (settingsRes.data["daily_fat_goal"] as num).toDouble();
      carbsGoal = (settingsRes.data["daily_carbs_goal"] as num).toDouble();

      await AuthStorage.saveGoal(dailyGoal);

      final todayRes = await api.getToday(token);

      setState(() {
        totalCalories = (todayRes.data["total_calories"] as num).toDouble();
        protein = (todayRes.data["protein_g"] as num).toDouble();
        fat = (todayRes.data["fat_g"] as num).toDouble();
        carbs = (todayRes.data["carbs_g"] as num).toDouble();
        logs = todayRes.data["logs"];
        loading = false;
      });

    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load dashboard: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: scheme.surface,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [

                  // ==========================
                  // Main Calorie Ring
                  // ==========================
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                )
                              ],
                      ),
                      child: CalorieRing(
                        progress: (totalCalories / dailyGoal).clamp(0.0, 1.0),
                        calories: totalCalories,
                        goal: dailyGoal,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================
                  // Macro Section
                  // ==========================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                              )
                            ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MacroRing(
                          progress: proteinGoal > 0 ? protein / proteinGoal : 0,
                          amount: protein,
                          goal: proteinGoal,
                          label: "Protein",
                          color: Colors.orangeAccent,
                        ),
                        MacroRing(
                          progress: fatGoal > 0 ? fat / fatGoal : 0,
                          amount: fat,
                          goal: fatGoal,
                          label: "Fat",
                          color: Colors.pinkAccent,
                        ),
                        MacroRing(
                          progress: carbsGoal > 0 ? carbs / carbsGoal : 0,
                          amount: carbs,
                          goal: carbsGoal,
                          label: "Carbs",
                          color: Colors.lightBlueAccent,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Today's Foods",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (logs.isEmpty)
                    Text(
                      "No foods logged yet",
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),

                  for (var log in logs) _foodCard(context, log),
                ],
              ),
            ),
    );
  }

  // ==========================
  // Food Log Card
  // ==========================
  Widget _foodCard(BuildContext context, Map log) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final created = DateTime.parse(log["created_at"]);
    final time = "${created.hour}:${created.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
            child: log["image_url"] != null
                ? Image.network(
                    "http://10.0.2.2:8000${log["image_url"]}",
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 90,
                    height: 90,
                    color: scheme.surfaceVariant,
                    child: Icon(Icons.fastfood,
                        size: 40, color: scheme.onSurfaceVariant),
                  ),
          ),

          // CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log["food_name"],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${log["calories"]} kcal",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "$time • P:${log["protein_g"]}g  F:${log["fat_g"]}g  C:${log["carbs_g"]}g",
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
