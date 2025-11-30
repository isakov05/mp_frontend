import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  Map<String, dynamic>? result;
  bool loading = true;
  late String imagePath;

  final api = ApiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imagePath = ModalRoute.of(context)!.settings.arguments as String;
    sendPrediction();
  }

  Future<void> sendPrediction() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Not logged in")));
      return;
    }

    try {
      final response = await api.predict(imagePath, token);
      result = response.data;

      double conf = result!["confidence"] ?? 0.0;
      bool low = result!["low_confidence"] ?? false;

      // AUTO-LOG if confidence >= 0.60
      if (!low) {
        try {
          await api.autoLog(imagePath, 1, token);
          result!["auto_logged"] = true;
        } catch (e) {
          print("Auto-log failed: $e");
        }
      }

      setState(() => loading = false);

    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prediction failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prediction")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : result == null
              ? const Center(child: Text("Error"))
              : buildResult(),
    );
  }

  Widget buildResult() {
    final img = File(imagePath);

    final food = result!["label"];
    final double conf = result!["confidence"] ?? 0.0;
    final bool autoLogged = result!["auto_logged"] == true;
    final bool lowConfidence = result!["low_confidence"] ?? false;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(img, height: 260, fit: BoxFit.cover),
          ),

          const SizedBox(height: 20),

          Text(
            food,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text("Confidence: ${(conf * 100).toStringAsFixed(1)}%"),

          const SizedBox(height: 20),

          if (autoLogged)
            const Text(
              "Automatically added to your log ✔",
              style: TextStyle(color: Colors.green, fontSize: 16),
            )
          else if (lowConfidence)
            Column(
              children: [
                const Text(
                  "Low confidence. Please confirm the food.",
                  style: TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, "/lookup"),
                  child: const Text("Search USDA"),
                ),
              ],
            )
          else
            const Text(
              "Added to log.",
              style: TextStyle(color: Colors.green),
            ),
        ],
      ),
    );
  }
}
