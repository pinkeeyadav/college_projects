import 'package:diet_plan_app/screens/goal_screen.dart';
import 'package:flutter/material.dart';

class BmiDisplay extends StatelessWidget {
  const BmiDisplay({
    super.key,
    required this.messaage,
    required this.bmr,
    required this.bmi,

  });

  final String messaage;
  final double bmr;
  final double bmi;

  void _showGoalScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => GoalScreen(bmr: bmr, bmi: bmi,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Container(
        margin: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 236, 241, 240),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const SizedBox(height: 50,),
                Text(
                  messaage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    _showGoalScreen(context); // Navigate to GoalScreen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}