import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

class LookupScreen extends StatefulWidget {
  const LookupScreen({super.key});

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final ctrl = TextEditingController();
  final api = ApiService();

  bool loading = false;
  Map<String, dynamic>? result;

  void searchFood() async {
    final query = ctrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      loading = true;
      result = null;
    });

    try {
      final response = await api.usdaSearch(query);

      setState(() {
        result = response.data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        result = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No results found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lookup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: "Search food",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onSubmitted: (_) => searchFood(),
            ),

            const SizedBox(height: 20),

            // ⏳ Loading Indicator
            if (loading)
              const Center(child: CircularProgressIndicator()),

            // 📦 Display 1 Result
            if (!loading && result != null)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result!["food_name"],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "${result!["calories_per_100g"]} kcal per 100g",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 20),

                      FilledButton(
                        onPressed: () async {
                          final token = await AuthStorage.getToken();
                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Login required")),
                            );
                            return;
                          }

                          try {
                            await api.addUsdaLog(
                              token,
                              result!["food_name"],
                              result!["calories_per_100g"],   // <-- correct field
                              result!["protein_g"],
                              result!["fat_g"],
                              result!["carbs_g"],
                              servings: 1,
                            );


                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Added to log ✔")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to log food: $e")),
                            );
                          }
                        },
                        child: const Text("Add to Log"),
                      ),
                    ],
                  ),
                ),
              ),

            // 📭 No results state
            if (!loading && result == null)
              const Center(
                child: Text(
                  "Search a food name to begin",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
