import 'package:diet_plan_app/Widgets/daily_tracking.dart';
import 'package:flutter/material.dart';
import 'package:diet_plan_app/Widgets/weekly_tracking.dart';

class Progress extends StatefulWidget {
  const Progress({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  @override
  Widget build(BuildContext context) {
    double cal = widget.calories;
    // ignore: unused_local_variable
    double pr = widget.protein;
    // ignore: unused_local_variable
    double carb = widget.carbs;
    // ignore: unused_local_variable
    double fats = widget.fat;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Horizontal bar with date navigation
            const SizedBox(height: 10),

            const SizedBox(height: 10),

            DailyTracking(),

            const SizedBox(height: 10),

            WeeklyTrackingBarChart(goalCalories: cal),
          ],
        ),
      ),
    );
  }
}
