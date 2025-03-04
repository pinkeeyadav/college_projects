// ignore: unused_import
import 'package:diet_plan_app/Widgets/nutritioncard.dart';
import 'package:diet_plan_app/screens/nutrition_display.dart';
import 'package:flutter/material.dart';

class WeightTargetScreen extends StatelessWidget {
  const WeightTargetScreen({
    super.key,
    required this.message,
    required this.calorie,
  });

  final String message; // 'weight loss' or 'weight gain'
  final double calorie; // User's current daily maintenance calories

  // Function to calculate daily calorie intake based on weight target
  double _calculateCalories(double selectedWeight) {
    if (message == 'weight loss') {
      // Different calculations for 0.5 kg and 1 kg
      if (selectedWeight == 0.5) {
        return calorie -
            500; // 0.5 kg weight loss requires 500 kcal deficit per day
      } else if (selectedWeight == 1.0) {
        return calorie -
            1000; // 1 kg weight loss requires 1000 kcal deficit per day
      }
    } else {
      // Weight gain requires calorie surplus
      if (selectedWeight == 0.5) {
        return calorie +
            500; // 0.5 kg weight gain requires 500 kcal surplus per day
      } else if (selectedWeight == 1.0) {
        return calorie +
            1000; // 1 kg weight gain requires 1000 kcal surplus per day
      }
    }
    return calorie; // Default if something goes wrong
  }

  void _handleWeightSelection(BuildContext context, double selectedWeight) {
    double calculatedCalories = _calculateCalories(selectedWeight);
    double protein = (calculatedCalories * 0.2) / 4;
    double carbs = (calculatedCalories * 0.5) / 4;
    double fats = (calculatedCalories * 0.3) / 9;

    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => NutritionDisplay(
              calories: calculatedCalories,
              protein: protein,
              carbs: carbs,
              fat: fats)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Target'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        color: const Color.fromARGB(255, 236, 241, 240),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Conditional text based on whether it's weight loss or gain
              (message == 'weight loss')
                  ? Text(
                      'How much weight do you want to lose per week?',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      'How much weight do you want to gain per week?',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 40),
              // Weight Selection Buttons
              ElevatedButton(
                onPressed: () => _handleWeightSelection(context, 0.5),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryFixedDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '0.5 kg',
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleWeightSelection(context, 1.0),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryFixedDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '1 kg',
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
