import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diet_plan_app/Widgets/nutritioncard.dart';
import 'package:diet_plan_app/screens/tabs._screen.dart';

class NutritionDisplay extends StatelessWidget {
   NutritionDisplay({
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

  // Firestore and Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store nutrition data in Firestore
  Future<void> _storeNutritionInFirestore() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).collection('nutrition_intake').doc('daily_intake').set({
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
        }); // Merging to avoid overwriting other fields
      }
    } catch (e) {
      print('Error storing nutrition data: $e');
    }
  }

  
  
  void showDietaryScreen (BuildContext context) async
  {
       await _storeNutritionInFirestore(); 
        Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const TabsScreen(),
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
      body: Column(
        children: <Widget>[
          const SizedBox(height: 16.0),
          Text(
            'Your daily nutrition intake as:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 16.0),
          NutritionCard(
            label: 'Calories',
            value: '${calories.toStringAsFixed(0)} kcal',
            color: Colors.red,
          ),
          const SizedBox(height: 16.0),
          NutritionCard(
            label: 'Protein',
            value: '${protein.toStringAsFixed(0)} g',
            color: Colors.blue,
          ),
          const SizedBox(height: 16.0),
          NutritionCard(
            label: 'Carbs',
            value: '${carbs.toStringAsFixed(0)} g',
            color: Colors.green,
          ),
          const SizedBox(height: 16.0),
          NutritionCard(
            label: 'Fat',
            value: '${fat.toStringAsFixed(0)} g',
            color: Colors.yellow,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              showDietaryScreen(context);
            },
            child: const Text(
              'Next',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 79, 59, 59),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
