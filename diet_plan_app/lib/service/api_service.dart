
/*

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diet_plan_app/models/food.dart';
import 'package:diet_plan_app/models/recipe_detail.dart';

class ApiService {
  final String _apiKey = '92a5864b22854b86b49b649c2d615045';
  final String _baseNutrientUrl = 'https://api.spoonacular.com/recipes/findByNutrients';
  final String _baseRecipeDetailUrl = 'https://api.spoonacular.com/recipes';

  // Fetch filtered meals
  Future<List<Food>> fetchFilteredMeals(
      String mealType, double minCalories, double maxCalories, String userDietaryPreference) async {
    List<Food> meals = await fetchMeals(mealType, minCalories, maxCalories);

    // Fetch details of each meal to check the diet types
    List<Food> filteredMeals = [];

    for (var meal in meals) {
      RecipeDetail? recipeDetail = await fetchRecipeDetail(meal.id);

      // If the recipe detail matches user preference, add it to the filtered list
      if (recipeDetail != null && recipeDetail.matchesUserPreference(userDietaryPreference)) {
        filteredMeals.add(meal);
      }
    }

    return filteredMeals;
  }

  // Fetch meals based on calorie range and meal type
  Future<List<Food>> fetchMeals(String mealType, double minCalories, double maxCalories) async {
    final url = Uri.parse(
        '$_baseNutrientUrl?apiKey=$_apiKey&minCalories=$minCalories&maxCalories=$maxCalories');

    try {
      final response = await _retryRequest(() => http.get(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Fetched Foods: $data'); // Debugging output

        // Parse the list of food items from the response
        return data.map((json) => Food.fromJson(json as Map<String, dynamic>, mealType)).toList();
      } else {
        print('Failed to load meals. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      print('Error occurred during fetchMeals: $e');
      throw Exception('Failed to load meals');
    }
  }

  // Fetch recipe details by recipe ID
  Future<RecipeDetail>? fetchRecipeDetail(int recipeId) async {
    final url = Uri.parse(
        '$_baseRecipeDetailUrl/$recipeId/information?includeNutrition=false&apiKey=$_apiKey');

    try {
      final response = await _retryRequest(() => http.get(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Recipe Detail: $data'); // Debugging output

        // Parse the recipe details and return
        return RecipeDetail.fromJson(data as Map<String, dynamic>);
      } else {
        print('Failed to load recipe details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load recipe details');
      }
    } catch (e) {
      print('Error occurred during fetchRecipeDetail: $e');
      throw Exception('Failed to load recipe details');
    }
  }

  // Retry logic for API requests
  Future<http.Response> _retryRequest(Future<http.Response> Function() request, {int retries = 3}) async {
    for (var attempt = 0; attempt < retries; attempt++) {
      try {
        var response = await request();
        if (response.statusCode == 200) {
          return response;
        } else {
          print('Request failed with status ${response.statusCode}, retrying...');
        }
      } catch (e) {
        print('Request error: $e');
        if (attempt == retries - 1) {
          rethrow; // Rethrow the error if it's the last retry
        }
      }
      await Future.delayed(Duration(seconds: 2)); // Delay between retries
    }
    throw Exception('Failed to fetch after $retries attempts');
  }
}

// Extension to match dietary preference with the recipe detail
extension RecipeDetailExtension on RecipeDetail {
  bool matchesUserPreference(String userDietaryPreference) {
    // Convert user preference and diet types to lowercase for case-insensitive comparison
    userDietaryPreference = userDietaryPreference.toLowerCase();
    List<String> lowerCaseDietTypes = dietTypes.map((diet) => diet.toLowerCase()).toList();

    // Handle Vegan preference: Show only foods that are not vegetarian and non-veg
    if (userDietaryPreference == 'vegan') {
      return !(lowerCaseDietTypes.contains('vegetarian') || lowerCaseDietTypes.contains('non-veg'));
    }

    // Handle Vegetarian preference: Show foods that are either vegan or vegetarian, but not non-veg
    else if (userDietaryPreference == 'vegetarian') {
      return (lowerCaseDietTypes.contains('vegan') || lowerCaseDietTypes.contains('vegetarian')) &&
          !lowerCaseDietTypes.contains('non-veg');
    }

    // Handle Non-Veg preference: Show all foods (no filtering needed)
    else if (userDietaryPreference == 'non-veg') {
      return true;
    }

    return false;
  }
}




/*
extension RecipeDetailExtension on RecipeDetail {
  bool matchesUserPreference(String userDietaryPreference) {
    // Handle case where userDietaryPreference is empty or invalid
    if (userDietaryPreference.isEmpty) return false;

    // Convert user preference to lowercase for case-insensitive comparison
    userDietaryPreference = userDietaryPreference.toLowerCase();

    // Check if the user's dietary preference matches any of the diet types
    print((dietTypes.any((dietType) => dietType.toLowerCase() == userDietaryPreference)));
    return dietTypes.any((dietType) => dietType.toLowerCase() == userDietaryPreference);
    
  }
}  */


/*
extension RecipeDetailExtension on RecipeDetail {
  bool matchesUserPreference(String userDietaryPreference) {
    switch (userDietaryPreference.toLowerCase()) {
      case 'vegan':
        return dietTypes.contains('Vegan');
      case 'vegetarian':
        return dietTypes.contains('Vegetarian');
      case 'non-veg':
        return true; // Non-veg users can see all foods
      default:
        return false;
    }
  }
} */

*/










import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diet_plan_app/models/food.dart';
import 'package:diet_plan_app/models/recipe_detail.dart';


class ApiService {
  final String _apiKey = '92a5864b22854b86b49b649c2d615045'; 
  final String _baseUrl = 'https://api.spoonacular.com/recipes/findByNutrients';








  Future<List<Food>> fetchMeals(String mealType, double minCalories, double maxCalories) async {
  final response = await http.get(Uri.parse(
    '$_baseUrl?apiKey=$_apiKey&minCalories=$minCalories&maxCalories=$maxCalories&number=30',
  ));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
   // print('API Response: $data'); // Print the API response for debugging
   

    if (data != null && data is List) {
        List<Food> foodList = parseFoodList(data, mealType);

        // Debug: Print the image URLs
         /* for (var food in foodList) {
        //  print('Image URL: ${food.imageUrl}'); // Print each image URL
        } */

        return foodList;
      } else {
        throw Exception('Unexpected data structure');
      }
    } else {
      throw Exception('Failed to load meals');
    }
  }




Future<RecipeDetail>? fetchRecipeDetail(int recipeId) async {
    final response = await http.get(
      Uri.parse('https://api.spoonacular.com/recipes/$recipeId/information?includeNutrition=false&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print(data);
      return RecipeDetail.fromJson(data);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }








  // Parse the list of food items from JSON
  List<Food> parseFoodList(List<dynamic> jsonList, String mealType) {
    return jsonList.map((json) => Food.fromJson(json as Map<String, dynamic>, mealType)).toList();
  }
}
