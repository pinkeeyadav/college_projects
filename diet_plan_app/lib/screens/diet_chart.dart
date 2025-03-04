import 'package:diet_plan_app/screens/food_display.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diet_plan_app/screens/recipe_detail_screen.dart';

class WeeklyDietChart extends StatefulWidget {
  final List<Map<String, String>> weeklyDiet;

   WeeklyDietChart({
    super.key,
    required this.weeklyDiet,
  });

  @override
  State<WeeklyDietChart> createState() => _WeeklyDietChartState();
}

class _WeeklyDietChartState extends State<WeeklyDietChart> {




final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Variables to hold fetched values
  double? breakfastCalorie;
  double? lunchCalorie;
  double? snacksCalorie;
  double? dinnerCalorie;

  @override
  void initState() {
    super.initState();
    _fetchDailyNutrition();
  }

  Future<void> _fetchDailyNutrition() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('nutrition_intake')
            .doc('daily_intake')
            .get();
            
        // Assuming data is stored in double format
        setState(() {
          breakfastCalorie = (snapshot['breakfastCalorie'] as num?)?.toDouble();
          lunchCalorie = (snapshot['lunchCalorie'] as num?)?.toDouble();
          snacksCalorie = (snapshot['snacksCalorie'] as num?)?.toDouble();
          dinnerCalorie = (snapshot['dinnerCalorie'] as num?)?.toDouble();
        });
      }
    } catch (e) {
      print('Error fetching nutrition data: $e');
    }
  }






  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Table(
        border: TableBorder.all(color: Colors.grey, width: 1),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1.0),
          1: FlexColumnWidth(2.0),
          2: FlexColumnWidth(2.0),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
        },
        children: [
          _buildTableHeader(),
          _buildTableRow('Sunday'),
          _buildTableRow('Monday'),
          _buildTableRow('Tuesday'),
          _buildTableRow('Wednesday'),
          _buildTableRow('Thursday'),
          _buildTableRow('Friday'),
          _buildTableRow('Saturday'),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blueAccent),
      children: [
        _buildTableCell('Day', isHeader: true),
        _buildTableCell('Breakfast', isHeader: true),
        _buildTableCell('Lunch', isHeader: true),
        _buildTableCell('Snacks', isHeader: true),
        _buildTableCell('Dinner', isHeader: true),
      ],
    );
  }

  TableRow _buildTableRow(String day) {
    return TableRow(
      children: [
        _buildTableCell(day, isHeader: true),
        _buildMealSlot(day, 'Breakfast', const Color.fromARGB(255, 213, 190, 160)),
        _buildMealSlot(day, 'Lunch', const Color.fromARGB(255, 168, 244, 207)),
        _buildMealSlot(day, 'Snacks', const Color.fromARGB(255, 241, 211, 247)),
        _buildMealSlot(day, 'Dinner', const Color.fromARGB(255, 245, 177, 177)),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      color: isHeader ? const Color.fromARGB(255, 132, 173, 245) : Colors.white,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.black,
        ),
      ),
    );
  }



Widget _buildMealSlot(String day, String category, Color color) {
  final mealEntry = widget.weeklyDiet.firstWhere(
    (entry) => entry['day'] == day && entry['category'] == category,
    orElse: () => {'title': 'No meal added'},
  );

  final mealTitle = mealEntry['title'];
  final recipeId = mealEntry['recipeID']; // Use the correct key

  return GestureDetector(
    onTap: () {
      if (mealTitle != 'No meal added' && recipeId != null) {
        // Ensure recipeId is converted to int correctly
        final parsedRecipeId = int.tryParse(recipeId);
        
        if (parsedRecipeId != null) {
          // Navigate to RecipeDetailScreen with recipeId and mealType
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(
                recipeId: parsedRecipeId,
                mealType: category,
              ),
            ),
          );
        } else {
          print('Invalid Recipe ID: $recipeId');
        }
      } else {
        // Define calorie ranges for each meal type
        double minCalories = 0.0;
        double maxCalories = 0.0;

        switch (category) { // Remove the lowercase conversion
          case 'Breakfast':
            minCalories = (breakfastCalorie ?? 0.0) * 0.85;
            maxCalories = (breakfastCalorie ?? 0.0) * 1.85;
            break;
          case 'Lunch':
            minCalories = (lunchCalorie ?? 0.0) * 0.85;
            maxCalories = (lunchCalorie ?? 0.0) * 1.85;
            break;
          case 'Snacks':
            minCalories = (snacksCalorie ?? 0.0) * 0.85;
            maxCalories = (snacksCalorie ?? 0.0) * 1.85;
            break;
          case 'Dinner':
            minCalories = (dinnerCalorie ?? 0.0) * 0.85;
            maxCalories = (dinnerCalorie ?? 0.0) * 1.85;
            break;
        }

        // Navigate to FoodDisplay with the calculated range and meal type
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDisplay(
              minCalories: minCalories,
              maxCalories: maxCalories,
              mealType: category,
            ),
          ),
        );
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      color: color,
      child: Text(
        mealTitle ?? 'No meal added', // Ensure mealTitle is not null
        style: const TextStyle(color: Color.fromARGB(255, 15, 14, 14)),
        softWrap: true,
      ),
    ),
  );
}
}





   /*
Widget _buildMealSlot(String day, String category, Color color) {
  final mealEntry = widget.weeklyDiet.firstWhere(
    (entry) => entry['day'] == day && entry['category'] == category,
    orElse: () => {'title': 'No meal added'},
  );

  final mealTitle = mealEntry['title'];
  final recipeId = mealEntry['recipeID']; // Use the correct key

//  print('Category: $category');
  //print('Recipe ID: $recipeId');
  //print('Meal Title: $mealTitle');

  return GestureDetector(
    onTap: () {
      if (mealTitle != 'No meal added' && recipeId != null) {
        // Ensure recipeId is converted to int correctly
        final parsedRecipeId = int.tryParse(recipeId);
        
        if (parsedRecipeId != null) {
          // Navigate to RecipeDetailScreen with recipeId and mealType
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(
                recipeId: parsedRecipeId,
                mealType: category,
              ),
            ),
          );
        } else {
          print('Invalid Recipe ID: $recipeId');
        }
      } else {
        // Define calorie ranges for each meal type
        double minCalories = 0.0;
        double maxCalories = 0.0;

        switch (category.toLowerCase()) {
          case 'breakfast':
            minCalories = (breakfastCalorie ?? 0.0) * 0.85;
            maxCalories = (breakfastCalorie ?? 0.0) * 1.85;
            break;
          case 'lunch':
            minCalories = (lunchCalorie ?? 0.0) * 0.85;
            maxCalories = (lunchCalorie ?? 0.0) * 1.85;
            break;
          case 'snacks':
            minCalories = (snacksCalorie ?? 0.0) * 0.85;
            maxCalories = (snacksCalorie ?? 0.0) * 1.85;
            break;
          case 'dinner':
            minCalories = (dinnerCalorie ?? 0.0) * 0.85;
            maxCalories = (dinnerCalorie ?? 0.0) * 1.85;
            break;
        }

        // Navigate to FoodDisplay with the calculated range and meal type
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDisplay(
              minCalories: minCalories,
              maxCalories: maxCalories,
              mealType: category.capitalize(),
            ),
          ),
        );
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      color: color,
      child: Text(
        mealTitle ?? 'No meal added', // Ensure mealTitle is not null
        style: const TextStyle(color: Color.fromARGB(255, 15, 14, 14)),
        softWrap: true,
      ),
    ),
  );
}
}  */