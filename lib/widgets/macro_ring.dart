import 'package:flutter/material.dart';

class MacroRing extends StatelessWidget {
  final double progress; // value 0.0 - 1.0
  final double amount;   // grams
  final double goal;     // daily macro goal
  final String label;
  final Color color;

  const MacroRing({
    super.key,
    required this.progress,
    required this.amount,
    required this.goal,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle (grey)
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Colors.grey),
            ),
          ),

          // Colored progress ring
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),

          // Text inside the ring
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${amount.toStringAsFixed(0)}g",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
