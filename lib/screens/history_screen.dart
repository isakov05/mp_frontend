import 'package:flutter/material.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic>? history;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await HistoryService.getHistory();

    if (!mounted) return;

    setState(() {
      if (data != null && data["history"] != null) {
        history = data["history"];
      } else {
        history = [];
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history!.isEmpty
              ? const Center(child: Text("No logged meals yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history!.length,
                  itemBuilder: (context, index) {
                    final item = history![index];

                    return _HistoryCard(item: item);
                  },
                ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map item;

  const _HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final createdAt = item["created_at"] ?? "";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          item["food_name"] ?? "Unknown Food",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _chip(Icons.local_fire_department, "${item["calories"]} kcal"),
              const SizedBox(width: 8),
              _chip(Icons.fitness_center, "${item["protein_g"]}g P"),
              const SizedBox(width: 8),
              _chip(Icons.water_drop, "${item["fat_g"]}g F"),
              const SizedBox(width: 8),
              _chip(Icons.breakfast_dining, "${item["carbs_g"]}g C"),
            ],
          ),
        ),
        trailing: Text(
          createdAt.length >= 16 ? createdAt.substring(11, 16) : "",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
