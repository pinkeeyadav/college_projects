import 'package:flutter/material.dart';
import 'package:diet_plan_app/models/recipe_detail.dart';
import 'package:diet_plan_app/service/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDetailScreen extends StatelessWidget {
  final int recipeId;
  final String mealType;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<RecipeDetail>(
        future: ApiService().fetchRecipeDetail(recipeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          else if (snapshot.hasData) {
            final recipe = snapshot.data!;
            // Get the diet types, including "Non-Vegetarian" if applicable
            final dietTypes = _getDietTypes(recipe.ingredients, recipe.dietTypes);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Recipe Details'),
                 
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showDaySelectionDialog(context, mealType, recipe);
                    },
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(25),
                  color: const Color.fromARGB(255, 206, 240, 237),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(recipe.imageUrl),
                      const SizedBox(height: 16.0),
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text('Ready in: ${recipe.readyInMinutes} minutes'),
                      Text('Servings: ${recipe.servings}'),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Ingredients:',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      ...recipe.ingredients.map((ingredient) => Text('- $ingredient')),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Instructions:',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Text(recipe.instructions),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Diet Types:',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      ...dietTypes.map((diet) => Text('- $diet')),
                    ],
                  ),
                ),
              ),
            );
          } 
          else {
            return const Center(child: Text('Recipe not found.'));
          }
        },
      ),
    );
  }

  // Function to determine and add "Non-Vegetarian" based on ingredients
  List<String> _getDietTypes(List<String> ingredients, List<String> existingDietTypes) {
    List<String> updatedDietTypes = List.from(existingDietTypes); // Copy existing diet types
    bool isNonVeg = _checkForNonVegIngredients(ingredients);

    // Add 'Non-Vegetarian' to the diet types if non-veg ingredients are found
    if (isNonVeg) {
      updatedDietTypes.add('Non-Vegetarian');
    }

    return updatedDietTypes;
  }

  // Function to check if there are non-vegetarian ingredients
  bool _checkForNonVegIngredients(List<String> ingredients) {
    // List of common non-vegetarian ingredients
    List<String> nonVegItems = [
      'chicken', 'beef', 'pork', 'fish', 'mutton', 'bacon', 'sausage',
      'turkey', 'shrimp', 'crab', 'lamb', 'duck', 'ham', 'steak', 'venison', 'meat', 'salmon'
    ];

    // Check if any ingredient is non-vegetarian
    for (String ingredient in ingredients) {
      for (String nonVeg in nonVegItems) {
        if (ingredient.toLowerCase().contains(nonVeg)) {
          return true; // Non-veg item found
        }
      }
    }
    return false; // No non-veg items found
  }

  // Show a dialog for selecting the day of the week
  void _showDaySelectionDialog(BuildContext context, String mealType, RecipeDetail recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add recipe to day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDayOption(context, 'Sunday', mealType, recipe),
              _buildDayOption(context, 'Monday', mealType, recipe),
              _buildDayOption(context, 'Tuesday', mealType, recipe),
              _buildDayOption(context, 'Wednesday', mealType, recipe),
              _buildDayOption(context, 'Thursday', mealType, recipe),
              _buildDayOption(context, 'Friday', mealType, recipe),
              _buildDayOption(context, 'Saturday', mealType, recipe),
            ],
          ),
        );
      },
    );
  }

  // Build day selection options
  Widget _buildDayOption(BuildContext context, String day, String mealType, RecipeDetail recipe) {
    return ListTile(
      title: Text(day),
      onTap: () {
        saveRecipeForDay(day, recipe, mealType);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe added to $day\'s $mealType.')),
        );
      },
    );
  }

  // Save the selected recipe to Firestore
  void saveRecipeForDay(String dayOfWeek, RecipeDetail recipe, String mealType) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final String? userId = auth.currentUser?.uid;

    if (userId == null) {
      print('Error: User not logged in');
      return;
    }

    // Create a map to store the recipe details
    Map<String, dynamic> recipeData = {
      'recipeID': recipe.id,
      'recipeTitle': recipe.title,
    };

    // Reference to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Add the recipe to Firestore under user's diet plan
    await firestore
      .collection('users')
      .doc(userId)
      .collection('dietPlan')
      .doc(mealType)     // breakfast, lunch, snacks, or dinner
      .collection('days')  
      .doc(dayOfWeek)  // Sunday, Monday, etc. 
      .set(recipeData);

    print('Recipe for $mealType added to $dayOfWeek');
  }
}
