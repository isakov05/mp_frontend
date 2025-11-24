import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/dashboard_service.dart';
import '../services/settings_service.dart';

double dailyGoal = 0;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? today;
  List<dynamic>? weekChart;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final t = await DashboardService.getToday();
    final w = await DashboardService.getWeekChart();
    final settings = await SettingsService.getSettings();

    dailyGoal = (settings?["daily_calorie_goal"] as num?)?.toDouble() ?? 2000.0;

    setState(() {
      today = t;
      weekChart = w;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : today == null
              ? const Center(child: Text("Failed to load dashboard"))
              : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    final total = (today!["total_calories"] as num?)?.toDouble() ?? 0.0;
    final protein = (today!["protein_g"] as num?)?.toDouble() ?? 0.0;
    final fat = (today!["fat_g"] as num?)?.toDouble() ?? 0.0;
    final carbs = (today!["carbs_g"] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _todaySummary(total, protein, fat, carbs),

          const SizedBox(height: 20),

          // 🎯 Daily Goal Progress Bar
          _dailyGoalProgress(total),

          const SizedBox(height: 20),

          _sectionTitle("Today's Meals"),
          _todayMeals(),

          const SizedBox(height: 20),

          _sectionTitle("Weekly Calories"),
          const SizedBox(height: 10),
          _weekChart(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          height: 2,
          width: 40,
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  // 🔥 Daily Goal Progress UI
  Widget _dailyGoalProgress(double totalCalories) {
    if (dailyGoal == 0) return const SizedBox.shrink();

    final progress = (totalCalories / dailyGoal).clamp(0, 1);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daily Goal: ${dailyGoal.toStringAsFixed(0)} kcal",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress.toDouble(),
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Text(
              "${totalCalories.toStringAsFixed(0)} / ${dailyGoal.toStringAsFixed(0)} kcal",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _todaySummary(
    double total,
    double protein,
    double fat,
    double carbs,
  ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _summaryRow("Calories", "${total.toStringAsFixed(0)} kcal",
                Icons.local_fire_department),
            _summaryRow("Protein", "${protein.toStringAsFixed(1)} g",
                Icons.fitness_center),
            _summaryRow("Fat", "${fat.toStringAsFixed(1)} g", Icons.opacity),
            _summaryRow("Carbs", "${carbs.toStringAsFixed(1)} g",
                Icons.bubble_chart),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayMeals() {
    final meals = today!["logs"] as List? ?? [];

    if (meals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          "No meals logged today",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: meals.map((food) {
        final calories = (food["calories"] as num?)?.toDouble() ?? 0.0;

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.restaurant, color: Colors.blue),
            ),
            title: Text(food["food_name"] ?? "Unknown"),
            subtitle: Text("${calories.toStringAsFixed(0)} kcal"),
          ),
        );
      }).toList(),
    );
  }

  Widget _weekChart() {
    if (weekChart == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Calories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= weekChart!.length) return const SizedBox();

                          final dayName = weekChart![index]["day"];
                          if (dayName == null || dayName.toString().isEmpty) {
                            return const Text("Day", style: TextStyle(fontSize: 12));
                          }

                          return Text(
                            dayName.substring(0, 3),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 200,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    weekChart!.length,
                    (i) {
                      final value =
                          (weekChart![i]["total_calories"] as num).toDouble();
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            width: 14,
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.blueAccent,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
