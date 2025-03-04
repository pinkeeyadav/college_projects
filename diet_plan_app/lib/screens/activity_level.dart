


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diet_plan_app/screens/nutrition_display.dart';
import 'package:diet_plan_app/screens/weight_target_question.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({
    super.key,
    required this.bmr,
    required this.message,
  });
  final double bmr;
  final String message;

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? _selectedActivityLevel;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to calculate calories based on activity level
  double _calculationOfCalories() {
    double bmrValue = widget.bmr;

    double calorie = 0;
    if (_selectedActivityLevel == 'Sedentary (little or no exercise)') {
      calorie = bmrValue * 1.2;
    } else if (_selectedActivityLevel == 'Lightly active (light exercise/sports 1-3 days/week)') {
      calorie = bmrValue * 1.375;
    } else if (_selectedActivityLevel == 'Moderately active (Moderate exercise/sports 3-5 days/week)') {
      calorie = bmrValue * 1.55;
    } else if (_selectedActivityLevel == 'Very active (hard exercise/sports 6-7 days a week)') {
      calorie = bmrValue * 1.725;
    } else if (_selectedActivityLevel == 'Extra active (very hard exercise/sports & physical job for 2x training)') {
      calorie = bmrValue * 1.9;
    }
    return calorie;
  }

  // Method to store selected activity level in Firestore
  Future<void> _storeActivityLevelInFirestore() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null && _selectedActivityLevel != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'activityLevel': _selectedActivityLevel,
        }, SetOptions(merge: true));  // Merging to avoid overwriting other fields
      }
    } catch (e) {
      print('Error storing activity level: $e');
    }
  }

  // Method to calculate calories and navigate to the next screen
  void calorieCalculation() async {
    String messageValue = widget.message;
    double calorie = _calculationOfCalories();

    await _storeActivityLevelInFirestore();  // Store activity level in Firestore

    if (messageValue == 'weight maintain') {
      double protein = (calorie * 0.1) / 4;
      double carbs = (calorie * 0.45) / 4;
      double fats = (calorie * 0.2) / 9;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => NutritionDisplay(
            calories: calorie,
            protein: protein,
            carbs: carbs,
            fat: fats,
          ),
        ),
      );
    } else if (messageValue == 'weight loss') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) =>
              WeightTargetScreen(message: 'weight loss', calorie: calorie),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) =>
              WeightTargetScreen(message: 'weight gain', calorie: calorie),
        ),
      );
    }
  }

  // Method to show details in a dialog
  void _showDetails(String activityLevel) {
    String details;
    switch (activityLevel) {
      case 'Sedentary (little or no exercise)':
        details = '''Sedentary (Little to no exercise):

Daily life: Minimal movement, mostly sitting or lying down.
Job example: Office worker, computer programmer, receptionist.
Physical activity: Only basic tasks like sitting at a desk, watching TV, or light walking (e.g., to the kitchen or bathroom).''';
        break;
      case 'Lightly active (light exercise/sports 1-3 days/week)':
        details = '''Lightly Active (Light daily activity):

Daily life: Some light movement, like walking or standing occasionally.
Job example: Teacher, cashier, salesperson.
Physical activity: Walking short distances, standing during work, light housework. You might exercise once or twice a week, but it's not regular.''';
        break;
      case 'Moderately active (Moderate exercise/sports 3-5 days/week)':
        details = '''Moderately Active (Moderate physical activity):

Daily life: Regular movement or exercise.
Job example: Nurse, waiter, delivery person.
Physical activity: Walking for 30-60 minutes a day, or moderate-intensity exercise 3-5 days a week. You may stand or move around frequently during your job.''';
        break;
      case 'Very active (hard exercise/sports 6-7 days a week)':
        details = '''Very Active (Physically demanding):

Daily life: High level of movement and physical work or regular intense exercise.
Job example: Construction worker, farmer, fitness trainer.
Physical activity: Involves heavy lifting, intense manual labor, or exercising vigorously almost daily. You're on your feet a lot and rarely sit still.''';
        break;
      case 'Extra active (very hard exercise/sports & physical job for 2x training)':
        details = '''Extra Active (Extremely demanding):

Daily life: Almost constant intense physical activity or sports training.
Job example: Professional athlete, military personnel, or extremely labor-intensive jobs.
Physical activity: Very intense exercise for several hours daily, or jobs that require constant heavy lifting, climbing, or fast movement.''';
        break;
      default:
        details = 'No details available.';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Details for $activityLevel'),
          content: Text(details),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Level Survey'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'How would you describe your current activity level:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildActivityLevelOption('Sedentary (little or no exercise)'),
            _buildActivityLevelOption('Lightly active (light exercise/sports 1-3 days/week)'),
            _buildActivityLevelOption('Moderately active (Moderate exercise/sports 3-5 days/week)'),
            _buildActivityLevelOption('Very active (hard exercise/sports 6-7 days a week)'),
            _buildActivityLevelOption('Extra active (very hard exercise/sports & physical job for 2x training)'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                calorieCalculation();
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
    );
  }

  Widget _buildActivityLevelOption(String activityLevel) {
    return ListTile(
      title: Text(activityLevel),
      trailing: TextButton(
        onPressed: () {
          _showDetails(activityLevel);
        },
        child: const Text('View More Details'),
      ),
      leading: Radio<String>(
        value: activityLevel,
        groupValue: _selectedActivityLevel,
        onChanged: (value) {
          setState(() {
            _selectedActivityLevel = value;
          });
        },
      ),
    );
  }
}











