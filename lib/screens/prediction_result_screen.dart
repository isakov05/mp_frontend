import 'dart:io';
import 'package:flutter/material.dart';
import '../services/predict_service.dart';

class PredictionResultScreen extends StatefulWidget {
  final String label;
  final double confidence;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final File image;

  const PredictionResultScreen({
    super.key,
    required this.label,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.image,
  });

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen> {
  int servings = 1;
  bool loading = false;

  bool get isLowConfidence => widget.confidence < 0.60;

  Future<void> _addToLog() async {
    setState(() => loading = true);

    final result =
        await PredictService.autoLogFood(widget.image, servings: servings);

    setState(() => loading = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food logged successfully!")),
      );
      Navigator.pop(context); // Back to camera/home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to log food.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Result"),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// IMAGE PREVIEW
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    widget.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 16),

                /// LABEL
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                /// CONFIDENCE
                Text(
                  "Confidence: ${(widget.confidence * 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isLowConfidence ? Colors.red : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (isLowConfidence) const SizedBox(height: 14),

                /// LOW CONFIDENCE WARNING
                if (isLowConfidence)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "⚠️ Low confidence.\nAsk AI to confirm or log manually.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                /// NUTRITION CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Nutrition (per serving)",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _NutritionItem(
                              label: "Calories",
                              value: "${widget.calories.toInt()} kcal"),
                          _NutritionItem(
                              label: "Protein",
                              value: "${widget.protein} g"),
                          _NutritionItem(
                              label: "Fat", value: "${widget.fat} g"),
                          _NutritionItem(
                              label: "Carbs", value: "${widget.carbs} g"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// SERVINGS PICKER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: servings > 1
                          ? () => setState(() => servings--)
                          : null,
                      icon: const Icon(Icons.remove_circle,
                          color: Colors.green),
                    ),
                    Text(
                      "$servings serving${servings > 1 ? "s" : ""}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => servings++),
                      icon: const Icon(Icons.add_circle,
                          color: Colors.green),
                    ),
                  ],
                ),

                const Spacer(),

                /// ADD TO LOG BUTTON (ALWAYS VISIBLE)
                ElevatedButton.icon(
                  onPressed: _addToLog,
                  icon: const Icon(Icons.check),
                  label: const Text("Add to Log"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 12),

                /// ASK AI TO CONFIRM (ONLY IF LOW CONFIDENCE)
                if (isLowConfidence)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/chat",
                        arguments: {
                          "predicted_label": widget.label,
                          "confidence": widget.confidence,
                          "initialMessage":
                              "I think this is ${widget.label} but confidence is ${(widget.confidence * 100).toStringAsFixed(1)}%. Can you confirm?",
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text("Ask AI to Confirm"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),

          /// LOADING OVERLAY
          if (loading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            )),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}
