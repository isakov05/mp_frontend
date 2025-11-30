import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final api = ApiService();
  bool loading = true;
  List logs = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final response = await api.getHistory(token);

      setState(() {
        logs = response.data["history"];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load history: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const Center(
                  child: Text("No logs yet",
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final log = logs[i];

                    final date = DateTime.parse(log["created_at"]);
                    final formatted =
                        "${date.year}-${date.month}-${date.day}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    final imageUrl = log["image_url"];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // FOOD IMAGE (if available)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl != null
                                  ? Image.network(
                                      "http://10.0.2.2:8000$imageUrl",
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.fastfood),
                                    ),
                            ),

                            const SizedBox(width: 16),

                            // FOOD DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log["food_name"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text("$formatted",
                                      style:
                                          TextStyle(color: Colors.grey[700])),

                                  const SizedBox(height: 8),

                                  Text("Calories: ${log["calories"]} kcal"),
                                  Text("Protein: ${log["protein_g"]} g"),
                                  Text("Fat: ${log["fat_g"]} g"),
                                  Text("Carbs: ${log["carbs_g"]} g"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