/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diet_plan_app/screens/nutrition_display.dart';
import 'package:diet_plan_app/screens/weight_target_question.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({
    super.key,
    required this.bmr,
    required this.message,
  });
  final double bmr;
  final String message;

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? _selectedActivityLevel;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to calculate calories based on activity level
  double _calculationOfCalories() {
    double bmrValue = widget.bmr;

    double calorie = 0;
    if (_selectedActivityLevel == 'Sedentary( little or no exercise)') {
      calorie = bmrValue * 1.2;
    } else if (_selectedActivityLevel ==
        'Lightly active(light exercise/sports 1-3 days/week)') {
      calorie = bmrValue * 1.375;
    } else if (_selectedActivityLevel ==
        'Moderately active(Moderate exercise/sports 3-5 days/week)') {
      calorie = bmrValue * 1.55;
    } else if (_selectedActivityLevel ==
        'Very active(hard exercise/sports 6-7 days a week)') {
      calorie = bmrValue * 1.725;
    } else if (_selectedActivityLevel ==
        'Extra active(very hard exercise/sports & physical job for 2x training)') {
      calorie = bmrValue * 1.9;
    }
    return calorie;
  }

  // Method to store selected activity level in Firestore
  Future<void> _storeActivityLevelInFirestore() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null && _selectedActivityLevel != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'activityLevel': _selectedActivityLevel,
        }, SetOptions(merge: true));  // Merging to avoid overwriting other fields
      }
    } catch (e) {
      print('Error storing activity level: $e');
    }
  }

  // Method to calculate calories and navigate to the next screen
  void calorieCalculation() async {
    String messageValue = widget.message;
    double calorie = _calculationOfCalories();

    await _storeActivityLevelInFirestore();  // Store activity level in Firestore

    if (messageValue == 'weight maintain') {
      double protein = (calorie * 0.1) / 4;
      double carbs = (calorie * 0.45) / 4;
      double fats = (calorie * 0.2) / 9;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => NutritionDisplay(
            calories: calorie,
            protein: protein,
            carbs: carbs,
            fat: fats,
          ),
        ),
      );
    } else if (messageValue == 'weight loss') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) =>
              WeightTargetScreen(message: 'weight loss', calorie: calorie),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) =>
              WeightTargetScreen(message: 'weight gain', calorie: calorie),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Level Survey'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'How would you describe your current activity level:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildActivityLevelOption('Sedentary( little or no exercise)'),
            _buildActivityLevelOption(
                'Lightly active(light exercise/sports 1-3 days/week)'),
            _buildActivityLevelOption(
                'Moderately active(Moderate exercise/sports 3-5 days/week)'),
            _buildActivityLevelOption(
                'Very active(hard exercise/sports 6-7 days a week)'),
            _buildActivityLevelOption(
                'Extra active(very hard exercise/sports & physical job for 2x training)'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                calorieCalculation();
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
    );
  }

  Widget _buildActivityLevelOption(String activityLevel) {
    return ListTile(
      title: Text(activityLevel),
      leading: Radio<String>(
        value: activityLevel,
        groupValue: _selectedActivityLevel,
        onChanged: (value) {
          setState(() {
            _selectedActivityLevel = value;
          });
        },
      ),
    );
  }
}
*/
