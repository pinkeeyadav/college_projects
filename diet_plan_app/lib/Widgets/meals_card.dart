

 

    /*  double breakfastCalorie=0.2 * calorie ;
   double launchCalorie=0.35 * calorie;
   double snacksCalorie=0.1 * calorie;
   double dinnerCalorie=0.35 * calorie;

   double breakfastProtein= 0.2 * protein;
    double launchProtein= 0.35 * protein;
     double snacksProtein= 0.1* protein;
      double dinnerProtein= 0.35 * protein;

       double breakfastcarbs= 0.2 * carbs;
        double launchcarbs= 0.35 * carbs;
     double snackscarbs= 0.1 * carbs;
      double dinnercarbs= 0.35 * carbs;

      double breakfastFats= 0.2 * fats;
        double launchFats= 0.35 * fats;
     double snacksFats= 0.1 * fats;
      double dinnerFats= 0.35 * fats;
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diet_plan_app/Widgets/nutritioncard.dart';
import 'package:diet_plan_app/Screens/food_display.dart'; 

class MealsCard extends StatelessWidget {
  final double calorie;
  final double protein;
  final double carbs;
  final double fats;

  MealsCard({
    super.key,
    required this.calorie,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  // Firestore and Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    double breakfastCalorie = 0.2 * calorie;
    double lunchCalorie = 0.35 * calorie;
    double snacksCalorie = 0.1 * calorie;
    double dinnerCalorie = 0.35 * calorie;

    // Store daily nutrition in Firestore
    _storeDailyNutritionInFirestore(
      breakfastCalorie: breakfastCalorie,
      lunchCalorie: lunchCalorie,
      snacksCalorie: snacksCalorie,
      dinnerCalorie: dinnerCalorie,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 16.0),
        GestureDetector(
          onTap: () {
            // Navigate to food display screen with breakfast calorie range
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDisplay(
                  minCalories: breakfastCalorie * 0.85,
                  maxCalories: breakfastCalorie * 1.15, 
                  mealType: 'Breakfast',
                ),
              ),
            );
          },
          child: NutritionCard(
            label: 'Breakfast',
            value: '${breakfastCalorie.toStringAsFixed(0)} kcal',
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16.0),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDisplay(
                  minCalories: lunchCalorie * 0.85,
                  maxCalories: lunchCalorie * 1.15,
                  mealType: 'Lunch',
                ),
              ),
            );
          },
          child: NutritionCard(
            label: 'Lunch',
            value: '${lunchCalorie.toStringAsFixed(0)} kcal',
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16.0),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDisplay(
                  minCalories: snacksCalorie * 0.85,
                  maxCalories: snacksCalorie * 1.15,
                  mealType: 'Snacks',
                ),
              ),
            );
          },
          child: NutritionCard(
            label: 'Snacks',
            value: '${snacksCalorie.toStringAsFixed(0)} kcal',
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16.0),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDisplay(
                  minCalories: dinnerCalorie * 0.85,
                  maxCalories: dinnerCalorie * 1.15,
                  mealType: 'Dinner',
                ),
              ),
            );
          },
          child: NutritionCard(
            label: 'Dinner',
            value: '${dinnerCalorie.toStringAsFixed(0)} kcal',
            color: Colors.yellow,
          ),
        ),
      ],
    );
  }

  Future<void> _storeDailyNutritionInFirestore({
    required double breakfastCalorie,
    required double lunchCalorie,
    required double snacksCalorie,
    required double dinnerCalorie,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('nutrition_intake')
            .doc('daily_intake')
            .set({
          'breakfastCalorie': breakfastCalorie,
          'lunchCalorie': lunchCalorie,
          'snacksCalorie': snacksCalorie,
          'dinnerCalorie': dinnerCalorie,
        }, SetOptions(merge: true)); // Merging to avoid overwriting other fields
      }
    } catch (e) {
      print('Error storing nutrition data: $e');
    }
  }
}
